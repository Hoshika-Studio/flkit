# FLKit

FLKit is a small CLI for generating Flutter apps with a clean, feature-first
starter.

The goal is to remove the boring setup work when starting a new Flutter repo:
routing, translations, theme tokens, basic auth screens, navigation, and a
starter architecture that stays easy to grow.

## Features

- Feature-first Flutter starter.
- Mobile, desktop, and web platform selection.
- Slang i18n with English and French starter translations.
- GoRouter navigation with onboarding, auth, home, search, favorite, settings.
- Optional Riverpod Generator setup.
- Optional Dio API client setup.
- Envied setup for generated environment variables.
- Freezed and JSON Serializable dependencies ready for DTOs and models.
- Simple black and white Theme Tailor theme.
- Mock async auth flow with TODOs for backend calls.

## Install

For local development:

```sh
dart pub global activate --source path .
```

After FLKit is published on pub.dev:

```sh
dart pub global activate flkit
```

Check the installed version:

```sh
flkit --version
```

## Usage

Create a project with the starter template:

```sh
flkit create sample_app --template=starter
```

The starter template asks for a bundle id and uses the default FLKit stack.

Create a project with the custom flow:

```sh
flkit create sample_app
```

The custom flow asks for:

- bundle id
- target platforms
- languages
- Riverpod Generator
- Dio

## Non-interactive Usage

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

## Generated Project

After generation, FLKit runs:

```sh
flutter pub get
dart run slang
```

For Riverpod and Theme Tailor code generation, run this in the generated project:

```sh
dart run build_runner build
```

The generated starter uses this layout:

```txt
lib/
  core/
    i18n/
    env/
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

## Roadmap

- `flkit add feature <name>` to generate feature folders and i18n files.
- More starter templates.
- More language presets.
- JSON/non-interactive output for AI and automation workflows.

## License

MIT
