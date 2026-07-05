Below is a discussion Barry had with GPT-5.5 about the development of the "Time Expedition" game.

## Barry
What's the copyright status for H.G. Wells' 1895 book The Time Machine?

## GPT-5.5
The Time Machine is in the public domain in essentially all jurisdictions, including Australia, the UK, the EU, and the United States.

The details vary slightly by country:

* Australia: Works by H. G. Wells entered the public domain on 1 January 2017, following Australia’s change to a life-plus-70-years copyright term. Wells died in 1946.
* United Kingdom and European Union: Public domain since 1 January 2017 (life + 70 years).
* United States: The 1895 edition has been in the public domain for many decades because all works first published in the US before 1928 are now in the public domain.

This means you are generally free to:

* reproduce the text;
* adapt or modernise it;
* create derivative works (including sequels, translations, or illustrated editions);
* distribute it commercially or non-commercially.

There are, however, two practical caveats:

1. Use an original public-domain text. Modern editions may contain copyrighted introductions, annotations, illustrations, or editorial revisions, even though Wells’ original text is free to use.
2. Choose the version carefully. The Time Machine has a somewhat complicated publication history. The novella first appeared in serial form in 1894–95 and was then published as a book in 1895, with Wells making revisions between versions. All of Wells’ own versions are now public domain, but they are not word-for-word identical.

For a clean source text, the editions available from Project Gutenberg or Standard Ebooks are excellent starting points. The latter, in particular, provides carefully proofread and modernised typography while preserving the original wording.

## Barry
So that means, for example, I could design a game system based on any part of that novel, and there would be no copyright implications.

## GPT-5.5
Yes. From a copyright perspective, you are on very solid ground.

Because The Time Machine is in the public domain, you can freely use:

* its plot and story structure;
* its characters, such as the Time Traveller, the Eloi, and the Morlocks;
* its settings and fictional concepts;
* its dialogue (from the original text);
* its terminology and descriptions.

That means you could create, for example:

* a role-playing game set in Wells’ future Earth;
* a strategy game about the Eloi–Morlock civilisation;
* an adventure game following (or reimagining) the Time Traveller’s journey;
* a board game or card game inspired directly by the novel;
* a modern sequel or alternative timeline.

The main things to avoid are material that belongs to later adaptations rather than Wells himself. For example:

* distinctive visual designs created for a particular film;
* original dialogue or scenes invented for a movie or television adaptation;
* music, logos, artwork, or other creative elements from those adaptations.

For instance, if you copied the appearance of the time machine from the 1960 film adaptation or the Morlocks as depicted in the 2002 film, those visual interpretations could still be protected even though Wells’ underlying ideas are not.

The underlying literary work, however, is entirely free to build upon. Copyright protects the particular expression created by later authors and artists, not the public-domain story itself.

This is why many developers use public-domain literature as a foundation. Works by authors such as Jules Verne, Arthur Conan Doyle (for most of the Sherlock Holmes canon), Edgar Allan Poe, and H. G. Wells provide rich worlds and characters that can be reused without licensing the original texts.

## Barry
What is the current cutoff year for public domain copyright works?

## GPT-5.5
It depends on the country, because copyright terms are based on different rules.

For your purposes in Australia:

* Australia (current in 2026): Any work by an author who died in 1955 or earlier is now in the public domain. Australia uses a life + 70 years term, with copyright expiring at the end of the 70th calendar year after the author’s death. Thus, works by authors who died in 1956 or later are still under copyright.

For comparison:

* United Kingdom / European Union: The same rule applies: authors who died in 1955 or earlier are now in the public domain.
* United States: The simplest rule for older published works is different. As of 1 January 2026, works published in 1930 or earlier are in the public domain, regardless of the author’s date of death. Every New Year’s Day, another publication year enters the public domain.

For someone interested in adapting classic literature into games, the practical “safe pool” is therefore enormous. It includes works by authors such as:

* H. G. Wells
* Jules Verne
* Arthur Conan Doyle (all of the Sherlock Holmes stories are now public domain worldwide)
* Edgar Allan Poe
* H. P. Lovecraft
* Bram Stoker
* Mary Shelley
* Robert Louis Stevenson
* Oscar Wilde

This gives you access to a vast range of characters, settings, and stories without needing to obtain licences, provided you work from the original public-domain texts rather than borrowing creative additions from later film, television, or illustrated adaptations.

