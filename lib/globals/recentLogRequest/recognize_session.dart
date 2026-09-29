import 'dart:async';

/// Client-held state of one recognition session (stateless recognize).
///
/// The server keeps nothing between chunks: every request carries the raw
/// texts and audio ids of the unfinished utterance. The state only advances
/// when a chunk succeeded, so a retry resends exactly the same state.
///
/// Chunks of a session run one after another ([run]); otherwise a chunk sent
/// while the previous one is still in flight would miss its text.
class RecognizeSession {
  RecognizeSession(this.id);

  /// Session id sent to the server.
  final String id;

  List<String> _pendingTexts = const [];
  List<String> _pendingAudioIds = const [];
  Future<void> _tail = Future.value();

  /// Raw texts to send with the next chunk (`[]` on the first chunk).
  List<String> get pendingTexts => _pendingTexts;

  /// Audio ids of earlier chunks of the current utterance.
  List<String> get pendingAudioIds => _pendingAudioIds;

  /// Applies a successful response.
  void apply(
      {required bool isComplete,
      List<String>? pendingTexts,
      List<String>? audioIds}) {
    if (isComplete) {
      _pendingTexts = const [];
      _pendingAudioIds = const [];
      return;
    }
    _pendingTexts = List.unmodifiable(pendingTexts ?? const <String>[]);
    _pendingAudioIds = List.unmodifiable(audioIds ?? const <String>[]);
  }

  /// Runs [task] after every earlier task of this session has finished,
  /// whether it succeeded or failed.
  Future<T> run<T>(Future<T> Function() task) {
    final result = _tail.then((_) => task());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}
