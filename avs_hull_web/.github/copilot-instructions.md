# Copilot Instructions for AVSHullWeb

## Project Overview
- **AVSHullWeb** is a Flutter web application for hull design and analysis.
- The codebase is organized by feature and responsibility: `lib/geometry` (math/geometry), `lib/models` (domain models), `lib/UI` (Flutter UI), `lib/IO` (file and export), and `lib/settings` (configuration).
- The main entry point is `lib/main.dart`.

## Architecture & Patterns
- **UI Layer**: All user interface code is in `lib/UI/`. Each major screen/dialog is a separate file (e.g., `design_screen.dart`, `export_offsets_dialog.dart`). Custom painters are used for hull and panel visualization.
- **Domain Models**: Core hull and panel logic is in `lib/models/` (e.g., `hull.dart`, `panel.dart`). These are plain Dart classes with methods for geometry and state.
- **Geometry/Math**: All geometric calculations are in `lib/geometry/` (e.g., `hull_math.dart`, `point_3d.dart`, `spline.dart`).
- **IO**: File operations and export logic are in `lib/IO/`.
- **Settings**: App configuration and persistent settings are in `lib/settings/settings.dart`.

## Developer Workflows
- **Build for Web**: Use the VS Code task `Flutter build web` or run `flutter build web` in the terminal. Output is in `build/web/`.
- **Run Locally**: Use `flutter run -d chrome` to launch the app in a browser.
- **Dependencies**: Managed via `pubspec.yaml`. Run `flutter pub get` after editing dependencies.
- **No explicit test suite**: No test/ directory or test tasks are present.

## Project-Specific Conventions
- **File Naming**: Lowercase with underscores, grouped by feature.
- **UI/Logic Separation**: UI code in `lib/UI/` should not contain business logic; delegate to models or geometry classes.
- **Export/Import**: All file IO and export logic is centralized in `lib/IO/`.
- **Settings**: Use `settings.dart` for app-wide configuration.

## Integration Points
- **Flutter Web**: Uses standard Flutter web build and asset pipeline.
- **No backend/server**: All logic is client-side.
- **Assets**: Static assets (icons, shaders, etc.) are in `web/` and `build/flutter_assets/`.

## Examples
- To add a new hull calculation, extend or add a class in `lib/geometry/` and update relevant models in `lib/models/`.
- To add a new UI dialog, create a new widget in `lib/UI/` and connect it via the appropriate screen.

## Key Files
- `lib/main.dart`: App entry point
- `lib/UI/design_screen.dart`: Main design UI
- `lib/models/hull.dart`: Core hull logic
- `lib/geometry/hull_math.dart`: Hull geometry calculations
- `lib/IO/export_offsets.dart`: Export logic
- `lib/settings/settings.dart`: App settings

---
For more details, see the code in each directory. If conventions or structure are unclear, ask for clarification or review related files for patterns.
