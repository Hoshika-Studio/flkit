# FLKit

FLKit is a small CLI for creating Flutter apps with a clean, feature-first
starter. It removes the repetitive setup work around routing, translations,
theme tokens, environment variables, auth screens, navigation, and the first
project structure.

The package is published on pub.dev as `hoshika_flkit`, and it installs the
`flkit` command.

## Features

- Feature-first Flutter starter.
- Starter and custom creation flows.
- Feature generation with `flkit add feature <name>`.
- Agent-readable starter with `AGENTS.md` and `flkit.yaml`.
- Mobile, desktop, and web platform selection.
- Slang i18n with English and French starter translations.
- Feature-local translation files.
- GoRouter navigation with onboarding, auth, home, search, favorite, settings.
- Optional Riverpod Generator setup.
- Optional Dio API client setup.
- Envied setup for generated environment variables.
- Freezed and JSON Serializable dependencies ready for DTOs and models.
- Simple black and white Theme Tailor theme.
- Mock async auth flow with TODOs for backend calls.

## Install

Activate FLKit from pub.dev:

```sh
dart pub global activate hoshika_flkit
```

Check that the command is available:

```sh
flkit --version
```

## Usage

Create a Flutter app with the default starter:

```sh
flkit create sample_app --template=starter
```

The starter template only asks for a bundle id and uses the default FLKit stack.

Create a Flutter app with the custom flow:

```sh
flkit create sample_app
```

The custom flow asks for:

- bundle id
- target platforms
- languages
- Riverpod Generator
- Dio

## Non-Interactive Usage

You can pass flags for scripts, CI, or AI agents:

```sh
flkit create sample_app \
  --template=starter \
  --bundle-id=com.example.app \
  --platforms=mobile
```

Platform groups:

```sh
flkit create sample_app --template=starter --platforms=mobile
flkit create sample_app --template=starter --platforms=desktop
flkit create sample_app --template=starter --platforms=web
flkit create sample_app --template=starter --platforms=mobile,web
```

Flutter platforms are also supported:

```sh
flkit create sample_app --template=starter --platforms=android,ios,web
```

## Add A Feature

Inside a FLKit-generated project, add a feature folder:

```sh
flkit add feature notifications
```

This creates:

```txt
lib/features/notifications/
  application/
  data/
  domain/
  i18n/
  presentation/
```

It also creates a starter screen and i18n files for the detected project languages.

Use explicit languages for scripts or AI agents:

```sh
flkit add feature notifications --languages=en,fr
```

Skip Slang generation if you want to run it yourself later:

```sh
flkit add feature notifications --no-run-slang
```

## Generated Project

After generation, FLKit runs:

```sh
flutter pub get
dart run slang
```

Then run the remaining code generation commands in the generated project:

```sh
cd sample_app
dart run slang
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The generated starter uses this layout:

```txt
lib/
  core/
    env/
    i18n/
    network/
    router/
    theme/
    widgets/
  features/
    auth/
    favorite/
    home/
    onboarding/
    search/
    settings/
```

Feature translations live next to their feature:

```txt
lib/features/auth/i18n/auth_en.i18n.json
lib/features/auth/i18n/auth_fr.i18n.json
```

Shared translations stay in:

```txt
lib/core/i18n/
```

Environment values are generated from `.env` with Envied:

```txt
.env.example
lib/core/env/env.dart
```

FLKit also adds `.env` patterns to the generated `.gitignore`.

Generated projects include:

```txt
AGENTS.md
flkit.yaml
```

`AGENTS.md` gives AI agents and contributors project instructions. `flkit.yaml`
records the generated stack, architecture, tools, locales, and conventions.

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## License

MIT
