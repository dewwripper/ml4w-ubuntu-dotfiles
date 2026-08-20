# Quickstart & Verification Guide: Ubuntu 26.04 Compatibility

**Feature**: `002-ubuntu-2604-compatibility`
**Date**: 2026-08-20

## Scenario 1: Dry-Run on Ubuntu 26.04

```bash
./install.sh --dry-run
```
**Expected Outcome**:
- Identifies `OS_ID: ubuntu`, `OS_VERSION_ID: 26.04`
- Demonstrates resilient package mapping and PPA probing without failures
- Returns exit code `0`

## Scenario 2: Container Verification on Ubuntu 26.04 / Devel

```bash
docker run --rm -v "$(pwd):/repo" -w /repo ubuntu:devel bash -c "
  apt-get update && apt-get install -y sudo curl git ca-certificates
  ./install.sh --noconfirm --dry-run
"
```
**Expected Outcome**:
- Executes cleanly in Ubuntu 26.04/devel container environment
- Passes package probe and exits with code `0`
