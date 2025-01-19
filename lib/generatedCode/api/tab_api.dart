//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class TabApi {
  TabApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/Tab' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [TabRequest] tabRequest:
  Future<Response> postWithHttpInfo({
    TabRequest? tabRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Tab';

    // ignore: prefer_final_locals
    Object? postBody = tabRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[
      'application/json',
      'text/json',
      'application/*+json'
    ];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [TabRequest] tabRequest:
  Future<List<Map<String, String>>?> post({
    TabRequest? tabRequest,
  }) async {
    final response = await postWithHttpInfo(
      tabRequest: tabRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(
              responseBody, 'List<Map<String, String>>') as List)
          .cast<Map<String, String>>()
          .toList(growable: false);
    }
    return null;
  }

  /// Performs an HTTP 'POST /api/Tab/recognize' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [RecognitionRequest] recognitionRequest:
  Future<Response> recognizeWithHttpInfo({
    RecognitionRequest? recognitionRequest,
  }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Tab/recognize';

    // ignore: prefer_final_locals
    Object? postBody = recognitionRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[
      'application/json',
      'text/json',
      'application/*+json'
    ];

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [RecognitionRequest] recognitionRequest:
  Future<RecognitionResponse?> recognize({
    RecognitionRequest? recognitionRequest,
  }) async {
    final response = await recognizeWithHttpInfo(
      recognitionRequest: recognitionRequest,
    );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(
        await _decodeBodyBytes(response),
        'RecognitionResponse',
      ) as RecognitionResponse;
    }
    return null;
  }
}
