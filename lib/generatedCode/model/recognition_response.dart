//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RecognitionResponse {
  /// Returns a new [RecognitionResponse] instance.
  RecognitionResponse({
    this.isComplete,
    this.text,
    this.columnWithText = const [],
    this.audioIds = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? isComplete;

  String? text;

  List<Map<String, String>>? columnWithText;

  /// List of audio ids that were combined to get the completed response.
  List<String>? audioIds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RecognitionResponse &&
    other.isComplete == isComplete &&
    other.text == text &&
    _deepEquality.equals(other.columnWithText, columnWithText) &&
    _deepEquality.equals(other.audioIds, audioIds);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (isComplete == null ? 0 : isComplete!.hashCode) +
    (text == null ? 0 : text!.hashCode) +
    (columnWithText == null ? 0 : columnWithText!.hashCode) +
    (audioIds == null ? 0 : audioIds!.hashCode);

  @override
  String toString() => 'RecognitionResponse[isComplete=$isComplete, text=$text, columnWithText=$columnWithText, audioIds=$audioIds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.isComplete != null) {
      json[r'isComplete'] = this.isComplete;
    } else {
      json[r'isComplete'] = null;
    }
    if (this.text != null) {
      json[r'text'] = this.text;
    } else {
      json[r'text'] = null;
    }
    if (this.columnWithText != null) {
      json[r'columnWithText'] = this.columnWithText;
    } else {
      json[r'columnWithText'] = null;
    }
    if (this.audioIds != null) {
      json[r'audioIds'] = this.audioIds;
    } else {
      json[r'audioIds'] = null;
    }
    return json;
  }

  /// Returns a new [RecognitionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RecognitionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RecognitionResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RecognitionResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RecognitionResponse(
        isComplete: mapValueOfType<bool>(json, r'isComplete'),
        text: mapValueOfType<String>(json, r'text'),
        columnWithText: Map.listFromJson(json[r'columnWithText']),
        audioIds: json[r'audioIds'] is Iterable
            ? (json[r'audioIds'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<RecognitionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RecognitionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RecognitionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RecognitionResponse> mapFromJson(dynamic json) {
    final map = <String, RecognitionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RecognitionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RecognitionResponse-objects as value to a dart map
  static Map<String, List<RecognitionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RecognitionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RecognitionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

