//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecognitionRequest {
  /// Returns a new [RecognitionRequest] instance.
  RecognitionRequest({
    this.base64Opus,
    this.language,
    this.sessionId,
    this.columnWithDescription = const {},
  });

  String? base64Opus;

  String? language;

  String? sessionId;

  Map<String, PropertyInfo>? columnWithDescription;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecognitionRequest &&
    other.base64Opus == base64Opus &&
    other.language == language &&
    other.sessionId == sessionId &&
    _deepEquality.equals(other.columnWithDescription, columnWithDescription);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (base64Opus == null ? 0 : base64Opus!.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (sessionId == null ? 0 : sessionId!.hashCode) +
    (columnWithDescription == null ? 0 : columnWithDescription!.hashCode);

  @override
  String toString() => 'RecognitionRequest[base64Opus=$base64Opus, language=$language, sessionId=$sessionId, columnWithDescription=$columnWithDescription]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.base64Opus != null) {
      json[r'base64Opus'] = this.base64Opus;
    } else {
      json[r'base64Opus'] = null;
    }
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.sessionId != null) {
      json[r'sessionId'] = this.sessionId;
    } else {
      json[r'sessionId'] = null;
    }
    if (this.columnWithDescription != null) {
      json[r'columnWithDescription'] = this.columnWithDescription;
    } else {
      json[r'columnWithDescription'] = null;
    }
    return json;
  }

  /// Returns a new [RecognitionRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecognitionRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecognitionRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecognitionRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecognitionRequest(
        base64Opus: mapValueOfType<String>(json, r'base64Opus'),
        language: mapValueOfType<String>(json, r'language'),
        sessionId: mapValueOfType<String>(json, r'sessionId'),
        columnWithDescription: PropertyInfo.mapFromJson(json[r'columnWithDescription']),
      );
    }
    return null;
  }

  static List<RecognitionRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecognitionRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecognitionRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecognitionRequest> mapFromJson(dynamic json) {
    final map = <String, RecognitionRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecognitionRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecognitionRequest-objects as value to a dart map
  static Map<String, List<RecognitionRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecognitionRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecognitionRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

