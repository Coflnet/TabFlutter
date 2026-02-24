//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ComplicatedCaseMetadataDto {
  /// Returns a new [ComplicatedCaseMetadataDto] instance.
  ComplicatedCaseMetadataDto({
    this.id,
    this.dialectId,
    this.audioId,
    this.audioBase64,
    this.audioBucket,
    this.transcription,
    this.uploaderEmail,
    this.reporterEmail,
    this.notes,
    this.reportedAt,
    this.status,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? dialectId;

  String? audioId;

  String? audioBase64;

  String? audioBucket;

  String? transcription;

  String? uploaderEmail;

  String? reporterEmail;

  String? notes;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? reportedAt;

  String? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ComplicatedCaseMetadataDto &&
    other.id == id &&
    other.dialectId == dialectId &&
    other.audioId == audioId &&
    other.audioBase64 == audioBase64 &&
    other.audioBucket == audioBucket &&
    other.transcription == transcription &&
    other.uploaderEmail == uploaderEmail &&
    other.reporterEmail == reporterEmail &&
    other.notes == notes &&
    other.reportedAt == reportedAt &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (dialectId == null ? 0 : dialectId!.hashCode) +
    (audioId == null ? 0 : audioId!.hashCode) +
    (audioBase64 == null ? 0 : audioBase64!.hashCode) +
    (audioBucket == null ? 0 : audioBucket!.hashCode) +
    (transcription == null ? 0 : transcription!.hashCode) +
    (uploaderEmail == null ? 0 : uploaderEmail!.hashCode) +
    (reporterEmail == null ? 0 : reporterEmail!.hashCode) +
    (notes == null ? 0 : notes!.hashCode) +
    (reportedAt == null ? 0 : reportedAt!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'ComplicatedCaseMetadataDto[id=$id, dialectId=$dialectId, audioId=$audioId, audioBase64=$audioBase64, audioBucket=$audioBucket, transcription=$transcription, uploaderEmail=$uploaderEmail, reporterEmail=$reporterEmail, notes=$notes, reportedAt=$reportedAt, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.dialectId != null) {
      json[r'dialectId'] = this.dialectId;
    } else {
      json[r'dialectId'] = null;
    }
    if (this.audioId != null) {
      json[r'audioId'] = this.audioId;
    } else {
      json[r'audioId'] = null;
    }
    if (this.audioBase64 != null) {
      json[r'audioBase64'] = this.audioBase64;
    } else {
      json[r'audioBase64'] = null;
    }
    if (this.audioBucket != null) {
      json[r'audioBucket'] = this.audioBucket;
    } else {
      json[r'audioBucket'] = null;
    }
    if (this.transcription != null) {
      json[r'transcription'] = this.transcription;
    } else {
      json[r'transcription'] = null;
    }
    if (this.uploaderEmail != null) {
      json[r'uploaderEmail'] = this.uploaderEmail;
    } else {
      json[r'uploaderEmail'] = null;
    }
    if (this.reporterEmail != null) {
      json[r'reporterEmail'] = this.reporterEmail;
    } else {
      json[r'reporterEmail'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    if (this.reportedAt != null) {
      json[r'reportedAt'] = this.reportedAt!.toUtc().toIso8601String();
    } else {
      json[r'reportedAt'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [ComplicatedCaseMetadataDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ComplicatedCaseMetadataDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ComplicatedCaseMetadataDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ComplicatedCaseMetadataDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ComplicatedCaseMetadataDto(
        id: mapValueOfType<String>(json, r'id'),
        dialectId: mapValueOfType<String>(json, r'dialectId'),
        audioId: mapValueOfType<String>(json, r'audioId'),
        audioBase64: mapValueOfType<String>(json, r'audioBase64'),
        audioBucket: mapValueOfType<String>(json, r'audioBucket'),
        transcription: mapValueOfType<String>(json, r'transcription'),
        uploaderEmail: mapValueOfType<String>(json, r'uploaderEmail'),
        reporterEmail: mapValueOfType<String>(json, r'reporterEmail'),
        notes: mapValueOfType<String>(json, r'notes'),
        reportedAt: mapDateTime(json, r'reportedAt', r''),
        status: mapValueOfType<String>(json, r'status'),
      );
    }
    return null;
  }

  static List<ComplicatedCaseMetadataDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ComplicatedCaseMetadataDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ComplicatedCaseMetadataDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ComplicatedCaseMetadataDto> mapFromJson(dynamic json) {
    final map = <String, ComplicatedCaseMetadataDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ComplicatedCaseMetadataDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ComplicatedCaseMetadataDto-objects as value to a dart map
  static Map<String, List<ComplicatedCaseMetadataDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ComplicatedCaseMetadataDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ComplicatedCaseMetadataDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

