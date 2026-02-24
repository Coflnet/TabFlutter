//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DialectApi {
  DialectApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Returns the list of fully approved samples (from validated table) including  transcription, uploader/validator emails, and bucket information. This  endpoint is protected by a single ephemeral token generated on server  startup. Provide the token via header 'X-Ephemeral-Token'.  To download audio, use the /api/dialect/approved-audio/{id} endpoint with the audioId and bucket.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] xEphemeralToken:
  Future<Response> approvedSamplesWithHttpInfo({ String? xEphemeralToken, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/approved-samples';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (xEphemeralToken != null) {
      headerParams[r'X-Ephemeral-Token'] = parameterToString(xEphemeralToken);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Returns the list of fully approved samples (from validated table) including  transcription, uploader/validator emails, and bucket information. This  endpoint is protected by a single ephemeral token generated on server  startup. Provide the token via header 'X-Ephemeral-Token'.  To download audio, use the /api/dialect/approved-audio/{id} endpoint with the audioId and bucket.
  ///
  /// Parameters:
  ///
  /// * [String] xEphemeralToken:
  Future<List<ApprovedSampleDto>?> approvedSamples({ String? xEphemeralToken, }) async {
    final response = await approvedSamplesWithHttpInfo( xEphemeralToken: xEphemeralToken, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ApprovedSampleDto>') as List)
        .cast<ApprovedSampleDto>()
        .toList(growable: false);

    }
    return null;
  }

  /// Clears the cached Wikipedia content for a specific zip code (for testing/debugging)
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] zipCode (required):
  Future<Response> clearWikipediaCacheWithHttpInfo(String zipCode,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/wikipedia-cache/{zipCode}'
      .replaceAll('{zipCode}', zipCode);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Clears the cached Wikipedia content for a specific zip code (for testing/debugging)
  ///
  /// Parameters:
  ///
  /// * [String] zipCode (required):
  Future<CacheClearResponse?> clearWikipediaCache(String zipCode,) async {
    final response = await clearWikipediaCacheWithHttpInfo(zipCode,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CacheClearResponse',) as CacheClearResponse;
    
    }
    return null;
  }

  /// Creates or updates a user's information including their zip code and settings.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [UserInfoRequest] userInfoRequest:
  ///   User info payload
  Future<Response> createOrUpdateUserInfoWithHttpInfo({ UserInfoRequest? userInfoRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/user-info';

    // ignore: prefer_final_locals
    Object? postBody = userInfoRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


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

  /// Creates or updates a user's information including their zip code and settings.
  ///
  /// Parameters:
  ///
  /// * [UserInfoRequest] userInfoRequest:
  ///   User info payload
  Future<void> createOrUpdateUserInfo({ UserInfoRequest? userInfoRequest, }) async {
    final response = await createOrUpdateUserInfoWithHttpInfo( userInfoRequest: userInfoRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Downloads an approved audio file by its ID and bucket. Protected by ephemeral token.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] audioId (required):
  ///   The audio file ID
  ///
  /// * [String] bucket:
  ///   The bucket name where the audio is stored
  ///
  /// * [String] xEphemeralToken:
  ///   Ephemeral token for authentication (header: X-Ephemeral-Token)
  Future<Response> downloadApprovedAudioWithHttpInfo(String audioId, { String? bucket, String? xEphemeralToken, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/approved-audio/{audioId}'
      .replaceAll('{audioId}', audioId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (bucket != null) {
      queryParams.addAll(_queryParams('', 'bucket', bucket));
    }

    if (xEphemeralToken != null) {
      headerParams[r'X-Ephemeral-Token'] = parameterToString(xEphemeralToken);
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Downloads an approved audio file by its ID and bucket. Protected by ephemeral token.
  ///
  /// Parameters:
  ///
  /// * [String] audioId (required):
  ///   The audio file ID
  ///
  /// * [String] bucket:
  ///   The bucket name where the audio is stored
  ///
  /// * [String] xEphemeralToken:
  ///   Ephemeral token for authentication (header: X-Ephemeral-Token)
  Future<void> downloadApprovedAudio(String audioId, { String? bucket, String? xEphemeralToken, }) async {
    final response = await downloadApprovedAudioWithHttpInfo(audioId,  bucket: bucket, xEphemeralToken: xEphemeralToken, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'GET /api/Dialect/audio/{audioId}' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] audioId (required):
  Future<Response> getAudioWithHttpInfo(String audioId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/audio/{audioId}'
      .replaceAll('{audioId}', audioId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] audioId (required):
  Future<void> getAudio(String audioId,) async {
    final response = await getAudioWithHttpInfo(audioId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Retrieves a specific complicated case by ID with audio content.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] caseId (required):
  ///   The ID of the complicated case
  Future<Response> getComplicatedCaseMetadataWithHttpInfo(String caseId,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/complicated-cases/{caseId}'
      .replaceAll('{caseId}', caseId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Retrieves a specific complicated case by ID with audio content.
  ///
  /// Parameters:
  ///
  /// * [String] caseId (required):
  ///   The ID of the complicated case
  Future<ComplicatedCaseMetadataDto?> getComplicatedCaseMetadata(String caseId,) async {
    final response = await getComplicatedCaseMetadataWithHttpInfo(caseId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ComplicatedCaseMetadataDto',) as ComplicatedCaseMetadataDto;
    
    }
    return null;
  }

  /// Retrieves complicated case metadata and attempts to load audio from both buckets.
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> getNextPendingComplicatedCaseWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/complicated-cases/next-pending';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Retrieves complicated case metadata and attempts to load audio from both buckets.
  Future<ComplicatedCaseMetadataDto?> getNextPendingComplicatedCase() async {
    final response = await getNextPendingComplicatedCaseWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ComplicatedCaseMetadataDto',) as ComplicatedCaseMetadataDto;
    
    }
    return null;
  }

  /// Gets the next sentence from Wikipedia articles about towns/villages in the region  associated with the user's zip code. Tracks reading progress to provide different  sentences each time. The user must have registered their zip code via the user-info endpoint first.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] email (required):
  ///   User's email address
  Future<Response> getWikipediaSentenceWithHttpInfo(String email,) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/wikipedia-sentence/{email}'
      .replaceAll('{email}', email);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Gets the next sentence from Wikipedia articles about towns/villages in the region  associated with the user's zip code. Tracks reading progress to provide different  sentences each time. The user must have registered their zip code via the user-info endpoint first.
  ///
  /// Parameters:
  ///
  /// * [String] email (required):
  ///   User's email address
  Future<WikipediaSentenceResponse?> getWikipediaSentence(String email,) async {
    final response = await getWikipediaSentenceWithHttpInfo(email,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'WikipediaSentenceResponse',) as WikipediaSentenceResponse;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /api/Dialect/next-unvalidated' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] email:
  Future<Response> nextUnvalidatedWithHttpInfo({ String? email, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/next-unvalidated';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (email != null) {
      queryParams.addAll(_queryParams('', 'email', email));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] email:
  Future<void> nextUnvalidated({ String? email, }) async {
    final response = await nextUnvalidatedWithHttpInfo( email: email, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Reports a complicated dialect case for further discussion.  Flags cases where words may not exist in standard language.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ReportComplicatedCaseRequest] reportComplicatedCaseRequest:
  ///   Report request containing dialect ID, reporter email, and optional notes
  Future<Response> reportComplicatedCaseWithHttpInfo({ ReportComplicatedCaseRequest? reportComplicatedCaseRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/report-complicated-case';

    // ignore: prefer_final_locals
    Object? postBody = reportComplicatedCaseRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


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

  /// Reports a complicated dialect case for further discussion.  Flags cases where words may not exist in standard language.
  ///
  /// Parameters:
  ///
  /// * [ReportComplicatedCaseRequest] reportComplicatedCaseRequest:
  ///   Report request containing dialect ID, reporter email, and optional notes
  Future<void> reportComplicatedCase({ ReportComplicatedCaseRequest? reportComplicatedCaseRequest, }) async {
    final response = await reportComplicatedCaseWithHttpInfo( reportComplicatedCaseRequest: reportComplicatedCaseRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/Dialect/report-error' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ErrorReportRequest] errorReportRequest:
  Future<Response> reportErrorWithHttpInfo({ ErrorReportRequest? errorReportRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/report-error';

    // ignore: prefer_final_locals
    Object? postBody = errorReportRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


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
  /// * [ErrorReportRequest] errorReportRequest:
  Future<void> reportError({ ErrorReportRequest? errorReportRequest, }) async {
    final response = await reportErrorWithHttpInfo( errorReportRequest: errorReportRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Updates a complicated case's status and/or notes.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] caseId (required):
  ///   The ID of the complicated case to update
  ///
  /// * [UpdateComplicatedCaseRequest] updateComplicatedCaseRequest:
  ///   Update request with new status and/or notes
  Future<Response> updateComplicatedCaseWithHttpInfo(String caseId, { UpdateComplicatedCaseRequest? updateComplicatedCaseRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/complicated-cases/{caseId}'
      .replaceAll('{caseId}', caseId);

    // ignore: prefer_final_locals
    Object? postBody = updateComplicatedCaseRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Updates a complicated case's status and/or notes.
  ///
  /// Parameters:
  ///
  /// * [String] caseId (required):
  ///   The ID of the complicated case to update
  ///
  /// * [UpdateComplicatedCaseRequest] updateComplicatedCaseRequest:
  ///   Update request with new status and/or notes
  Future<Object?> updateComplicatedCase(String caseId, { UpdateComplicatedCaseRequest? updateComplicatedCaseRequest, }) async {
    final response = await updateComplicatedCaseWithHttpInfo(caseId,  updateComplicatedCaseRequest: updateComplicatedCaseRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// Updates a user's settings for the provided email address.
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] email (required):
  ///   User email
  ///
  /// * [Map<String, String>] requestBody:
  ///   Settings map
  Future<Response> updateUserSettingsWithHttpInfo(String email, { Map<String, String>? requestBody, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/user-info/{email}/settings'
      .replaceAll('{email}', email);

    // ignore: prefer_final_locals
    Object? postBody = requestBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Updates a user's settings for the provided email address.
  ///
  /// Parameters:
  ///
  /// * [String] email (required):
  ///   User email
  ///
  /// * [Map<String, String>] requestBody:
  ///   Settings map
  Future<void> updateUserSettings(String email, { Map<String, String>? requestBody, }) async {
    final response = await updateUserSettingsWithHttpInfo(email,  requestBody: requestBody, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/Dialect/upload' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [UploadRequest] uploadRequest:
  Future<Response> uploadWithHttpInfo({ UploadRequest? uploadRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/upload';

    // ignore: prefer_final_locals
    Object? postBody = uploadRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


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
  /// * [UploadRequest] uploadRequest:
  Future<void> upload({ UploadRequest? uploadRequest, }) async {
    final response = await uploadWithHttpInfo( uploadRequest: uploadRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Performs an HTTP 'POST /api/Dialect/validate' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [ValidateRequest] validateRequest:
  Future<Response> validateWithHttpInfo({ ValidateRequest? validateRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/api/Dialect/validate';

    // ignore: prefer_final_locals
    Object? postBody = validateRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json', 'text/json', 'application/*+json'];


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
  /// * [ValidateRequest] validateRequest:
  Future<void> validate({ ValidateRequest? validateRequest, }) async {
    final response = await validateWithHttpInfo( validateRequest: validateRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