## Barry
It would only be for open source projects that might be, as you say, an adventure game or an RPG skin or something like that. I just want to know whether, which authors' works I'm free to develop. I'm not actually looking to make a profit, even if it was feasible there. So that's good to know these rules.

## GPT-5.5
For open-source, non-commercial projects, the public domain is a particularly attractive space because you don’t need permission from anyone to use the original works. Even if you were to make money from such a project, copyright wouldn’t be the issue if the underlying work is genuinely in the public domain.

Given your interests in science fiction, speculative evolution, and history, there is a remarkable amount you can draw upon. Some particularly rich authors include:

* H. G. Wells – time travel, alien invasion, invisibility, uplift, speculative biology.
* Jules Verne – exploration, engineering, submarines, space travel.
* Robert E. Howard – sword and sorcery, Conan, Kull, Solomon Kane.
* H. P. Lovecraft – cosmic horror and an extensive mythos that is largely public domain (though a few later collaborators’ contributions require more care).
* Edgar Rice Burroughs – many early works, including the earliest Tarzan and John Carter stories, are public domain in Australia, although US publication dates and some trademarks make the picture more nuanced if distributing internationally.
* Olaf Stapledon – grand-scale future history and cosmic evolution.
* Arthur Conan Doyle – Sherlock Holmes and Professor Challenger.
* Edgar Allan Poe – mystery, horror, early detective fiction.
* Mary Shelley – Frankenstein.
* Bram Stoker – Dracula.
* William Hope Hodgson – maritime horror and The Night Land.

One thing I think is particularly interesting for your purposes is that copyright protects the expression, not the ideas. So if Wells describes a Morlock tunnel network or Howard describes the Hyborian kingdoms, you can use those settings directly because the original text is public domain. But you could also borrow the underlying concepts—evolutionary futures, lost civilisations, forgotten technologies—and develop them in completely new directions.

Since you mentioned RPGs and adventure games, another advantage is that many open-source engines pair well with public-domain source material. For example, an engine like Godot could host an adaptation of The Time Machine or a Conan-inspired RPG without any licensing friction from the literary source.

I also suspect we’re entering something of a renaissance for public-domain works. Every year, another cohort of twentieth-century authors enters the public domain. By the 2040s, writers such as John Wyndham will become available, opening up classics like The Day of the Triffids and The Chrysalids. For someone who enjoys both literature and software, the available palette is only going to expand over time.

## Barry
That's really interesting. I hadn't thought of building on an engine rather than creating something from scratch myself. And Godot could be a good example. Could you sketch out what something like an adventure game based on the Time Machine book might look like in the context of using Godot? High-level stuff here, I'm just brainstorming.

## GPT-5.5
Yes — The Time Machine would map very naturally onto Godot, especially as a compact 2D or 2.5D adventure rather than a huge RPG. The key is not to think “I must implement a whole game engine”, but “I’ll assemble reusable scenes, actors, inventory objects, dialogue, and time-state logic inside an existing engine”. Godot is especially congenial for that because its design is built around reusable nodes and scenes, with scripts attached to them; scenes can become reusable components such as a player, a chest, an NPC, a location, or a UI panel.  

The obvious form would be a narrative exploration adventure: part point-and-click, part light survival, part puzzle game. The player begins in the Victorian workshop, witnesses or reconstructs the framing dinner-party scene, prepares the machine, and then travels into the far future. The major locations could be relatively few but dense: the laboratory, the garden/ruins of 802,701 AD, the Eloi spaces above ground, the well-shafts and Morlock tunnels below, the Palace of Green Porcelain, and finally the bleak, far-future terminal landscape. Project Gutenberg summarises the original novella as a journey by a Victorian Time Traveller to the year 802,701, where humanity has diverged into the Eloi and Morlocks, which is exactly the kind of compact premise that suits a small adventure game.  

I would make the time machine itself the central interface, not just a plot device. It could sit as an interactable scene object with levers, gauges, date dials, cracked crystals, or mechanical components. Early on, the machine might only permit fixed jumps; later, after solving puzzles, you gain more control. Mechanically, this could allow the same location to exist in several “time layers”. The laboratory in 1895, its ruined footprint in 802,701, and its geological trace in the far future could all be versions of the same map. That is very Godot-friendly: each time period can be a separate scene, or one base scene with different tilemaps, props, NPCs, lighting, and collision layers toggled by a TimelineState.

