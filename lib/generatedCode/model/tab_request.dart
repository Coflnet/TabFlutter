//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TabRequest {
  /// Returns a new [TabRequest] instance.
  TabRequest({
    this.text,
    this.columnWithDescription = const {},
    this.requiredColums = const [],
  });

  String? text;

  Map<String, PropertyInfo>? columnWithDescription;

  List<String>? requiredColums;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TabRequest &&
    other.text == text &&
    _deepEquality.equals(other.columnWithDescription, columnWithDescription) &&
    _deepEquality.equals(other.requiredColums, requiredColums);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (text == null ? 0 : text!.hashCode) +
    (columnWithDescription == null ? 0 : columnWithDescription!.hashCode) +
    (requiredColums == null ? 0 : requiredColums!.hashCode);

  @override
  String toString() => 'TabRequest[text=$text, columnWithDescription=$columnWithDescription, requiredColums=$requiredColums]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.text != null) {
      json[r'text'] = this.text;
    } else {
      json[r'text'] = null;
    }
    if (this.columnWithDescription != null) {
      json[r'columnWithDescription'] = this.columnWithDescription;
    } else {
      json[r'columnWithDescription'] = null;
    }
    if (this.requiredColums != null) {
      json[r'requiredColums'] = this.requiredColums;
    } else {
      json[r'requiredColums'] = null;
    }
    return json;
  }

  /// Returns a new [TabRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TabRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TabRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "TabRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return TabRequest(
        text: mapValueOfType<String>(json, r'text'),
        columnWithDescription: PropertyInfo.mapFromJson(json[r'columnWithDescription']),
        requiredColums: json[r'requiredColums'] is Iterable
            ? (json[r'requiredColums'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<TabRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TabRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TabRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TabRequest> mapFromJson(dynamic json) {
    final map = <String, TabRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TabRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TabRequest-objects as value to a dart map
  static Map<String, List<TabRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TabRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TabRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

