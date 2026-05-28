import 'package:flutter_test/flutter_test.dart';
{{#use_riverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
{{/use_riverpod}}
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/main.dart';

void main() {
  testWidgets('starts on onboarding', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
{{#use_riverpod}}
        child: const ProviderScope(child: App()),
{{/use_riverpod}}
{{^use_riverpod}}
        child: const App(),
{{/use_riverpod}}
      ),
    );

    expect(find.text(t.onboarding.title), findsOneWidget);
  });
}
