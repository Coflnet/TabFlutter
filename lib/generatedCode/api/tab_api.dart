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
  Future<List<Map<String, Object>>?> post({TabRequest? tabRequest}) async {
    final response = await postWithHttpInfo(tabRequest: tabRequest);

    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }

    // When the server returns a 204 status or no content, return null
    if (response.body.isNotEmpty &&
        response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);

      try {
        final List<dynamic> decodedJson =
            jsonDecode(responseBody) as List<dynamic>;

        final List<Map<String, Object>> typedResponse = decodedJson
            .map((item) => Map<String, Object>.from(item as Map))
            .toList(growable: false);

        return typedResponse;
      } catch (e) {
        // Catch any deserialization issues
        throw ApiException(500, 'Deserialization error: $e');
      }
    }

    return null;
  }
}
