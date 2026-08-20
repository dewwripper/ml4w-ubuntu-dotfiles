# Implementation Plan: Ubuntu 26.04 Compatibility & Refactoring

**Branch**: `002-ubuntu-2604-compatibility` | **Date**: 2026-08-20 | **Spec**: [spec.md](file:///Users/deww/Repos/per/ml4w-ubuntu-dotfiles/specs/002-ubuntu-2604-compatibility/spec.md)

**Input**: Feature specification from `specs/002-ubuntu-2604-compatibility/spec.md`

## Summary

Refactor the OS detection and Ubuntu packaging subsystem to support Ubuntu 26.04 LTS alongside Ubuntu 24.04 LTS and upstream distributions (Arch, Fedora, openSUSE). Implement codename and version parsing in `install/os-detect.sh`, resilient PPA probing with graceful binary fallback routing in `install/distros/ubuntu.sh`, expanded Qt6 runtime libraries for Quickshell, and automated Docker testing for Ubuntu 26.04.

## Technical Context

**Language/Version**: POSIX Shell (`bash` 5.x, `zsh` 5.x)
**Primary Dependencies**: `apt-get`, `dpkg`, Qt6 runtime libraries, `curl`, `tar`, `rsync`, `sudo`
**Testing**: Containerized test runner (`ubuntu:26.04` / `ubuntu:devel` Docker), dry-run CLI test
**Target Platform**: Ubuntu 26.04 LTS+, Ubuntu 24.04 LTS, Debian 12+, Arch, Fedora, openSUSE
**Project Type**: Shell scripts & Desktop configuration installer
**Constraints**: 100% backward compatibility; zero PPA 404 hard crashes on newer Ubuntu releases

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle / Gate | Compliance Status | Rationale |
|---|---|---|
| **I. Multi-Distro Support & Idempotency** | **PASS** | Enhanced `/etc/os-release` parser supporting 26.04; idempotent package installations. |
| **II. Native APT & PPA / Fallback Logic** | **PASS** | Native 26.04 APT prioritized; PPAs verified before addition with fallback to GitHub release binaries. |
| **III. No Breakage of Existing Distros** | **PASS** | Ubuntu 24.04, Arch, Fedora, and openSUSE retain exact previous behavior. |
| **IV. Clean Uninstall & Safe Backup** | **PASS** | Pre-install backup preserved across all releases. |

## Project Structure

### Documentation (this feature)
```text
specs/002-ubuntu-2604-compatibility/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── installer-interface.md
└── checklists/
    └── requirements.md
```

### Source Code
```text
ml4w-ubuntu-dotfiles/
├── install.sh                                # Top-level entry point
├── install/
│   ├── os-detect.sh                          # Enhanced OS & Codename detection (26.04 support)
│   ├── distros/
│   │   └── ubuntu.sh                         # Resilient APT package list & safe PPA probe
│   └── fallbacks/
│       ├── quickshell.sh                     # Quickshell runtime deployer
│       └── tools.sh                          # Binary fallbacks
└── tests/
    ├── Dockerfile.ubuntu2604                 # 26.04 Test container definition
    └── test-ubuntu2604-container.sh          # 26.04 Test execution harness
```

**Structure Decision**: Refactor existing `install/os-detect.sh` and `install/distros/ubuntu.sh` to handle 26.04 natively, adding dedicated 26.04 test containers.

## Complexity Tracking

> **No Constitution violations. Complexity score: Low.**
