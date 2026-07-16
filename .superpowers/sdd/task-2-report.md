# Task 2 Report: Six-Candidate Content, Narrative, and Decoy Art

## Conclusion

PASS. Task 2 now provides six candidate items, eight journal entries, 60 nonblank observations, the exact fifteen rejection IDs, the exact eight diagnostic IDs, strict default-manifest validation, and three deterministic vector-derived decoy icons.

## Files and Commit

- Content: `tools/build_content.gd`, `game/content/act_00/act_00_manifest.tres`, `game/content/content_registry.gd`
- Art sources: `assets/art/act_00/source/brass_rails.svg`, `smoked_lens.svg`, `clockwork_escapement.svg`
- Runtime art and imports: the corresponding three `256x256` PNG and `.png.import` files
- Art pipeline: `tools/process_art.sh`, `assets/art/act_00/ASSET_PROVENANCE.md`
- Tests: `tests/test_content_registry.gd`, `tests/test_art_assets.gd`
- Report: `.superpowers/sdd/task-2-report.md`
- Commit: the single task commit containing this report, with subject `feat: add Act 0 candidates and richer content`; exact SHA is reported from `HEAD` after commit because a commit cannot contain its own final object ID.

## RED Evidence

Tests were changed before production code. The complete command
`godot --headless --path . --script res://tests/run_all.gd` exited `1` with
`TESTS FAILED: 50 of 1367 assertions`. Failures were the intended missing
candidate, journal, observation, strict-contract, source-vector, runtime-icon,
binding, provenance, and processor-rule assertions. There were no parse or
unrelated behavioral failures.

## Green and Deterministic Verification

- Final import: `godot --headless --editor --path . --quit` exited `0`.
- Content build: `godot --headless --path . --script res://tools/build_content.gd` exited `0` and wrote the canonical manifest.
- Full suite: `godot --headless --path . --script res://tests/run_all.gd` exited `0` with `TESTS PASSED: 1596 assertions`.
- Deterministic regeneration: art processing plus content rebuilding left all three new PNGs, provenance, and the manifest byte-identical, `5/5` surfaces.
- Final runtime PNG SHA-256: brass rails `4415792965a777e3b10622ccbecf26a80ac0dcc6cde030eeea1a3749ba525a7a`; smoked lens `16b4a1ccae3272fce7036b812404782f4e4e165fff64981632d350ad7f65f575`; clockwork escapement `127a255b4acfbbd1b7f233e49c905cba460e970dc6c71ea74741402e37aa0816`.
- Visual self-review confirmed transparent, legible gold-brass rails with mounting holes, charcoal glass in a nickel rim, and a brass escape wheel with steel anchor and pivot jewels.

## Narrative and Art Assumptions

- Existing progression IDs and the strong notebook phrase "The ink is scarcely dry" were preserved for current-suite and downstream compatibility; exact R2 state, rejection, and diagnostic IDs were added without aliases.
- Candidate descriptions expose physical properties without labelling any item correct or incorrect. Rejections name both item properties and fitting geometry. Every diagnostic explicitly names lateral field pull and temporal cadence.
- All prose is original, empirical, and adaptation-independent. No Wells quotation is claimed or imitated.
- The six future workbench token paths are tested as stable art contracts. Adding the three decoy token nodes remains Task 5 work and was intentionally not pulled into this scope.
- The three SVGs are original repository-owned vectors. Solid material colours were preferred over SVG gradients because the pinned ImageMagick SVG renderer flattened those gradients almost to black during visual review.

## Uncertainty and Escalation

No Task 2 blocker or material contract ambiguity remains. A pre-existing Task 1 source file, `tests/test_workshop_scene_contract.gd`, lacks a tracked Godot `.uid`; editor import recreates an untracked `.uid` and logs a warning. The byproduct was removed from this task footprint and does not affect the headless suite, but it should be resolved in a later integration task if clean editor imports are required. No escalation is otherwise justified; Task 3 can consume the exact IDs and content contract.
