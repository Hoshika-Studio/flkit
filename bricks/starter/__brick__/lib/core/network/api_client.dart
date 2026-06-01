{{#use_dio}}
import 'package:dio/dio.dart';
import 'package:{{package_name}}/core/env/env.dart';
{{#use_riverpod}}
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}
{{/use_riverpod}}
{{^use_riverpod}}
Dio createDio() {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
}

final dio = createDio();
{{/use_riverpod}}
{{/use_dio}}
{{^use_dio}}
// Add your API client here when the project needs network calls.
{{/use_dio}}
