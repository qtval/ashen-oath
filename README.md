# The Ashen Oath

> A grim, choice-driven medieval narrative game where truth can be more dangerous than war.

**Status:** early playable prototype / pre-production  
**Engine:** Godot 4  
**Language:** GDScript  
**Target:** Android first, portrait orientation

## The game

*The Ashen Oath* is a mobile interactive graphic novel set eighty years after the collapse of an empire. The player follows flawed people caught between war, politics, loyalty, and survival. Decisions are not divided into good and evil: they alter trust, fear, secrets, alliances, survival, and later story paths.

The opening prototype follows Garren Vale, a former military interrogator returning from a failed border war with a sealed letter. At a rain-soaked checkpoint, a deserter claims Garren's regiment was deliberately sacrificed. Helping him may expose the conspiracy; abandoning him may be the only safe choice.

The project draws inspiration from morally complex, multi-perspective grim fantasy while keeping its world, characters, dialogue, and plot original.

## Prototype features

- Portrait mobile story interface
- JSON-driven branching narrative
- Seventeen story nodes and five short endings
- Four approaches to the opening confrontation
- Hidden traits, relationship values, flags, and delayed consequences
- Automatic local saving and restart
- Environment-first artwork placeholders

## Visual direction

Every story beat will use a separate, hand-drawn black-and-white panel. Compositions emphasize roads, settlements, interiors, weather, architecture, and the traces of war. Characters appear at a distance, from behind, or in silhouette so the player's imagination completes them. Dialogue and interface text remain separate from the artwork.

Artwork files will live in `assets/artwork/`. See [the art direction guide](docs/ART_DIRECTION.md) before contributing panels.

## Run the prototype

1. Install Godot 4.3 or newer.
2. Import `project.godot` in the Godot Project Manager.
3. Press **Run Project**.

On Android, the official Godot editor can import and run the project directly. A future release will provide a normal installable APK.

## Development workflow

1. Choose one small outcome from `docs/ROADMAP.md`.
2. Ask Codex to implement and validate it in this repository.
3. Run the project in Godot and test the changed behavior.
4. Commit the working result to GitHub.

### Updating the project on Windows

After Codex publishes new changes, close Godot (or save your work), then double-click `Update-Ashen-Oath.cmd` in the project folder. It downloads the latest version from GitHub and stops safely if you have local changes that could be overwritten. Reopen the project in Godot and press **Run Project** after the update.

The updater requires Git, which is normally installed alongside GitHub CLI.

Validate all chapter links and required fields with:

```text
python tools/validate_story.py
```

See `AGENTS.md` for persistent project rules and `docs/ARCHITECTURE.md` for system boundaries.

## Repository layout

```text
assets/artwork/       Separate monochrome story panels
data/chapters/        Branching narrative content in JSON
docs/                 Design and contribution guidance
scenes/               Godot interface scenes
scripts/              Story, state, and save logic
project.godot         Godot project configuration
```

## Roadmap

- [x] Establish the game concept, tone, protagonists, and visual direction
- [x] Build a reusable portrait story reader
- [x] Create the branching checkpoint prototype
- [x] Add hidden state and local saving
- [ ] Produce consistent environment-first artwork for every story node
- [ ] Expand Chapter One to a polished 20–30 minute vertical slice
- [ ] Add dialogue polish, sound, music, transitions, and accessibility settings
- [ ] Test across common Android screen sizes
- [ ] Export and distribute an Android APK
- [ ] Introduce Elianor Vey and Oren “the Hollow” in later chapters

## Rights and contributions

The current repository uses a temporary **All Rights Reserved** notice while the project is being defined. The recommended long-term approach is an MIT license for original code and a separate proprietary license for narrative and art assets. Contributions are not open yet.

## Content note

The intended game contains mature themes including war, coercion, betrayal, and implied violence. The prototype contains no graphic artwork.
