import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';
import 'package:{{package_name}}/core/widgets/app_button.dart';
import 'package:{{package_name}}/features/auth/presentation/login_screen.dart';
import 'package:{{package_name}}/features/auth/presentation/register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  static const route = '/onboarding';

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.foreground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  color: colors.background,
                  size: 30,
                ),
              ),
              const SizedBox(height: 32),
              Text(t.onboarding.title, style: textTheme.headlineLarge),
              const SizedBox(height: 16),
              Text(
                t.onboarding.subtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.muted,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              AppButton(
                label: t.onboarding.primaryAction,
                onPressed: () => context.go(RegisterScreen.route),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go(LoginScreen.route),
                  child: Text(t.onboarding.secondaryAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
