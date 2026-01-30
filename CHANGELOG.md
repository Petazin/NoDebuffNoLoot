# Changelog - NoDebuffNoLoot

## [2.0.3] - 2026-01-30
### Fixed
- **CurseForge Integration**: Añadido Project ID para la subida automática.
- **Visuals**: Incluida imagen oficial de marca `logo.png`.

## [2.0.2] - 2026-01-30
### Added
- **Public Beta**: Preparación para el lanzamiento en CurseForge y GitHub para pruebas comunitarias.
- **Documentation**: Actualizado el plan de pruebas para reflejar el estado actual.

## [2.0.1] - 2026-01-28
### Fixed
- **Hotfix**: Solucionado error de Lua al ejecutar `/ndnl` causado por una función omitida en la v2.0.0.

## [2.0.0] - 2026-01-28
### Added
- **Multi-Language Support**: Full implementation of `AceLocale-3.0` with initial support for English (`enUS`) and Spanish (`esES`/`esMX`).
- **Alert Optimization**: Redesigned warning system to avoid data contamination and ensure optimal performance.

### Changed
- **Code Refactoring**: Improved file organization for easier future maintenance.
- **Automatic Sync**: The system now attempts to sync assignments immediately after editing them in the menu.

## [1.2.0] - 2026-01-28
### Added
- Raid synchronization via `AceComm-3.0`.
- `/ndnlsync` chat command to force manual assignment synchronization.
- On-screen visual alerts (`UIErrorsFrame`) when a debuff assigned to the local player is missing.
- "Debuff about to expire" alerts (< 5 seconds).

## [1.1.0] - 2026-01-28
### Added
- New configuration menu accessible via `/ndnl`.
- Direct player assignment system for debuffs from the UI.
- `/ndnl` chat command for easier access.
- Dynamic options loading based on the debuff database.

## [1.0.0] - 2026-01-28
### Added
- Project initialization.
- Core structure creation (Core, Data, UI, Assignments).
- Critical TBC debuffs definition.
- Included Ace3 libraries for total addon independence.
- `.gitignore` configuration for internal file protection.
- Initial synchronization with GitHub.
