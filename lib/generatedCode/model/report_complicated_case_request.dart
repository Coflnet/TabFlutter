//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ReportComplicatedCaseRequest {
  /// Returns a new [ReportComplicatedCaseRequest] instance.
  ReportComplicatedCaseRequest({
    required this.dialectId,
    required this.reporterEmail,
    this.notes,
  });

  String dialectId;

  String? reporterEmail;

  String? notes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReportComplicatedCaseRequest &&
    other.dialectId == dialectId &&
    other.reporterEmail == reporterEmail &&
    other.notes == notes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (dialectId.hashCode) +
    (reporterEmail == null ? 0 : reporterEmail!.hashCode) +
    (notes == null ? 0 : notes!.hashCode);

  @override
  String toString() => 'ReportComplicatedCaseRequest[dialectId=$dialectId, reporterEmail=$reporterEmail, notes=$notes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'dialectId'] = this.dialectId;
    if (this.reporterEmail != null) {
      json[r'reporterEmail'] = this.reporterEmail;
    } else {
      json[r'reporterEmail'] = null;
    }
    if (this.notes != null) {
      json[r'notes'] = this.notes;
    } else {
      json[r'notes'] = null;
    }
    return json;
  }

  /// Returns a new [ReportComplicatedCaseRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ReportComplicatedCaseRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ReportComplicatedCaseRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ReportComplicatedCaseRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ReportComplicatedCaseRequest(
        dialectId: mapValueOfType<String>(json, r'dialectId')!,
        reporterEmail: mapValueOfType<String>(json, r'reporterEmail'),
        notes: mapValueOfType<String>(json, r'notes'),
      );
    }
    return null;
  }

  static List<ReportComplicatedCaseRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ReportComplicatedCaseRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ReportComplicatedCaseRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ReportComplicatedCaseRequest> mapFromJson(dynamic json) {
    final map = <String, ReportComplicatedCaseRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ReportComplicatedCaseRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ReportComplicatedCaseRequest-objects as value to a dart map
  static Map<String, List<ReportComplicatedCaseRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ReportComplicatedCaseRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ReportComplicatedCaseRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'dialectId',
    'reporterEmail',
  };
}

