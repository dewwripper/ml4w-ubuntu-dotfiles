# Data Model: Ubuntu 26.04 Compatibility & Package Refactoring

**Feature**: `002-ubuntu-2604-compatibility`
**Date**: 2026-08-20

## Extended Entities

### 1. Extended OS Profile
Enhanced representation of host system metadata derived from `/etc/os-release`.

| Attribute | Type | Description | Example Values |
|---|---|---|---|
| `os_id` | String | Value of `ID` | `ubuntu`, `debian`, `arch`, `fedora` |
| `os_id_like` | String | Value of `ID_LIKE` | `debian`, `ubuntu debian` |
| `os_version_id` | String | Value of `VERSION_ID` | `26.04`, `24.04` |
| `os_codename` | String | Value of `VERSION_CODENAME` | `resolute`, `noble`, `devel` |
| `os_version_major` | Integer | Numerical major version | `26`, `24` |
| `os_family` | Enum | Canonical distribution family | `DEBIAN`, `ARCH`, `FEDORA`, `SUSE`, `UNKNOWN` |

### 2. PPA Verification Model

| Attribute | Type | Description |
|---|---|---|
| `ppa_uri` | String | Identifier / URI for PPA (e.g. `ppa:hyprland-community/hyprland`) |
| `supported_codenames`| Array<String> | Known working codenames or dynamically probed HTTP 200 response |
| `status` | Enum | `COMPATIBLE`, `UNAVAILABLE_SUITE`, `SKIPPED` |
| `fallback_action` | Enum | `USE_GITHUB_RELEASE_BIN`, `USE_SOURCE_BUILD`, `FAIL` |
