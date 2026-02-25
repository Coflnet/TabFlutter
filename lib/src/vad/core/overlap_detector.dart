// lib/src/vad/core/overlap_detector.dart
// Detects overlapping speech (multiple speakers talking simultaneously)

import 'dart:math';
import 'dart:typed_data';

/// Result of overlap detection analysis
class OverlapAnalysis {
  final bool hasOverlap;
  final double overlapConfidence;
  final int overlapFrameCount;
  final int totalFrames;

  double get overlapRatio =>
      totalFrames > 0 ? overlapFrameCount / totalFrames : 0.0;

  const OverlapAnalysis({
    required this.hasOverlap,
    required this.overlapConfidence,
    required this.overlapFrameCount,
    required this.totalFrames,
  });

  @override
  String toString() =>
      'OverlapAnalysis(hasOverlap: $hasOverlap, confidence: ${overlapConfidence.toStringAsFixed(2)}, '
      'overlapFrames: $overlapFrameCount/$totalFrames, ratio: ${(overlapRatio * 100).toStringAsFixed(1)}%)';
}

class OverlapDetector {
  final int sampleRate;
  final int frameSize;
  final double zcrVarianceThreshold;
  final double energyVarianceThreshold;
  final double minOverlapRatio;

  double _baselineZcrVariance = 0.0;
  double _baselineEnergyVariance = 0.0;
  int _calibrationFrames = 0;
  static const int _calibrationPeriod = 20;

  final List<double> _zcrHistory = [];
  final List<double> _energyHistory = [];
  int _overlapFrameCount = 0;
  int _totalFramesAnalyzed = 0;

  OverlapDetector({
    this.sampleRate = 16000,
    this.frameSize = 512,
    this.zcrVarianceThreshold = 2.5,
    this.energyVarianceThreshold = 3.0,
    this.minOverlapRatio = 0.15,
  });

  void reset() {
    _baselineZcrVariance = 0.0;
    _baselineEnergyVariance = 0.0;
    _calibrationFrames = 0;
    _zcrHistory.clear();
    _energyHistory.clear();
    _overlapFrameCount = 0;
    _totalFramesAnalyzed = 0;
  }

  bool analyzeFrame(Float32List samples) {
    if (samples.isEmpty) return false;

    _totalFramesAnalyzed++;

    final zcr = _calculateZeroCrossingRate(samples);
    _zcrHistory.add(zcr);

    final energy = _calculateEnergy(samples);
    _energyHistory.add(energy);

    if (_zcrHistory.length > 50) {
      _zcrHistory.removeAt(0);
      _energyHistory.removeAt(0);
    }

    if (_calibrationFrames < _calibrationPeriod) {
      _calibrationFrames++;
      if (_calibrationFrames == _calibrationPeriod) {
        _baselineZcrVariance = _calculateVariance(_zcrHistory);
        _baselineEnergyVariance = _calculateVariance(_energyHistory);
      }
      return false;
    }

    final isOverlapFrame = _detectOverlapInFrame();
    if (isOverlapFrame) {
      _overlapFrameCount++;
    }

    return isOverlapFrame;
  }

  OverlapAnalysis getAnalysis() {
    if (_totalFramesAnalyzed < _calibrationPeriod + 5) {
      return OverlapAnalysis(
        hasOverlap: false,
        overlapConfidence: 0.0,
        overlapFrameCount: 0,
        totalFrames: _totalFramesAnalyzed,
      );
    }

    final overlapRatio = _overlapFrameCount / _totalFramesAnalyzed;
    final hasOverlap = overlapRatio >= minOverlapRatio;

    double confidence = 0.0;
    if (hasOverlap) {
      confidence = min(1.0, overlapRatio / minOverlapRatio - 0.5);
    }

    return OverlapAnalysis(
      hasOverlap: hasOverlap,
      overlapConfidence: confidence,
      overlapFrameCount: _overlapFrameCount,
      totalFrames: _totalFramesAnalyzed,
    );
  }

  bool _detectOverlapInFrame() {
    if (_zcrHistory.length < 5) return false;

    final recentZcr = _zcrHistory.sublist(max(0, _zcrHistory.length - 10));
    final zcrVariance = _calculateVariance(recentZcr);

    final recentEnergy =
        _energyHistory.sublist(max(0, _energyHistory.length - 10));
    final energyVariance = _calculateVariance(recentEnergy);

    final zcrElevated = _baselineZcrVariance > 0 &&
        zcrVariance > _baselineZcrVariance * zcrVarianceThreshold;
    final energyElevated = _baselineEnergyVariance > 0 &&
        energyVariance > _baselineEnergyVariance * energyVarianceThreshold;

    final spectralIndicator = _checkSpectralOverlapIndicator(recentEnergy);

    int indicators = 0;
    if (zcrElevated) indicators++;
    if (energyElevated) indicators++;
    if (spectralIndicator) indicators++;

    return indicators >= 2;
  }

  bool _checkSpectralOverlapIndicator(List<double> energyHistory) {
    if (energyHistory.length < 3) return false;

    int rapidChanges = 0;
    for (int i = 1; i < energyHistory.length; i++) {
      final change = (energyHistory[i] - energyHistory[i - 1]).abs();
      final avgEnergy = (energyHistory[i] + energyHistory[i - 1]) / 2;
      if (avgEnergy > 0 && change / avgEnergy > 0.5) {
        rapidChanges++;
      }
    }

    return rapidChanges / (energyHistory.length - 1) > 0.4;
  }

  double _calculateZeroCrossingRate(Float32List samples) {
    if (samples.length < 2) return 0.0;

    int crossings = 0;
    for (int i = 1; i < samples.length; i++) {
      if ((samples[i] >= 0 && samples[i - 1] < 0) ||
          (samples[i] < 0 && samples[i - 1] >= 0)) {
        crossings++;
      }
    }

    return crossings / (samples.length - 1);
  }

  double _calculateEnergy(Float32List samples) {
    if (samples.isEmpty) return 0.0;

    double sum = 0.0;
    for (final sample in samples) {
      sum += sample * sample;
    }

    return sum / samples.length;
  }

  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    double sumSquaredDiff = 0.0;
    for (final v in values) {
      sumSquaredDiff += (v - mean) * (v - mean);
    }

    return sumSquaredDiff / (values.length - 1);
  }
}
