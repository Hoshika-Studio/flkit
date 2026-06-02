# FLKit Example

Create a Flutter app with the starter template:

```sh
flkit create sample_app --template=starter
```

Create the same app non-interactively:

```sh
flkit create sample_app \
  --template=starter \
  --bundle-id=com.example.app \
  --platforms=mobile
```

After generation:

```sh
cd sample_app
dart run build_runner build --delete-conflicting-outputs
flutter run
```