A good small-game structure might look like this. Act I: The Demonstration is the tutorial: explore the Victorian house, examine notes, assemble or calibrate the machine, and learn inventory/dialogue mechanics. Act II: The Garden Future opens the world: meet the Eloi, discover the machine is missing, and infer that the apparent paradise is unstable. Act III: The Underworld shifts into stealth and resource management: light, fire, matches, lamps, and noise matter because the Morlocks dominate the dark. Act IV: The Green Porcelain Museum becomes the puzzle-box zone: recover tools, learn fragments of human decline, and decide what to carry into the tunnels. Act V: Escape and Deep Time is short, atmospheric, and existential: recover the machine, flee, and overshoot into increasingly desolate futures.

The core gameplay loop could be: explore a scene, collect observations/items, update the journal, unlock a time or location transition, then reinterpret previous evidence. That last part is important: the book is not really an action story in the modern sense. It is speculative anthropology, class allegory, evolutionary extrapolation, and uncanny travelogue. So I would lean into “understanding the system” rather than “defeating enemies”. The player gradually pieces together why the Eloi are helpless, why the Morlocks behave as they do, and how the apparent utopia is actually a degenerated socio-ecological system.

For Godot, I’d probably start with a 2D side-view or isometric 2D prototype, not full 3D. Godot has a dedicated 2D engine, pixel-coordinate 2D nodes, and a built-in tile map editor, which makes hand-crafted locations, ruins, tunnels, and museum rooms quite approachable.   A 3D version would be more atmospheric, but it would multiply the art burden. A 2D game can still be beautiful: silhouettes of ruined London, parallax vegetation, glowing subterranean eyes, and a huge red sun at the end of time.

The Godot project could be organised something like this conceptually:

/scenes
  /actors
    player.tscn
    eloi.tscn
    morlock.tscn
  /locations
    victorian_lab.tscn
    garden_802701.tscn
    eloi_hall.tscn
    morlock_tunnels.tscn
    green_porcelain.tscn
    far_future_shore.tscn
  /objects
    time_machine.tscn
    journal.tscn
    interactable_item.tscn
  /ui
    dialogue_box.tscn
    inventory_panel.tscn
    time_dial.tscn
/scripts
  game_state.gd
  timeline.gd
  inventory.gd
  dialogue_runner.gd
  interaction.gd
/resources
  /items
  /dialogue
  /journal_entries
  /timeline_states

That maps neatly onto Godot’s strengths. The player is a reusable scene. The time machine is a reusable scene. Each inventory item can be a data resource rather than hard-coded logic. Godot explicitly supports custom resources for data-driven game objects such as characters, entities, and item structures, which would suit an adventure game with journal entries, clues, lamps, keys, tools, and fragments of future history.  

You could keep the code simple. GDScript would be the natural first choice: it is Godot’s built-in scripting language, described by the project as Python-inspired and designed for tight engine integration. C# is also supported via the .NET build if you prefer that ecosystem, though for a small open-source adventure GDScript would probably be the path of least resistance.  

The most interesting mechanics would be thematic rather than complex. Light as safety: Morlocks avoid bright light, so matches, lamps, fire, and museum relics become survival tools. Knowledge as progression: the player unlocks not combat upgrades but interpretations, allowing new dialogue or new uses for objects. Time-state puzzles: an obstacle in the far future might be solved by acting in an earlier state, or a machine component lost in one era might be recovered as an archaeological remnant in another. Fragility of civilisation: useful objects become rarer as time advances; the world grows simpler biologically but stranger geologically.

For an RPG-skinned version, you could add very light stats without turning it into combat fantasy: Composure, Fatigue, Light, Curiosity, and Understanding. Composure falls in darkness or after Morlock encounters. Fatigue limits exploration. Light is both resource and weapon. Curiosity unlocks optional observations. Understanding gates deductions in the journal. That gives you RPG texture without betraying the book’s tone.

The best visual style for an open-source project would be something you can sustain: perhaps monochrome Victorian engravings crossed with limited-colour pixel art. Above ground: pale greens, white stone, soft ruins, idle Eloi. Below ground: near-black tunnels, mechanical silhouettes, red glints, steam, rhythmic machinery. The far future: almost empty, with the enormous sun, low surf, and non-human life. You would not need lavish animation if the composition and soundscape were strong.

Copyright-wise, this is exactly the kind of use case where public-domain literature shines. In Australia, published works whose creators died before 1 January 1955 are generally public domain; Wells died in 1946, so the original Wells material is comfortably within that pool.   For an open-source repository, you could include original Wells text excerpts, quotations, chapter epigraphs, or dialogue adapted from the novel. What you should not include are assets from later films, TV versions, book covers, audiobooks, illustrated editions, or games unless those specific assets are also openly licensed.

