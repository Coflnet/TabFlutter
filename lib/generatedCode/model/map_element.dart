//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MapElement {
  /// Returns a new [MapElement] instance.
  MapElement({
    this.brand,
    this.product,
    this.occuredTimes,
    this.by,
  });

  String? brand;

  String? product;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? occuredTimes;

  String? by;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MapElement &&
    other.brand == brand &&
    other.product == product &&
    other.occuredTimes == occuredTimes &&
    other.by == by;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (brand == null ? 0 : brand!.hashCode) +
    (product == null ? 0 : product!.hashCode) +
    (occuredTimes == null ? 0 : occuredTimes!.hashCode) +
    (by == null ? 0 : by!.hashCode);

  @override
  String toString() => 'MapElement[brand=$brand, product=$product, occuredTimes=$occuredTimes, by=$by]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.brand != null) {
      json[r'brand'] = this.brand;
    } else {
      json[r'brand'] = null;
    }
    if (this.product != null) {
      json[r'product'] = this.product;
    } else {
      json[r'product'] = null;
    }
    if (this.occuredTimes != null) {
      json[r'occuredTimes'] = this.occuredTimes;
    } else {
      json[r'occuredTimes'] = null;
    }
    if (this.by != null) {
      json[r'by'] = this.by;
    } else {
      json[r'by'] = null;
    }
    return json;
  }

  /// Returns a new [MapElement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MapElement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MapElement[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MapElement[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MapElement(
        brand: mapValueOfType<String>(json, r'brand'),
        product: mapValueOfType<String>(json, r'product'),
        occuredTimes: mapValueOfType<int>(json, r'occuredTimes'),
        by: mapValueOfType<String>(json, r'by'),
      );
    }
    return null;
  }

  static List<MapElement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MapElement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MapElement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MapElement> mapFromJson(dynamic json) {
    final map = <String, MapElement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MapElement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MapElement-objects as value to a dart map
  static Map<String, List<MapElement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MapElement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MapElement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

