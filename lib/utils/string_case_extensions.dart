extension StringCaseExtensions on String {
  String toSnakeCase() {
    return trim()
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)}_${match.group(2)}',
        )
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String toPascalCase() {
    return split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join();
  }

  String toCamelCase() {
    final pascal = toPascalCase();
    if (pascal.isEmpty) return pascal;

    return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
  }

  String toDisplayName() {
    return split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String toRoutePath() {
    return '/${toSnakeCase().replaceAll('_', '-')}';
  }
}
