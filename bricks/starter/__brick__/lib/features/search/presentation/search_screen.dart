import 'package:flutter/material.dart';
import 'package:{{package_name}}/core/i18n/generated/strings.g.dart';
import 'package:{{package_name}}/core/widgets/app_text_field.dart';
import 'package:{{package_name}}/core/widgets/screen_shell.dart';

class SearchScreen extends StatefulWidget {
  static const route = '/search';

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenShell(
        title: t.search.title,
        description: t.search.description,
        child: Column(
          children: [
            AppTextField(
              controller: _controller,
              label: t.search.inputLabel,
            ),
            const SizedBox(height: 24),
            Text(t.search.emptyState),
          ],
        ),
      ),
    );
  }
}
