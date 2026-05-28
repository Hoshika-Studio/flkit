import 'package:flutter/material.dart';
{{#use_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/use_riverpod}}
import 'package:go_router/go_router.dart';
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';
import 'package:{{package_name}}/core/widgets/app_button.dart';
import 'package:{{package_name}}/core/widgets/app_text_field.dart';
import 'package:{{package_name}}/features/auth/application/auth_controller.dart';
import 'package:{{package_name}}/features/auth/presentation/register_screen.dart';

{{#use_riverpod}}
class LoginScreen extends ConsumerStatefulWidget {
{{/use_riverpod}}
{{^use_riverpod}}
class LoginScreen extends StatefulWidget {
{{/use_riverpod}}
  static const route = '/login';

  const LoginScreen({super.key});

  @override
{{#use_riverpod}}
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
{{/use_riverpod}}
{{^use_riverpod}}
  State<LoginScreen> createState() => _LoginScreenState();
{{/use_riverpod}}
}

{{#use_riverpod}}
class _LoginScreenState extends ConsumerState<LoginScreen> {
{{/use_riverpod}}
{{^use_riverpod}}
class _LoginScreenState extends State<LoginScreen> {
{{/use_riverpod}}
  final _emailController = TextEditingController(text: 'hello@flkit.dev');
  final _passwordController = TextEditingController(text: 'password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
{{#use_riverpod}}
    final authState = ref.watch(authControllerProvider);

    return _LoginView(
      emailController: _emailController,
      passwordController: _passwordController,
      isLoading: authState.isLoading,
      error: authState.error,
      onSubmit: () => ref.read(authControllerProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      ),
    );
{{/use_riverpod}}
{{^use_riverpod}}
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        return _LoginView(
          emailController: _emailController,
          passwordController: _passwordController,
          isLoading: authController.isLoading,
          error: authController.error,
          onSubmit: () => authController.login(
            _emailController.text,
            _passwordController.text,
          ),
        );
      },
    );
{{/use_riverpod}}
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final Object? error;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.auth.login.title, style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.login.subtitle,
                    style: textTheme.bodyMedium?.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: emailController,
                    label: t.auth.fields.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: passwordController,
                    label: t.auth.fields.password,
                    obscureText: true,
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      t.auth.errors.generic,
                      style: textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    label: t.auth.login.action,
                    isLoading: isLoading,
                    onPressed: () => onSubmit(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(RegisterScreen.route),
                      child: Text(t.auth.login.goToRegister),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
