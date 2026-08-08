# Changelog — PyroSync Clinical Workspace

All notable changes to the **PyroSync Clinical Workspace** platform developed by **Pyromatics Bio Solutions** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v1.0.0-HARDENED] - 2026-08-08

### Added & Configured
- **Android APK Build Environment (`android/app/build.gradle` & `AndroidManifest.xml`)**:
  - Configured Android package `com.pyromatics.pyrosync` targeting SDK 34 (Android 14) with Min SDK 21.
  - Added permissions for Bluetooth Low Energy, Bluetooth Scan/Connect, and Location for real hardware discovery.
  - Specified exact output path for release APK: `build/app/outputs/flutter-apk/app-release.apk`.
