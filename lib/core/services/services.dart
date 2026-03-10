import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

export 'toast_service.dart';

enum ServiceError {
  unknownError,
  unknownResponseError,
  clientError,
  serverError,
  timeoutError,
  socketError,
  authError,
}

abstract class Services {}

class OpenLinkService extends Services {
  Future<String?> openUrl({required String link}) async {
    debugPrint('Opening URL: $link');
    return null;
  }
}

class HttpServices extends Services {
  final String apiKey;

  HttpServices({required this.apiKey});

  Future postMethod(
    String url,
    var body, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    var bo = convert.jsonEncode(body);
    try {
      var data = await http
          .post(
            Uri.parse(url),
            body: bo,
            headers: <String, String>{
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json; charset=UTF-8',
            },
          )
          .timeout(timeout);
      debugPrint('[HTTP] ${data.statusCode} $url');
      debugPrint(
        '[HTTP] body: ${data.body.length > 300 ? '${data.body.substring(0, 300)}...' : data.body}',
      );
      if (data.statusCode == 200 || data.statusCode == 201) {
        return convert.jsonDecode(data.body);
      } else if (data.statusCode == 400 || data.statusCode == 404) {
        return ServiceError.clientError;
      } else if (data.statusCode == 403) {
        return ServiceError.authError;
      } else if (data.statusCode == 500) {
        return ServiceError.serverError;
      } else {
        return ServiceError.unknownResponseError;
      }
    } on TimeoutException catch (_) {
      debugPrint('[HTTP] Timeout: $url');
      return ServiceError.timeoutError;
    } on SocketException catch (e) {
      debugPrint('[HTTP] Socket error: $e');
      return ServiceError.socketError;
    } on Exception catch (e) {
      debugPrint('[HTTP] Exception: $e');
      return ServiceError.unknownError;
    }
  }

  Future<dynamic> postMultipart({
    required String url,
    required List<http.MultipartFile> files,
    required Map<String, String> fields,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.addAll(files);
      request.fields.addAll(fields);
      request.headers.addAll({'Authorization': 'Bearer $apiKey'});

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );
      var responseBody = await streamedResponse.stream.bytesToString();

      debugPrint('Status: ${streamedResponse.statusCode}');
      debugPrint('Response: $responseBody');

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return convert.jsonDecode(responseBody);
      } else {
        debugPrint('Error response: $responseBody');
        return ServiceError.unknownResponseError;
      }
    } on TimeoutException catch (_) {
      return ServiceError.timeoutError;
    } on SocketException catch (_) {
      return ServiceError.socketError;
    } on Exception catch (e) {
      debugPrint(e.toString());
      return ServiceError.unknownError;
    }
  }
}
