//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PropertyInfo {
  /// Returns a new [PropertyInfo] instance.
  PropertyInfo({
    this.type,
    this.description,
    this.enumValues = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  FunctionObjectTypes? type;

  String? description;

  List<String>? enumValues;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PropertyInfo &&
    other.type == type &&
    other.description == description &&
    _deepEquality.equals(other.enumValues, enumValues);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (type == null ? 0 : type!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (enumValues == null ? 0 : enumValues!.hashCode);

  @override
  String toString() => 'PropertyInfo[type=$type, description=$description, enumValues=$enumValues]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.type != null) {
      json[r'type'] = this.type;
    } else {
      json[r'type'] = null;
    }
    if (this.description != null) {
      json[r'description'] = this.description;
    } else {
      json[r'description'] = null;
    }
    if (this.enumValues != null) {
      json[r'enumValues'] = this.enumValues;
    } else {
      json[r'enumValues'] = null;
    }
    return json;
  }

  /// Returns a new [PropertyInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PropertyInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PropertyInfo[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PropertyInfo[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PropertyInfo(
        type: FunctionObjectTypes.fromJson(json[r'type']),
        description: mapValueOfType<String>(json, r'description'),
        enumValues: json[r'enumValues'] is Iterable
            ? (json[r'enumValues'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<PropertyInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PropertyInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PropertyInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PropertyInfo> mapFromJson(dynamic json) {
    final map = <String, PropertyInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PropertyInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PropertyInfo-objects as value to a dart map
  static Map<String, List<PropertyInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PropertyInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PropertyInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

