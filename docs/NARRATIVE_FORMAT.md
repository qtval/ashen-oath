# Narrative data format

Each chapter is a UTF-8 JSON document with a chapter title and a `nodes` array.

## Node

Required fields:

- `id`: stable, unique snake-case identifier
- `text`: narration or dialogue shown to the player
- `choices`: array, empty only for endings

Common optional fields:

- `speaker`: visible speaker name
- `panel_description`: artwork brief or temporary panel copy
- `ending`: ending title; ending nodes must have no choices

## Choice

Required fields:

- `text`: player-facing choice text
- `next`: ID of an existing node

Optional fields:

- `effects`: state changes applied after selection
- `requires`: exact state values required for visibility

Numeric effects add to the existing value. Other effects replace the stored flag value.

## Compatibility rules

- Do not reuse a deleted ID for a different narrative event.
- Do not rename IDs after a release without save migration.
- Every non-ending node needs at least one choice.
- Every choice target must exist.
- Every node must be reachable from the chapter start unless it is explicitly marked as development-only in a future schema revision.
- Mechanical values remain hidden from player-facing choice text unless the design intentionally exposes them.
