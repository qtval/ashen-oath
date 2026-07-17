# Architecture

## Goal

Maintain a small, data-driven mobile narrative game whose content can grow without coupling every chapter to Godot interface code.

## Runtime flow

```text
chapter JSON -> story reader -> game state -> save file
                     |
                     +-> portrait UI
```

The current prototype intentionally keeps this flow in one script. Split it only when Chapter One needs independent narrative, persistence, or UI behavior.

## Responsibilities

### Narrative data

`data/chapters/` contains stable node IDs, presented text, choices, requirements, effects, and endings. Content must pass `tools/validate_story.py`.

### Story reader

`scripts/story_reader.gd` loads narrative data, presents the current node, applies choice effects, and displays recoverable project errors. It is the prototype orchestration layer, not the permanent home of every future system.

### Game state

State currently contains `flags` and numeric `stats`. Keys are part of save compatibility. Future character relationships should use namespaced keys or dedicated records rather than loosely multiplying unrelated variables.

### Persistence

Saves live under Godot's `user://` location and include a numeric `version`. Any incompatible save-shape change must increment the version and either migrate old data or deliberately explain why a prototype reset is required.

### Interface

Godot `Control` containers own layout. Avoid fixed element positions. Interactive targets must remain comfortable on touchscreens and usable in portrait orientation.

## Dependency direction

UI may read narrative presentation and state. Narrative rules must not depend on particular buttons, labels, screen sizes, or artwork. Story JSON must not contain executable code.

## Planned extraction points

Extract these only when their complexity justifies it:

- `StoryManager`: loading, conditions, effects, and navigation
- `GameState`: typed state access and relationship rules
- `SaveManager`: migrations and multiple save slots
- `ArtworkPresenter`: panel loading and transitions

## Mobile constraints

- Primary viewport: 720 × 1280 logical pixels
- Portrait-first, responsive containers
- Touch targets approximately 48 logical pixels or larger
- No critical information conveyed by hover
- Back-button behavior must be explicitly designed before Android beta
- Large artwork should be compressed and tested on a mid-range Android device
