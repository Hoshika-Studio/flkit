import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';
import 'package:{{package_name}}/core/widgets/screen_shell.dart';

class FavoriteScreen extends StatelessWidget {
  static const route = '/favorite';

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: ScreenShell(
        title: t.favorite.title,
        description: t.favorite.description,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.heart, size: 44, color: colors.muted),
              const SizedBox(height: 16),
              Text(
                t.favorite.emptyState,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
