//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ApprovedSampleDto {
  /// Returns a new [ApprovedSampleDto] instance.
  ApprovedSampleDto({
    this.id,
    this.audioId,
    this.audioBucket,
    this.audioCurrentBucket,
    this.audioPresignedUrl,
    this.audioDownloadUrl,
    this.transcription,
    this.uploaderEmail,
    this.validator1Email,
    this.validator2Email,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? id;

  String? audioId;

  String? audioBucket;

  String? audioCurrentBucket;

  String? audioPresignedUrl;

  String? audioDownloadUrl;

  String? transcription;

  String? uploaderEmail;

  String? validator1Email;

  String? validator2Email;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ApprovedSampleDto &&
    other.id == id &&
    other.audioId == audioId &&
    other.audioBucket == audioBucket &&
    other.audioCurrentBucket == audioCurrentBucket &&
    other.audioPresignedUrl == audioPresignedUrl &&
    other.audioDownloadUrl == audioDownloadUrl &&
    other.transcription == transcription &&
    other.uploaderEmail == uploaderEmail &&
    other.validator1Email == validator1Email &&
    other.validator2Email == validator2Email;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id == null ? 0 : id!.hashCode) +
    (audioId == null ? 0 : audioId!.hashCode) +
    (audioBucket == null ? 0 : audioBucket!.hashCode) +
    (audioCurrentBucket == null ? 0 : audioCurrentBucket!.hashCode) +
    (audioPresignedUrl == null ? 0 : audioPresignedUrl!.hashCode) +
    (audioDownloadUrl == null ? 0 : audioDownloadUrl!.hashCode) +
    (transcription == null ? 0 : transcription!.hashCode) +
    (uploaderEmail == null ? 0 : uploaderEmail!.hashCode) +
    (validator1Email == null ? 0 : validator1Email!.hashCode) +
    (validator2Email == null ? 0 : validator2Email!.hashCode);

  @override
  String toString() => 'ApprovedSampleDto[id=$id, audioId=$audioId, audioBucket=$audioBucket, audioCurrentBucket=$audioCurrentBucket, audioPresignedUrl=$audioPresignedUrl, audioDownloadUrl=$audioDownloadUrl, transcription=$transcription, uploaderEmail=$uploaderEmail, validator1Email=$validator1Email, validator2Email=$validator2Email]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.audioId != null) {
      json[r'audioId'] = this.audioId;
    } else {
      json[r'audioId'] = null;
    }
    if (this.audioBucket != null) {
      json[r'audioBucket'] = this.audioBucket;
    } else {
      json[r'audioBucket'] = null;
    }
    if (this.audioCurrentBucket != null) {
      json[r'audioCurrentBucket'] = this.audioCurrentBucket;
    } else {
      json[r'audioCurrentBucket'] = null;
    }
    if (this.audioPresignedUrl != null) {
      json[r'audioPresignedUrl'] = this.audioPresignedUrl;
    } else {
      json[r'audioPresignedUrl'] = null;
    }
    if (this.audioDownloadUrl != null) {
      json[r'audioDownloadUrl'] = this.audioDownloadUrl;
    } else {
      json[r'audioDownloadUrl'] = null;
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
    if (this.validator1Email != null) {
      json[r'validator1Email'] = this.validator1Email;
    } else {
      json[r'validator1Email'] = null;
    }
    if (this.validator2Email != null) {
      json[r'validator2Email'] = this.validator2Email;
    } else {
      json[r'validator2Email'] = null;
    }
    return json;
  }

  /// Returns a new [ApprovedSampleDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ApprovedSampleDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ApprovedSampleDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ApprovedSampleDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ApprovedSampleDto(
        id: mapValueOfType<String>(json, r'id'),
        audioId: mapValueOfType<String>(json, r'audioId'),
        audioBucket: mapValueOfType<String>(json, r'audioBucket'),
        audioCurrentBucket: mapValueOfType<String>(json, r'audioCurrentBucket'),
        audioPresignedUrl: mapValueOfType<String>(json, r'audioPresignedUrl'),
        audioDownloadUrl: mapValueOfType<String>(json, r'audioDownloadUrl'),
        transcription: mapValueOfType<String>(json, r'transcription'),
        uploaderEmail: mapValueOfType<String>(json, r'uploaderEmail'),
        validator1Email: mapValueOfType<String>(json, r'validator1Email'),
        validator2Email: mapValueOfType<String>(json, r'validator2Email'),
      );
    }
    return null;
  }

  static List<ApprovedSampleDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ApprovedSampleDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ApprovedSampleDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ApprovedSampleDto> mapFromJson(dynamic json) {
    final map = <String, ApprovedSampleDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ApprovedSampleDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ApprovedSampleDto-objects as value to a dart map
  static Map<String, List<ApprovedSampleDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ApprovedSampleDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ApprovedSampleDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

