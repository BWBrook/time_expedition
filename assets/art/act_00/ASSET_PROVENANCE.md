# Act 0 Art Provenance

All source plates in this directory were generated for Time Expedition on 10 July 2026 using OpenAI built-in ImageGen mode, then retained in this repository. The project claims no rights in H. G. Wells' public-domain concepts; these visual interpretations are original and intentionally avoid later adaptations.

Runtime derivatives are created only by `tools/process_art.sh` with ImageMagick `7.1.2-26 Q16-HDRI aarch64 702175ac4:20260621` and the repository-owned `tools/remove_chroma_key.py`. The helper requires Pillow `12.2.0`, pinned in `requirements-art.txt`, and is invoked with Python 3, border sampling, `--soft-matte`, `--transparent-threshold 12`, `--opaque-threshold 220`, and `--despill`.

## Workshop panorama

- Source: `source/workshop_master.png`
- Runtime: `workshop_background.png`
- Transformation: ImageMagick Lanczos resize to the authored `3200x720` runtime canvas. This preserves all eight approved horizontal anchors and the full walkable floor; the rejected centre-crop candidate discarded the floor and right-side composition.

### Prompt

```text
Use case: historical-scene
Asset type: original source plate for a 2D narrative adventure game background
Primary request: An original illustrated 1895 scientific workshop in Richmond, seen as one continuous clean side-on theatrical cross-section. It will be cropped into an ultra-wide 3200x720 panorama spanning three connected camera zones.
Scene/backdrop: left drafting desk with an open notebook; measuring drawers; a wall or mantel house clock; centre main bench with a small unfinished delicate experimental frame; tall rain-lit window; right optical bench with an empty prism stand, an empty tray where control levers will later appear, and incomplete rejected frames/failed apparatus. No loose prism and no loose control levers. No people.
Composition/framing: Design the source as a seamless panoramic frieze contained in the central horizontal band of a landscape canvas, with useful ceiling and floor margins for a severe ultra-wide crop. Keep every anchor fully visible and in this strict normalized left-to-right order: notebook 13%, measuring drawer 27%, house clock 38%, main model bench 50%, tall rain window 65%, empty prism stand 73%, empty lever tray 85%, failed apparatus 96%. Keep an uncluttered continuous walkable floor along the lower edge. Do not create separate panels, borders, repeated rooms, perspective cuts, or dividers.
Style/medium: painterly but precise animated scientific-plate illustration, readable silhouettes, restrained detail, modest depth layers, suitable as inspectable game art.
Lighting/mood: cool blue-grey rain light through tall windows balanced by restrained warm gas lamps.
Color palette: ivory paper and ceramics, dark neutral iron, oxidised green copper, cool glass, with brass and mahogany only as accents; varied and balanced, not one-note.
Constraints: no completed Time Machine; the centre frame is unfinished and delicate. No legible writing. No recognisable film, television, illustrated-edition, or game adaptation design. No steampunk excess. No text, labels, watermark, logo, or decorative border.
```

## Time Traveller

- Source: `source/time_traveller_master.png`
- Runtime: `time_traveller_strip.png`
- Transformation: exact source-width quarter crops `[0,443)`, `[443,887)`, `[887,1330)`, and `[1330,1774)`; green-key removal; individual trim and aspect-preserving `430x440` fit; each cell placed on a transparent `512x512` canvas with fixed 24px bottom padding before append.

### Prompt

```text
Use case: illustration-story
Asset type: four-frame character sprite-strip source plate for a 2D side-view adventure game
Primary request: An original unnamed late-Victorian scientist, lean adult man in shirtsleeves and a dark waistcoat, slightly disordered from concentrated workshop labour, intelligent and impatient rather than heroic.
Composition/framing: One horizontal strip containing exactly four equal-width cells in this exact left-to-right order: 1) neutral standing idle, 2) left foot forward walk, 3) right foot forward walk, 4) leaning forward to inspect a mechanism. Every cell shows the identical full-body character in strict side profile facing right, at identical proportions and scale, with feet on one perfectly level shared baseline. Keep each figure wholly inside its own quarter with at least 8% padding on every side; nothing crosses a cell boundary. No visible separators, panels, frames, labels, or shadows. Character should fill roughly 75% of each cell height.
Style/medium: crisp painterly scientific-plate game illustration with a clean readable silhouette and consistent line/brush treatment across all four poses.
Lighting/mood: soft neutral studio light, identical in every cell.
Scene/backdrop: perfectly flat solid #00FF00 chroma-key background for later removal. It must be one uniform color with no gradient, texture, floor plane, reflections, or lighting variation.
Constraints: do not use #00FF00 anywhere in the character. No cast shadow, contact shadow, extra objects, text, watermark, or logo. No resemblance to any film actor, film/television adaptation, existing game, or illustrated-edition Time Traveller. Exactly four figures, no extra limbs or duplicate accessories.
```

