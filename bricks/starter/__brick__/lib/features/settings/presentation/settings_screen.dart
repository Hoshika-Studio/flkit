import 'package:flutter/material.dart';
{{#use_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/use_riverpod}}
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';
import 'package:{{package_name}}/core/widgets/screen_shell.dart';
import 'package:{{package_name}}/features/auth/application/auth_controller.dart';

{{#use_riverpod}}
class SettingsScreen extends ConsumerWidget {
{{/use_riverpod}}
{{^use_riverpod}}
class SettingsScreen extends StatelessWidget {
{{/use_riverpod}}
  static const route = '/settings';

  const SettingsScreen({super.key});

  @override
{{#use_riverpod}}
  Widget build(BuildContext context, WidgetRef ref) {
{{/use_riverpod}}
{{^use_riverpod}}
  Widget build(BuildContext context) {
{{/use_riverpod}}
    return Scaffold(
      body: ScreenShell(
        title: t.settings.title,
        description: t.settings.description,
        child: Column(
          children: [
            _SettingsTile(
              title: t.settings.account.title,
              description: t.settings.account.description,
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              title: t.settings.appearance.title,
              description: t.settings.appearance.description,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
{{#use_riverpod}}
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
{{/use_riverpod}}
{{^use_riverpod}}
                onPressed: () => authController.logout(),
{{/use_riverpod}}
                child: Text(t.settings.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
