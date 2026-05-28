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
import 'package:{{package_name}}/features/auth/presentation/login_screen.dart';

{{#use_riverpod}}
class RegisterScreen extends ConsumerStatefulWidget {
{{/use_riverpod}}
{{^use_riverpod}}
class RegisterScreen extends StatefulWidget {
{{/use_riverpod}}
  static const route = '/register';

  const RegisterScreen({super.key});

  @override
{{#use_riverpod}}
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
{{/use_riverpod}}
{{^use_riverpod}}
  State<RegisterScreen> createState() => _RegisterScreenState();
{{/use_riverpod}}
}

{{#use_riverpod}}
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
{{/use_riverpod}}
{{^use_riverpod}}
class _RegisterScreenState extends State<RegisterScreen> {
{{/use_riverpod}}
  final _nameController = TextEditingController(text: 'Starter User');
  final _emailController = TextEditingController(text: 'hello@flkit.dev');
  final _passwordController = TextEditingController(text: 'password');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
{{#use_riverpod}}
    final authState = ref.watch(authControllerProvider);

    return _RegisterView(
      nameController: _nameController,
      emailController: _emailController,
      passwordController: _passwordController,
      isLoading: authState.isLoading,
      error: authState.error,
      onSubmit: () => ref.read(authControllerProvider.notifier).register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      ),
    );
{{/use_riverpod}}
{{^use_riverpod}}
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        return _RegisterView(
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          isLoading: authController.isLoading,
          error: authController.error,
          onSubmit: () => authController.register(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
          ),
        );
      },
    );
{{/use_riverpod}}
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController nameController;
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
                  Text(t.auth.register.title, style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    t.auth.register.subtitle,
                    style: textTheme.bodyMedium?.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: nameController,
                    label: t.auth.fields.name,
                  ),
                  const SizedBox(height: 12),
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
                    label: t.auth.register.action,
                    isLoading: isLoading,
                    onPressed: () => onSubmit(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go(LoginScreen.route),
                      child: Text(t.auth.register.goToLogin),
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
