//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UploadRequest {
  /// Returns a new [UploadRequest] instance.
  UploadRequest({
    required this.base64Audio,
    required this.uploaderEmail,
    this.transcription,
  });

  String? base64Audio;

  String? uploaderEmail;

  String? transcription;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadRequest &&
    other.base64Audio == base64Audio &&
    other.uploaderEmail == uploaderEmail &&
    other.transcription == transcription;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (base64Audio == null ? 0 : base64Audio!.hashCode) +
    (uploaderEmail == null ? 0 : uploaderEmail!.hashCode) +
    (transcription == null ? 0 : transcription!.hashCode);

  @override
  String toString() => 'UploadRequest[base64Audio=$base64Audio, uploaderEmail=$uploaderEmail, transcription=$transcription]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.base64Audio != null) {
      json[r'base64Audio'] = this.base64Audio;
    } else {
      json[r'base64Audio'] = null;
    }
    if (this.uploaderEmail != null) {
      json[r'uploaderEmail'] = this.uploaderEmail;
    } else {
      json[r'uploaderEmail'] = null;
    }
    if (this.transcription != null) {
      json[r'transcription'] = this.transcription;
    } else {
      json[r'transcription'] = null;
    }
    return json;
  }

  /// Returns a new [UploadRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UploadRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UploadRequest(
        base64Audio: mapValueOfType<String>(json, r'base64Audio'),
        uploaderEmail: mapValueOfType<String>(json, r'uploaderEmail'),
        transcription: mapValueOfType<String>(json, r'transcription'),
      );
    }
    return null;
  }

  static List<UploadRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadRequest> mapFromJson(dynamic json) {
    final map = <String, UploadRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadRequest-objects as value to a dart map
  static Map<String, List<UploadRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'base64Audio',
    'uploaderEmail',
  };
}

