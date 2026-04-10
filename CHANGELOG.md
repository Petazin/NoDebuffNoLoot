# Changelog - NoDebuffNoLoot

All notable changes to this project will be documented in this file.

---

## [2.4.1] - 2026-04-01

### Fixed - v2.4.1
- **Assignment Blank Issue (Expose Armor)**: Corrected a bug where assigning "Improved Expose Armor" caused the assignment field to clear instantly. The database mistakenly pointed to the passive talent (Spell ID 26866) instead of the active debuff ability (Spell ID 8647), preventing the localized name lookup from working.
- **Spell ID Database Audit**: Performed a full review of all spell IDs in the central `Data.lua` registry. Corrected multiple entries that were mistakenly pointing to passive talents, low ranks, or unrelated quest IDs instead of the active debuff applied to enemies:
  - **Winter's Chill**: Updated from passive talent (28593) to debuff aura (12579).
  - **Judgement of Light**: Updated from quest ID (27163) to unranked debuff aura (20185).
  - **Judgement of Wisdom**: Updated from quest ID (27164) to unranked debuff aura (20186).
  - **Curse of Recklessness**: Updated from creature ID (27226) to Rank 5 debuff (27223).
  - **Curse of Weakness**: Updated from creature ID (27224) to Rank 8 debuff (30909).
  - **Demoralizing Roar**: Updated from quest ID (26998) to Rank 6 debuff (8983).
  - **Screech (Hunter Pet)**: Updated from Rank 4 (27050) to Rank 5 debuff (31480).
- **Improved Smart Validation**: Tuned `SmartSelection.lua` to properly prioritize the strictest assignment validation (Talent Requirement) when multiple dictionary spells share the same ability ID (e.g. baseline Expose Armor vs. Improved Expose Armor).
## [2.4.0] - 2026-03-31

### Added - v2.4.0
- **Smart Overwrite (Warrior/Rogue)**: Sunder Armor will now be silently satisfied and hidden from missing alerts if Expose Armor (or Improved) is applied, preventing Warrior frustration.
- **Smart Suggest**: The Leader's assignment dropdown menu now filters in real-time, prioritizing or hiding basic versions of spells if a valid player with an Improved Talent version is found in the group.

### Fixed - v2.4.0
- **Faerie Fire ID**: Corrected an erroneous spell ID for Faerie Fire that was causing the Rebirth icon to display instead of the correct purple moon icon.

---

## [2.3.5] - 2026-03-25

### Fixed - v2.3.5
- **Range-Based Sync Control**: Restricted transmission and reception of assignments to Group Leaders and Assistants only, preventing unauthorized configuration changes from other group members.

## [2.3.4] - 2026-03-24
- **SmartSelection Bugfix**: Resolved `attempt to index global 'L' (a nil value)` in `SmartSelection.lua` by ensuring proper local localization scope.

## [2.3.3] - 2026-03-24
- **UI & Localization Polish**: Expanded main panel width (720px) to prevent text clipping and added auto-localization for spell names in suggestion menus.

## [2.3.2] - 2026-03-23
- **EasyMenu Fix**: Replaced deprecated `EasyMenu` with a native `Dropdown` implementation to avoid nil global errors.

## [2.3.1] - 2026-03-23
- **Talent Inspection Fix**: Resolved `bad argument #2` in `GetTalentInfo` and cleaned up duplicate entries in the debuff database.

## [2.3.0] - 2026-03-23

### Added - v2.3.0
- **Assignment Intelligence (TBC Focus)**:
    - **Talent Scanner**: Automatic detection of critical specializations (Shadow Weaving, Improved Scorch, etc.) via raid inspection.
    - **Dynamic Filtering**: Suggested debuff list now adapts automatically based on classes and talents found in the group.
    - **Safety Validation**: Visual alert icons warning of incorrect class/talent assignments.
    - **Smart UI**: New contextual menus for rapid selection of spells and players.

---

## [2.2.0] - 2026-03-09

### Added - v2.2.0

- **Custom ConfigUI**: Completely brand new, dynamic assignment panel with 3 configurable columns (Spell, Primary, Backup) and priority re-ordering via Drag-and-Drop/Up-Down buttons.
- **Raid Announcements**: New "Announce to Raid" button added to the assignments panel. It sends a `RAID_WARNING` with the full list and simultaneously sends private `WHISPER`s to assigned players (requires Raid Leader/Assistant privileges to prevent spam).
- **Advanced HUD States**: HUD now has 3 clear visual states:
  - **IDLE** (Gray): Waiting for a valid target.
  - **PENDING** (Yellow): Target acquired but waiting for the combat grace period to expire.
  - **MISSING/ACTIVE** (Red Glow / Green): Active tracking during combat.
- **Per-Debuff Grace Period**: Replaced global combat delay with a customizable `Delay` column per assignment, allowing specific grace seconds before triggering missing alerts.
- **Advanced Filters**: Added "Show Only Missing" and "Only on Bosses" (Skull Level) options to reduce HUD clutter.
- **Full Localization**: The entire UI is now fully localized and translates automatically to English (`enUS`) or Spanish (`esES`) based on the game client.
- **Minimap Integration**: Added `Shift-Click` on the minimap icon to open the Assignments panel instantly.

### Changed - v2.2.0

- **Data Structure**: Breaking change. Assignments are now saved as an ordered array `[1] = {spellId, primary, backup}` to support priority levels, wiping the old dictionary configuration.
- Removed all dependencies and visual references to Method Raid Tools (MRT).

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
