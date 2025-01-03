//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MapingResult {
  /// Returns a new [MapingResult] instance.
  MapingResult({
    this.brandOccurences = const {},
    this.unmappable = const [],
  });

  Map<String, List<MapElement>>? brandOccurences;

  List<MapElement>? unmappable;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MapingResult &&
    _deepEquality.equals(other.brandOccurences, brandOccurences) &&
    _deepEquality.equals(other.unmappable, unmappable);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (brandOccurences == null ? 0 : brandOccurences!.hashCode) +
    (unmappable == null ? 0 : unmappable!.hashCode);

  @override
  String toString() => 'MapingResult[brandOccurences=$brandOccurences, unmappable=$unmappable]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.brandOccurences != null) {
      json[r'brandOccurences'] = this.brandOccurences;
    } else {
      json[r'brandOccurences'] = null;
    }
    if (this.unmappable != null) {
      json[r'unmappable'] = this.unmappable;
    } else {
      json[r'unmappable'] = null;
    }
    return json;
  }

  /// Returns a new [MapingResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MapingResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MapingResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MapingResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MapingResult(
        brandOccurences: json[r'brandOccurences'] == null
          ? const {}
            : MapElement.mapListFromJson(json[r'brandOccurences']),
        unmappable: MapElement.listFromJson(json[r'unmappable']),
      );
    }
    return null;
  }

  static List<MapingResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MapingResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MapingResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MapingResult> mapFromJson(dynamic json) {
    final map = <String, MapingResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MapingResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MapingResult-objects as value to a dart map
  static Map<String, List<MapingResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MapingResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MapingResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

