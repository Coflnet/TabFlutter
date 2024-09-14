//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MappingResult2 {
  /// Returns a new [MappingResult2] instance.
  MappingResult2({
    this.brands = const [],
    this.noChangeNecessary = const [],
    this.mapped = const [],
    this.unmappable = const [],
  });

  List<String>? brands;

  List<String>? noChangeNecessary;

  List<MappingElement>? mapped;

  List<UnMappable>? unmappable;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MappingResult2 &&
    _deepEquality.equals(other.brands, brands) &&
    _deepEquality.equals(other.noChangeNecessary, noChangeNecessary) &&
    _deepEquality.equals(other.mapped, mapped) &&
    _deepEquality.equals(other.unmappable, unmappable);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (brands == null ? 0 : brands!.hashCode) +
    (noChangeNecessary == null ? 0 : noChangeNecessary!.hashCode) +
    (mapped == null ? 0 : mapped!.hashCode) +
    (unmappable == null ? 0 : unmappable!.hashCode);

  @override
  String toString() => 'MappingResult2[brands=$brands, noChangeNecessary=$noChangeNecessary, mapped=$mapped, unmappable=$unmappable]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.brands != null) {
      json[r'brands'] = this.brands;
    } else {
      json[r'brands'] = null;
    }
    if (this.noChangeNecessary != null) {
      json[r'noChangeNecessary'] = this.noChangeNecessary;
    } else {
      json[r'noChangeNecessary'] = null;
    }
    if (this.mapped != null) {
      json[r'mapped'] = this.mapped;
    } else {
      json[r'mapped'] = null;
    }
    if (this.unmappable != null) {
      json[r'unmappable'] = this.unmappable;
    } else {
      json[r'unmappable'] = null;
    }
    return json;
  }

  /// Returns a new [MappingResult2] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MappingResult2? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MappingResult2[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MappingResult2[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MappingResult2(
        brands: json[r'brands'] is Iterable
            ? (json[r'brands'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        noChangeNecessary: json[r'noChangeNecessary'] is Iterable
            ? (json[r'noChangeNecessary'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        mapped: MappingElement.listFromJson(json[r'mapped']),
        unmappable: UnMappable.listFromJson(json[r'unmappable']),
      );
    }
    return null;
  }

  static List<MappingResult2> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MappingResult2>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MappingResult2.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MappingResult2> mapFromJson(dynamic json) {
    final map = <String, MappingResult2>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MappingResult2.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MappingResult2-objects as value to a dart map
  static Map<String, List<MappingResult2>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MappingResult2>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MappingResult2.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

