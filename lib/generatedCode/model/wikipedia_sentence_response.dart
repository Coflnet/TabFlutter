//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class WikipediaSentenceResponse {
  /// Returns a new [WikipediaSentenceResponse] instance.
  WikipediaSentenceResponse({
    this.sentence,
    this.locations = const [],
    this.zipCode,
    this.progress,
  });

  /// The selected sentence
  String? sentence;

  /// List of nearby village/town names used to build the region
  List<String>? locations;

  /// Zip code used to determine the region
  String? zipCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ProgressDto? progress;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WikipediaSentenceResponse &&
    other.sentence == sentence &&
    _deepEquality.equals(other.locations, locations) &&
    other.zipCode == zipCode &&
    other.progress == progress;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (sentence == null ? 0 : sentence!.hashCode) +
    (locations == null ? 0 : locations!.hashCode) +
    (zipCode == null ? 0 : zipCode!.hashCode) +
    (progress == null ? 0 : progress!.hashCode);

  @override
  String toString() => 'WikipediaSentenceResponse[sentence=$sentence, locations=$locations, zipCode=$zipCode, progress=$progress]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.sentence != null) {
      json[r'sentence'] = this.sentence;
    } else {
      json[r'sentence'] = null;
    }
    if (this.locations != null) {
      json[r'locations'] = this.locations;
    } else {
      json[r'locations'] = null;
    }
    if (this.zipCode != null) {
      json[r'zipCode'] = this.zipCode;
    } else {
      json[r'zipCode'] = null;
    }
    if (this.progress != null) {
      json[r'progress'] = this.progress;
    } else {
      json[r'progress'] = null;
    }
    return json;
  }

  /// Returns a new [WikipediaSentenceResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WikipediaSentenceResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WikipediaSentenceResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "WikipediaSentenceResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return WikipediaSentenceResponse(
        sentence: mapValueOfType<String>(json, r'sentence'),
        locations: json[r'locations'] is Iterable
            ? (json[r'locations'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        zipCode: mapValueOfType<String>(json, r'zipCode'),
        progress: ProgressDto.fromJson(json[r'progress']),
      );
    }
    return null;
  }

  static List<WikipediaSentenceResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WikipediaSentenceResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WikipediaSentenceResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WikipediaSentenceResponse> mapFromJson(dynamic json) {
    final map = <String, WikipediaSentenceResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WikipediaSentenceResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WikipediaSentenceResponse-objects as value to a dart map
  static Map<String, List<WikipediaSentenceResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WikipediaSentenceResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WikipediaSentenceResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

