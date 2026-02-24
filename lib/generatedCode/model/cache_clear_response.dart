//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CacheClearResponse {
  /// Returns a new [CacheClearResponse] instance.
  CacheClearResponse({
    this.message,
  });

  /// Human-readable confirmation message
  String? message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CacheClearResponse &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (message == null ? 0 : message!.hashCode);

  @override
  String toString() => 'CacheClearResponse[message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    return json;
  }

  /// Returns a new [CacheClearResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CacheClearResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CacheClearResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CacheClearResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CacheClearResponse(
        message: mapValueOfType<String>(json, r'message'),
      );
    }
    return null;
  }

  static List<CacheClearResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CacheClearResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CacheClearResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CacheClearResponse> mapFromJson(dynamic json) {
    final map = <String, CacheClearResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CacheClearResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CacheClearResponse-objects as value to a dart map
  static Map<String, List<CacheClearResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CacheClearResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CacheClearResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

