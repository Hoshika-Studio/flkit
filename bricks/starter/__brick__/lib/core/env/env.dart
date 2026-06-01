import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract final class Env {
  const Env._();

  @EnviedField(varName: 'API_BASE_URL')
  static const String apiBaseUrl = _Env.apiBaseUrl;
}