Godot itself is also philosophically well matched to this sort of project. It is free/open-source, and the project states that it is available under the MIT licence, with no contracts or engine fees for your game or even for building on the engine.   As of July 2026, the current Godot 4 download line is Godot 4.7, released 18 June 2026, with standard and .NET builds available.  

The smallest satisfying prototype would be just three rooms and one mechanic: the Victorian lab, the garden future, and a Morlock tunnel; one inventory system; one time-machine interface; one light/dark danger system. If that felt good, the rest of the game could grow outward scene by scene. That is the real appeal of doing it in Godot: The Time Machine becomes not one huge software problem, but a stack of small reusable scenes tied together by a clean timeline state.

## Barry
Dad joke: Godot also fits a Time Machine game because both can involve moving in the 4th dimension (one waiting, one zipping)

## GPT-5.5
Haha, that’s gloriously nerdy.

It actually works on two levels:

“I built a time travel game in Godot.”

“Ah yes—one is about traversing the fourth dimension, the other is about waiting for it.”

Or, slightly more polished:

“Using Godot to make The Time Machine seems appropriate. One is about travelling through the fourth dimension; the other is about waiting for something that never arrives.”

If you wanted to really lean into the literary joke:

“The Time Machine is about escaping the present by moving through time. Waiting for Godot is about being trapped in the present because time won’t move.”

That juxtaposition is actually quite elegant. The Time Machine is fundamentally about agency over time, whereas Waiting for Godot is almost the philosophical inverse: time passes relentlessly, yet nothing decisive ever happens.

A programmer’s version might be:

“Godot: where you spend years waiting to finish a game about travelling instantly through time.”

That one probably lands squarely in the “dad joke for software developers” category.

## Barry
Was the Godot engine actually named after the play?

## GPT-5.5
Yes—it was, and quite deliberately.

The official explanation from the Godot project is that the engine was named after Waiting for Godot. The founders chose the name because a game engine is never really “finished”: there’s always another feature to add, another optimisation to make, another platform to support. In that sense, developers are perpetually “waiting for Godot”—for the mythical moment when the engine becomes complete, which never quite arrives.  

That makes your joke even better, because it inadvertently links two separate ideas:

* Waiting for Godot → endless waiting through time.
* The Time Machine → deliberate travel through time.

So if you built The Time Machine in Godot, you’d have a game about mastering time, built in an engine named after a play about being unable to escape its passage.

Even the engine’s old slogan leaned into the pun:

“The game engine you’ve been waiting for.”  

It’s a wonderfully literary easter egg for a piece of software. Most game engines have utilitarian names (Unity, Unreal, CryEngine), whereas Godot quietly carries around a reference to one of the twentieth century’s most influential absurdist plays. Given your own fondness for both literature and software, I suspect that’s one of the reasons it appeals to you.

## Barry
Okay, is there a suitable LLM-ingestible markdown version of Wells’ original prose, or will I need to convert from a pdf?

## GPT-5.5
No PDF conversion needed. The best source is already text-native.

For an LLM/game-design workflow, I’d use Project Gutenberg’s plain-text edition of The Time Machine. Its Gutenberg page offers an accessible Plain Text download, plus HTML and EPUB formats, and identifies it as eBook no. 35.   The plain-text file is already easy to ingest, and the current file has the normal Gutenberg header/footer surrounding the actual book text.  

A simple starting point would be:

curl -L -o time-machine-gutenberg.txt https://www.gutenberg.org/cache/epub/35/pg35.txt

Then strip everything before:

*** START OF THE PROJECT GUTENBERG EBOOK THE TIME MACHINE ***

and everything after the corresponding END marker. After that, you can save it as time-machine.md and add Markdown headings manually or with a quick script.

There is also a very clean Standard Ebooks source repository. It is not Markdown, but it is probably the better structured source if you want chapters, metadata, and clean semantic formatting. The repo is explicitly the EPUB source for the Standard Ebooks edition of The Time Machine, and its src/epub/text directory contains chapter-level .xhtml files.   The repo’s licence note says the source text/artwork are believed public domain in the US, and that the contributors dedicate their own contributions via CC0.  

For a Markdown conversion from Standard Ebooks, the rough workflow would be:

