import 'package:flutter/material.dart';
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';
import 'package:{{package_name}}/core/widgets/screen_shell.dart';

class HomeScreen extends StatelessWidget {
  static const route = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        title: t.home.title,
        description: t.home.description,
        child: Column(
          children: [
            _StarterCard(
              title: t.home.cards.first.title,
              description: t.home.cards.first.description,
            ),
            const SizedBox(height: 12),
            _StarterCard(
              title: t.home.cards.second.title,
              description: t.home.cards.second.description,
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  const _StarterCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