## Model workbench

- Source: `source/workbench_master.png`
- Runtime: `workbench_background.png`
- Transformation: near-lossless ImageMagick Lanczos resize to `1280x720`; the source aspect ratio is already 16:9.

### Prompt

```text
Use case: stylized-concept
Asset type: full-screen 16:9 work-surface background for an interactive assembly interface
Primary request: An original Victorian scientific workbench for assembling a small model Time Machine, viewed slightly from above on a dark neutral work surface. Show one engraved mounting plate with exactly three unmistakably different empty mounting regions arranged left to right: twin ivory guide-bar fitting, transparent crystalline prism fitting, paired control-lever fitting. None of the required components is installed.
Composition/framing: wide 16:9 composition. Keep the entire engraved plate in the central horizontal band with three clear equal visual zones and substantial negative space above each fitting for overlaid game controls. Fine coordinate marks and two restrained calibration scales beneath the plate. Place an instrument cloth and precise hand tools only around the outer edges. No hands.
Style/medium: painterly but precise scientific-instrument illustration, rigorous and plausible rather than ornate fantasy; strong readable hierarchy under UI.
Lighting/mood: cool glass highlights, ivory and oxidised-green accents, selective warm gas-lamp reflection.
Materials/textures: dark neutral bench, engraved nickel/brass mounting plate, worn cloth, precise steel tools.
Constraints: no metallic model frame, no ivory guides, no prism, and no control levers in the fittings. No chair, sled, completed machine, people, hands, text, labels, numbers, watermark, logo, or border. No recognisable film/television adaptation design and no steampunk excess.
```

## Model framework

- Source: `source/model_frame_master.png`
- Runtime: `model_frame.png`
- Transformation: magenta-key removal; trim; aspect-preserving `960x260` fit; transparent `1024x300` centre canvas.
- Semantic correction: accepted empty-socket magenta v2 source. The earlier model-frame concept was rejected because it did not preserve the required visibly empty right-side lever sockets.

### Prompt

```text
Use case: illustration-story
Asset type: transparent-cutout source plate for a 2D game workbench
Primary request: A completely bare original miniature Victorian experimental framework, side-on, awaiting three removable components. It must visibly contain exactly three EMPTY mounting zones from left to right: (1) two parallel empty sockets for ivory guide bars, with no bars present; (2) an empty polygonal cradle for a crystalline prism, with no glass present; (3) two small empty pivot sockets for control levers, with absolutely no lever arms or handles present.
Composition/framing: one long low horizontal frame, entire object centred, filling about 78% of width and 42% of height, generous padding, no cropping. Keep all members fine and readable.
Style/medium: precise painterly scientific-plate game illustration, plausible restrained engineering, thin nickel and restrained brass, crisp silhouette.
Scene/backdrop: perfectly flat uniform solid #FF00FF chroma-key background only. No gradient, texture, floor plane, reflection, shadow, or lighting variation.
Hard exclusions: NO tall rods, NO handles, NO lever arms, NO ivory bars, NO prism or glass, NO chair, NO sled, NO seat, NO wheels, NO ornate steampunk decoration, NO completed machine, NO people, hands, labels, text, watermark, logo, or border. The right mounting zone must be visibly empty except for two small pivot sockets. No resemblance to any film, television, illustrated-edition, or existing-game Time Machine.
```

## Item and UI icons

