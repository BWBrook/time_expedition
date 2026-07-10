# Time Expedition

Time Expedition is an open-source 2D narrative adventure built in Godot. Act 0, "The Model", is an original prologue to H. G. Wells' *The Time Machine*: the Time Traveller finishes and first tests the model machine shortly before his dinner guests arrive.

## Requirements

- Godot `4.7.stable.official.5b4e0cb0f`
- Python 3 with Pillow `12.2.0`, installed from `requirements-art.txt`
- ImageMagick 7 for deterministic raster-art regeneration
- POSIX shell tools: `sh`, `git`, `find`, `sort`, `cmp`, `mktemp`, `grep`, `sed`, `awk`, `shasum`, and `identify`
- Perl for the bounded Godot boot checks in `scripts/verify.sh`

## Run

```bash
godot --path .
```

## Controls

- Move: `A`/`D` or left/right arrows
- Interact or advance: `E`, `Space`, or `Enter`
- Journal: `J`
- Inventory: `I`
- Pause and reduced-motion option: `Escape`
- Workbench: mouse drag/drop or keyboard focus and confirm

## Verify

```bash
scripts/verify.sh
```

The verification script regenerates deterministic art, audio, and content; imports the project; checks bounded main and workshop boots; runs every headless test; and confirms generated outputs are unchanged with no untracked generated files.

Capture a visual QA set outside the repository with:

```bash
scripts/capture-qa.sh --viewport=1280x720 --output=/private/tmp/time-expedition-qa/1280x720
```

## Sources and licences

- Code: MIT, see `LICENSE`
- Original narrative, art, and audio: CC BY 4.0, see `CONTENT_LICENSE.md`
- Wells and edition provenance: `docs/sources.md`
- Generated art provenance: `assets/art/act_00/ASSET_PROVENANCE.md`
