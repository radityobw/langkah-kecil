# Security Policy

## Supported Versions

| Version | Supported |
| :--- | :--- |
| `1.1.x` | Yes |
| `< 1.1.0` | No (please upgrade to `1.1.0` or newer) |

---

## Reporting a Vulnerability

Please **do not** open public GitHub issues for security vulnerabilities, keystore leaks, or unsafe asset issues.

1. Use **GitHub Private Vulnerability Reporting** under the repository's **Security** tab (`Security -> Advisories -> Report a vulnerability`), or
2. Contact the maintainer directly at **`radityobudiw@gmail.com`**.

We aim to acknowledge reports within **48 hours** and coordinate remediation before public disclosure.

---

## Automated Checks

Every push and pull request targeting `main` runs:

- `tools/validate_project.py` (ensuring `export_presets.cfg` contains no keystore passwords or unsafe absolute export paths).
- **SIDIK** offline SAST & secret scanning (`--fail-on high`).
- Godot 4.5 headless import and scene/script smoke tests.
