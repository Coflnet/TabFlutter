//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ErrorReportRequest {
  /// Returns a new [ErrorReportRequest] instance.
  ErrorReportRequest({
    required this.deviceId,
    this.appVersion,
    this.state,
    this.log,
    this.message,
    this.timestamp,
  });

  String? deviceId;

  String? appVersion;

  String? state;

  String? log;

  String? message;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? timestamp;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ErrorReportRequest &&
    other.deviceId == deviceId &&
    other.appVersion == appVersion &&
    other.state == state &&
    other.log == log &&
    other.message == message &&
    other.timestamp == timestamp;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId == null ? 0 : deviceId!.hashCode) +
    (appVersion == null ? 0 : appVersion!.hashCode) +
    (state == null ? 0 : state!.hashCode) +
    (log == null ? 0 : log!.hashCode) +
    (message == null ? 0 : message!.hashCode) +
    (timestamp == null ? 0 : timestamp!.hashCode);

  @override
  String toString() => 'ErrorReportRequest[deviceId=$deviceId, appVersion=$appVersion, state=$state, log=$log, message=$message, timestamp=$timestamp]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.deviceId != null) {
      json[r'deviceId'] = this.deviceId;
    } else {
      json[r'deviceId'] = null;
    }
    if (this.appVersion != null) {
      json[r'appVersion'] = this.appVersion;
    } else {
      json[r'appVersion'] = null;
    }
    if (this.state != null) {
      json[r'state'] = this.state;
    } else {
      json[r'state'] = null;
    }
    if (this.log != null) {
      json[r'log'] = this.log;
    } else {
      json[r'log'] = null;
    }
    if (this.message != null) {
      json[r'message'] = this.message;
    } else {
      json[r'message'] = null;
    }
    if (this.timestamp != null) {
      json[r'timestamp'] = this.timestamp!.toUtc().toIso8601String();
    } else {
      json[r'timestamp'] = null;
    }
    return json;
  }

  /// Returns a new [ErrorReportRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ErrorReportRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ErrorReportRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ErrorReportRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ErrorReportRequest(
        deviceId: mapValueOfType<String>(json, r'deviceId'),
        appVersion: mapValueOfType<String>(json, r'appVersion'),
        state: mapValueOfType<String>(json, r'state'),
        log: mapValueOfType<String>(json, r'log'),
        message: mapValueOfType<String>(json, r'message'),
        timestamp: mapDateTime(json, r'timestamp', r''),
      );
    }
    return null;
  }

  static List<ErrorReportRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ErrorReportRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ErrorReportRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ErrorReportRequest> mapFromJson(dynamic json) {
    final map = <String, ErrorReportRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ErrorReportRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ErrorReportRequest-objects as value to a dart map
  static Map<String, List<ErrorReportRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ErrorReportRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ErrorReportRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
  };
}

