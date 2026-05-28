{{#use_riverpod}}
import 'package:riverpod_annotation/riverpod_annotation.dart';
{{/use_riverpod}}
{{^use_riverpod}}
import 'package:flutter/foundation.dart';
{{/use_riverpod}}
import 'package:{{package_name}}/features/auth/domain/auth_user.dart';

{{#use_riverpod}}
part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  Future<AuthUser?> build() async => null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      // TODO: Replace this mock with a backend call through Dio.
      return AuthUser(id: 'local-user', email: email, name: 'Starter User');
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      // TODO: Replace this mock with a backend call through Dio.
      return AuthUser(id: 'local-user', email: email, name: name);
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    state = const AsyncData(null);
  }
}
{{/use_riverpod}}
{{^use_riverpod}}
final authController = AuthController();

class AuthController extends ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = false;
  Object? _error;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> login(String email, String password) async {
    await _runAuthTask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      // TODO: Replace this mock with a backend call through Dio.
      _user = AuthUser(id: 'local-user', email: email, name: 'Starter User');
    });
  }

  Future<void> register(String name, String email, String password) async {
    await _runAuthTask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      // TODO: Replace this mock with a backend call through Dio.
      _user = AuthUser(id: 'local-user', email: email, name: name);
    });
  }

  Future<void> logout() async {
    await _runAuthTask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _user = null;
    });
  }

  Future<void> _runAuthTask(Future<void> Function() task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await task();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
{{/use_riverpod}}
