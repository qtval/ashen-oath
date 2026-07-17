# Codex project guidance

## Product target

The Ashen Oath is a portrait-first Android narrative game built with Godot 4 and GDScript. Keep desktop play useful for development, but judge interface decisions against touch use and narrow mobile screens.

## Working agreement

1. Read `docs/ROADMAP.md` before beginning feature work.
2. Keep `main` playable. Use a short-lived `agent/<description>` branch for substantial changes.
3. Keep story content in `data/`; do not hard-code chapter prose or branches into UI scripts.
4. Treat story node IDs and saved-state keys as persistent API. Do not rename or remove them without a migration plan.
5. Run `python tools/validate_story.py` after changing narrative JSON.
6. Run Godot headlessly when it is available. A human visual/touch test is still required for UI changes.
7. Update `CHANGELOG.md` and the active milestone when user-visible behavior changes.
8. Never commit signing keys, tokens, passwords, store credentials, or private user data.

## Architecture boundaries

- UI presents state but does not own narrative rules.
- Narrative data describes nodes, choices, conditions, and effects.
- Persistence owns serialization and save-version compatibility.
- Assets are referenced by stable repository paths.
- New systems must solve a current milestone need; avoid speculative frameworks.

## Definition of done

A change is done when its behavior is implemented, relevant validators pass, failure states are handled, documentation is current, and the user has clear Godot test steps. UI work additionally requires a portrait-layout check.
