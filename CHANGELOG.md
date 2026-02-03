# Changelog - NoDebuffNoLoot

All notable changes to this project will be documented in this file.

---

## [2.1.1] - 2026-02-02

### Added - v2.1.1

- **HUD Filter**: Added "Only My Assignments" option.
  - When enabled, hides all debuff icons from the HUD except those assigned to you.
  - Ideal for players who want to focus solely on their specific tasks.

---

## [2.1.0] - 2026-01-31

### Added - v2.1.0

- **Quick Wins**: Implemented "Quality of Life" improvement package.
- **Visual & Auditory Alerts**: Red screen flash and "Raid Warning" sound for critical missing debuffs (configurable).
- **Chat Logs**: Textual log in chat window when an assigned debuff is missed.
- **LDB Support**: Integration with LibDataBroker (Titan Panel, Minimap Button) as optional dependency.

### Changed - v2.1.0

- **Defaults**: Visual and chat alerts enabled by default.

---

## [2.0.4] - 2026-01-31

### Added - v2.0.4

- **Release Optimization**: Añadido archivo `.pkgmeta` para excluir automáticamente archivos de prueba, scripts de desarrollo y documentación interna de los paquetes de CurseForge.

---

## [2.0.3] - 2026-01-30

### Fixed - v2.0.3

- **CurseForge Integration**: Añadido Project ID para la subida automática.
- **Visuals**: Incluida imagen oficial de marca `logo.png`.

---

## [2.0.2] - 2026-01-30

### Added - v2.0.2

- **Public Beta**: Preparación para el lanzamiento en CurseForge y GitHub para pruebas comunitarias.
- **Documentation**: Actualizado el plan de pruebas para reflejar el estado actual.

---

## [2.0.1] - 2026-01-28

### Fixed - v2.0.1

- **Hotfix**: Solucionado error de Lua al ejecutar `/ndnl` causado por una función omitida en la v2.0.0.

---

## [2.0.0] - 2026-01-28

### Added - v2.0.0

- **Multi-Language Support**: Full implementation of `AceLocale-3.0` with initial support for English (`enUS`) and Spanish (`esES`/`esMX`).
- **Alert Optimization**: Redesigned warning system to avoid data contamination and ensure optimal performance.

### Changed - v2.0.0

- **Code Refactoring**: Improved file organization for easier future maintenance.
- **Automatic Sync**: The system now attempts to sync assignments immediately after editing them in the menu.

---

## [1.2.0] - 2026-01-28

### Added - v1.2.0

- Raid synchronization via `AceComm-3.0`.
- `/ndnlsync` chat command to force manual assignment synchronization.
- On-screen visual alerts (`UIErrorsFrame`) when a debuff assigned to the local player is missing.
- "Debuff about to expire" alerts (< 5 seconds).

---

## [1.1.0] - 2026-01-28

### Added - v1.1.0

- New configuration menu accessible via `/ndnl`.
- Direct player assignment system for debuffs from the UI.
- `/ndnl` chat command for easier access.
- Dynamic options loading based on the debuff database.

---

## [1.0.0] - 2026-01-28

### Added - v1.0.0

- Project initialization.
- Core structure creation (Core, Data, UI, Assignments).
- Critical TBC debuffs definition.
- Included Ace3 libraries for total addon independence.
- `.gitignore` configuration for internal file protection.
- Initial synchronization with GitHub.
