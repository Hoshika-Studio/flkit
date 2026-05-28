import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
{{#use_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/use_riverpod}}
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/router/app_router.dart';
import 'package:{{package_name}}/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();

  runApp(
    TranslationProvider(
{{#use_riverpod}}
      child: const ProviderScope(child: App()),
{{/use_riverpod}}
{{^use_riverpod}}
      child: const App(),
{{/use_riverpod}}
    ),
  );
}

{{#use_riverpod}}
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return _AppView(router: router);
  }
}
{{/use_riverpod}}
{{^use_riverpod}}
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return _AppView(router: _router);
  }
}
{{/use_riverpod}}

class _AppView extends StatelessWidget {
  const _AppView({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: t.core.app.title,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: const [...GlobalMaterialLocalizations.delegates],
      supportedLocales: AppLocaleUtils.supportedLocales,
    );
  }
}
