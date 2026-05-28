# flkit

flkit is a CLI tool to generate Flutter projects.

## Usage

```sh
flkit create sample_app --template=starter
```

Use `--platforms` for non-interactive platform selection:

```sh
flkit create sample_app --template=starter --platforms=mobile
flkit create sample_app --template=starter --platforms=mobile,web
flkit create sample_app --template=starter --platforms=android,ios,web
```

Supported groups are `mobile`, `desktop`, and `web`.
