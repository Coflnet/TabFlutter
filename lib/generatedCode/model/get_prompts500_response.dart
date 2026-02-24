//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class GetPrompts500Response {
  /// Returns a new [GetPrompts500Response] instance.
  GetPrompts500Response({
    this.slug,
    this.message,
    this.trace,
  });

  /// Human readable id for this kind of error
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? slug;

  /// Unknown error occured
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? message;

  /// Id for the error report with this id
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? trace;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GetPrompts500Response &&
    other.slug == slug &&
    other.message == message &&
    other.trace == trace;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (slug == null ? 0 : slug!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (trace == null ? 0 : trace!.hashCode);

  @override
  String toString() => 'GetPrompts500Response[slug=$slug, message=$message, trace=$trace]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.slug != null) {
      json[r'slug'] = this.slug;
    } else {
      json[r'slug'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.trace != null) {
      json[r'trace'] = this.trace;
    } else {
      json[r'trace'] = null;
    }
    return json;
  }

  /// Returns a new [GetPrompts500Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GetPrompts500Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GetPrompts500Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GetPrompts500Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GetPrompts500Response(
        slug: mapValueOfType<String>(json, r'slug'),
        message: mapValueOfType<String>(json, r'message'),
        trace: mapValueOfType<String>(json, r'trace'),
      );
    }
    return null;
  }

  static List<GetPrompts500Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GetPrompts500Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GetPrompts500Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GetPrompts500Response> mapFromJson(dynamic json) {
    final map = <String, GetPrompts500Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GetPrompts500Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GetPrompts500Response-objects as value to a dart map
  static Map<String, List<GetPrompts500Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GetPrompts500Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GetPrompts500Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