git clone https://github.com/standardebooks/h-g-wells_the-time-machine.git
cd h-g-wells_the-time-machine
pandoc src/epub/text/chapter-*.xhtml src/epub/text/epilogue.xhtml -t gfm -o time-machine.md

My practical recommendation: use Project Gutenberg plain text if you want a quick LLM-ingestible source; use Standard Ebooks XHTML if you want a cleaner, chapter-aware source that converts nicely to Markdown. I would avoid PDF entirely unless you specifically need to reproduce a scanned historical edition.

## Barry
Great. And once I get the game version of the original book working well, it would be straightforward to produce pastiche expansions, such as the time traveller visiting the end Permian for a few days, or arriving in London in 2030!

## GPT-5.5
Exactly. Once the “original book” version is working, the system becomes a reusable time-expedition framework rather than a one-off adaptation.

The original Wells story gives you the canonical spine: Victorian lab → 802,701 AD → Morlock underworld → Green Porcelain Palace → terminal far future. But once you have built the time-machine interface, inventory, journal, dialogue, location transitions, hazard systems, and save-state logic, a pastiche expansion is mostly a new content pack.

For example, structurally you could have:

/episodes
  /wells_original_1895
  /end_permian
  /london_2030
  /mars_olaf_stapledon_mode
  /hyborian_accident

Each episode could define its own scenes, NPCs/creatures, items, environmental hazards, journal entries, and victory conditions, while using the same underlying player controller and adventure-game scaffolding.

The end-Permian expedition is a particularly good fit because it would let you shift the game from literary adventure into speculative natural history. The end-Permian extinction occurred about 252 million years ago and is widely treated as Earth’s largest mass extinction; Stanford’s summary links it to enormous Siberian volcanism, while broader reviews discuss global ecological collapse, warming, ocean anoxia, and long recovery.   In game terms, that gives you immediate mechanics: heat stress, toxic air, dwindling oxygen in enclosed spaces, strange pre-dinosaur faunas, shoreline anoxia, ashfall, water-quality testing, and the problem of keeping a Victorian gentleman alive in a world for which he has neither equipment nor conceptual vocabulary.

A London 2030 episode would be almost the inverse. The player is not physically imperilled in the same way, but culturally and cognitively overwhelmed. The Time Traveller arrives expecting perhaps a rational techno-utopia and instead finds smartphones, climate anxiety, algorithmic society, surveillance, electric vehicles, absurd bureaucracy, food delivery apps, degraded public discourse, and museums explaining things he only dimly anticipated. That could be played as satire, melancholy, detective fiction, or social speculation — very Wellsian in spirit without being bound to Wells’ exact itinerary.

The key design trick would be to separate engine systems from episode content. For instance, the base game could know about generic concepts like time_period, scene, interactable, inventory_item, journal_entry, hazard, and transition_condition. Then an expansion merely supplies new content:

/end_permian
  episode.json
  scenes/
    pangaea_coast.tscn
    volcanic_horizon.tscn
    anoxic_lagoon.tscn
    machine_shelter.tscn
  dialogue/
    traveller_observations.md
  items/
    brass_barometer.tres
    improvised_respirator.tres
    specimen_case.tres
  journal/
    synapsid_notes.md
    atmospheric_alarm.md

That also plays nicely with LLM-assisted development. You could ingest Wells’ original prose, build a “Wellsian narrator” style guide, then have expansions generate draft journal entries, object descriptions, scene outlines, and dialogue in a controlled pastiche voice. You would still edit heavily, but the structure gives the LLM useful constraints: “write a journal entry for a late-Victorian scientific traveller encountering a Lystrosaurus-like survivor, without modern terminology unless inferred through analogy.”

Legally, this remains comfortable because Wells’ own text is public domain in Australia under the life-plus-70 framework; Australian guidance states that literary works generally last for 70 years after the creator’s death, and Wells died in 1946.   Your end-Permian and 2030 episodes would be your own new creative additions built on a public-domain foundation. The caveats remain the same: avoid later film/game/illustration-specific designs, do not borrow copyrighted assets, and be cautious with real modern brands, living people, and trade marks if distributing publicly.

The most elegant model might be: The Time Machine: Expeditions. The first episode is Wells 1895. Later episodes become scientific, historical, satirical, or alternate-future excursions. That turns the Time Traveller into a reusable protagonist and the machine into a narrative excuse for almost any self-contained adventure.

## Barry
Excellent. With that, I think we're well positioned to start planning the build!