- Source: `source/icon_strip_master.png`
- Runtime: `ivory_guides.png`, `crystal_prism.png`, `control_levers.png`, `journal_icon.png`, `inventory_icon.png`
- Transformation: exact source-width fifth crops `[0,396)`, `[396,793)`, `[793,1189)`, `[1189,1586)`, and `[1586,1983)`; magenta-key removal; independent trim and aspect-preserving `200x200` fit; transparent `256x256` centre canvases. The processor removes raw-strip neighbour fragments after sizing with a journal mask cutoff of `x>=210` and a control-lever mask cutoff of `x>=205`; it then clears the detached journal sliver in `x=203..209`, `y=90..208`.

### Prompt

```text
Use case: illustration-story
Asset type: five-cell inventory and UI icon source strip for a 2D game
Primary request: Exactly five original Victorian scientific-adventure objects in one horizontal strip, in this exact left-to-right order: 1) twin ivory guide bars, 2) one transparent faceted crystalline prism, 3) paired miniature metal control levers with one clearly white lever handle, 4) one closed dark-green laboratory journal with no writing, 5) one compact dark leather instrument satchel.
Composition/framing: exactly five equal-width invisible cells across the image; each cell contains exactly one centred object or one paired component set as specified. Every object fully visible, no overlap, nothing crosses a cell boundary, consistent scale and about 62% of cell height, at least 10% padding. No visible dividers, frames, panels, labels, or shadows.
Style/medium: consistent crisp painterly scientific-plate game icons with clean readable silhouettes and identical soft neutral front lighting.
Scene/backdrop: perfectly flat uniform solid #FF00FF chroma-key background for later removal. No gradient, texture, floor plane, reflection, or lighting variation.
Constraints: do not use #FF00FF anywhere in the objects. No text, labels, letters, hands, cast shadow, contact shadow, watermark, logo, or border. No film/television adaptation resemblance. Exactly five cells and exactly the specified five icon subjects; no extras.
```

<!-- BEGIN GENERATED CHECKSUMS: tools/process_art.sh -->
## SHA-256 Checksums

### Source plates
3462969bf0f7f757f1f858e16b5f4ffc6b3b5852c75f2af08fb32f681fa3a2bb  assets/art/act_00/source/icon_strip_master.png
1410a5f0f51475d27c775803a0fc9aae35c606df458f2ce23ca6a9828cbb213b  assets/art/act_00/source/model_frame_master.png
bb743a43220132561dc3bed4fe9ebfdfb7dd6441ffd2e3b0cc43138a3407c826  assets/art/act_00/source/time_traveller_master.png
e35a69d6cb614e98e6cbd6869c9b3934d5be1e9a2411619c6564a40a2584fcce  assets/art/act_00/source/workbench_master.png
b524c6a4a09649e18dfd06d06fd4d2acc5cf015388deae09dfa95fb864cd5c82  assets/art/act_00/source/workshop_master.png
### Runtime assets

894b4cd3adea0553abda4fc27425f97e0423cbe0809713640f4874c2e92adc7e  assets/art/act_00/control_levers.png
560d681c2de94bdab9a71ba437d478e62a29e130e01e097cfb119beb6efb321a  assets/art/act_00/crystal_prism.png
f17453c61766428fc21357ced7b74e2b49d339cf7145b1168abe797e72ce4246  assets/art/act_00/inventory_icon.png
077a697d18224e9f3e8ffcb4dcf019a6c28ada76a81cf12dbe848000e42e0e18  assets/art/act_00/ivory_guides.png
14b7ecfd1219ef393891df013f409ce32fdefb8d66ed85716481651caa052c9d  assets/art/act_00/journal_icon.png
210a531765af83e6d6c8a1131c4455880fcc572eec0937c2966fb1ab363b9e13  assets/art/act_00/model_frame.png
1788e6fd26a6b644df4a6a61812c107cad5f0cb1f56c65becb33e8a7adfd556f  assets/art/act_00/time_traveller_strip.png
9f0f9d6b35e64445c31924f86e08392e69421985209c83299243b48b1da7ce51  assets/art/act_00/workbench_background.png
a51afc250b401f9b7ffc427dc66c233c2821037955c38887a0008cd1e02fb60d  assets/art/act_00/workshop_background.png
<!-- END GENERATED CHECKSUMS: tools/process_art.sh -->
