//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ImportApi {
  ImportApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /api/Import/generateExcel/{count}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] count (required):
  Future<Response> generatedSurverysAsExcelWithHttpInfo(String count,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Import/generateExcel/{count}'
      .replaceAll('{count}', count);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


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
  /// * [String] count (required):
  Future<List<SurveryResult>?> generatedSurverysAsExcel(String count,) async {
    final response = await generatedSurverysAsExcelWithHttpInfo(count,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SurveryResult>') as List)
        .cast<SurveryResult>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/Import/generate' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [int] count:
  Future<Response> getMoreSurverysWithHttpInfo({ int? count, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Import/generate';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (count != null) {
      queryParams.addAll(_queryParams('', 'count', count));
    }

    const contentTypes = <String>[];


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
  /// * [int] count:
  Future<List<SurveryResult>?> getMoreSurverys({ int? count, }) async {
    final response = await getMoreSurverysWithHttpInfo( count: count, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SurveryResult>') as List)
        .cast<SurveryResult>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'POST /api/Import' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [MultipartFile] file:
  Future<Response> uploadExcelImportWithHttpInfo({ MultipartFile? file, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Import';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['multipart/form-data'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(path));
    if (file != null) {
      hasFields = true;
      mp.fields[r'file'] = file.field;
      mp.files.add(file);
    }
    if (hasFields) {
      postBody = mp;
    }

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
  /// * [MultipartFile] file:
  Future<List<SurveryResult>?> uploadExcelImport({ MultipartFile? file, }) async {
    final response = await uploadExcelImportWithHttpInfo( file: file, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<SurveryResult>') as List)
        .cast<SurveryResult>()
        .toList(growable: false);

    }
    return null;
  }
}
