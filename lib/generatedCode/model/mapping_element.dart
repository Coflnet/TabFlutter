//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MappingElement {
  /// Returns a new [MappingElement] instance.
  MappingElement({
    this.inputBrand,
    this.inputProduct,
    this.output,
  });

  String? inputBrand;

  String? inputProduct;

  String? output;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MappingElement &&
    other.inputBrand == inputBrand &&
    other.inputProduct == inputProduct &&
    other.output == output;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (inputBrand == null ? 0 : inputBrand!.hashCode) +
    (inputProduct == null ? 0 : inputProduct!.hashCode) +
    (output == null ? 0 : output!.hashCode);

  @override
  String toString() => 'MappingElement[inputBrand=$inputBrand, inputProduct=$inputProduct, output=$output]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.inputBrand != null) {
      json[r'inputBrand'] = this.inputBrand;
    } else {
      json[r'inputBrand'] = null;
    }
    if (this.inputProduct != null) {
      json[r'inputProduct'] = this.inputProduct;
    } else {
      json[r'inputProduct'] = null;
    }
    if (this.output != null) {
      json[r'output'] = this.output;
    } else {
      json[r'output'] = null;
    }
    return json;
  }

  /// Returns a new [MappingElement] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MappingElement? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MappingElement[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MappingElement[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MappingElement(
        inputBrand: mapValueOfType<String>(json, r'inputBrand'),
        inputProduct: mapValueOfType<String>(json, r'inputProduct'),
        output: mapValueOfType<String>(json, r'output'),
      );
    }
    return null;
  }

  static List<MappingElement> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MappingElement>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MappingElement.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MappingElement> mapFromJson(dynamic json) {
    final map = <String, MappingElement>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MappingElement.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MappingElement-objects as value to a dart map
  static Map<String, List<MappingElement>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MappingElement>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MappingElement.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

