# Melody Mill - Visual Vertical Slice Plan

## Goal
Turn the current Godot prototype into a **small but polished vertical slice** that feels cozy, modern, and commercially credible.

This plan assumes:
- we **stay in Godot**
- the current build is a **prototype**, not a visual foundation
- the main issue is **presentation quality**, not engine capability

## Core Diagnosis
The game currently feels janky because too many important visuals are still doing prototype work.

### Main Problems
- core scene art is mostly procedural placeholder drawing
- UI layout is functional but not designed as a finished product
- visual hierarchy is weak, so the eye does not know what matters most
- the cats, yarn, shelf, and buttons do not yet feel like they belong to one art system
- motion and feedback are too light, so interactions feel cheap

## Vertical Slice Definition
The first polished slice should prove one thing:

**Melody Mill can make clicking a central object, buying musical upgrades, and growing a song feel beautiful and premium.**

For version 1 of the visual slice, we should focus on:
- `Cat Mill` only
- one finished screen
- one polished visual theme
- one polished UI direction
- one polished interaction loop

Do not try to solve every future theme right now.

## Target Experience
The player opens the game and immediately understands:
- the center yarn is the hero
- the beat guide tells them when to click
- the island is the world
- the cats are the performers
- the shelf is a handcrafted shop
- every click wakes up art, motion, and sound together

The tone should be:
- cozy
- handcrafted
- musical
- warm
- readable
- lightly magical

## Visual Direction For Cat Mill
Use **cozy island workshop** as the anchor style.

### Scene Composition
- center: the yarn centerpiece
- crossing the center: a visible beat lane or beat ring
- around center: the active performer and progression ring
- edges/background: island props, palms, dock pieces, huts, flowers, lanterns
- right side: compact toy shelf / wooden market rack

### Shape Language
- rounded silhouettes
- soft asymmetry
- thick readable forms
- simple hand-drawn details
- avoid tiny noisy linework

### Color Direction
- warm sand
- faded coral
- honey gold
- seafoam
- leafy green
- cream paper neutrals

### Modern Feel Rule
Modern does **not** mean flat tech UI.

For Melody Mill, modern should mean:
- strong hierarchy
- intentional spacing
- consistent asset quality
- restrained but satisfying motion
- clean typography
- fewer placeholder shapes

## Camera Recommendation
Do **not** use a true flat top-down camera and do **not** stay in the current side-leaning layout.

Use a **semi-top-down storybook angle**:
- readable like a board game table
- cozy like a hand-painted island scene
- structured enough to support rhythm gameplay

This is the best middle ground between:
- warmth and charm
- readable progression
- a clear center-focused rhythm mechanic

## New Hero Layout Blueprint
The vertical slice should reorganize the screen around a rhythm-first center.

### Center Board
- the yarn sits exactly in the center of the play area
- a beat guide passes through or around the yarn
- strong beats should visually converge on the yarn
- perfect or near-perfect clicks should create a bigger visual and resource reward

### Performer Ring
- melody units should sit closest to the center
- percussion and texture units should sit on the left and right flanks
- bass or late-game capstone pieces should anchor the outer ring
- new upgrades should visually claim positions around the yarn as the song grows

### Progression Readability
- early game should look sparse and cozy
- mid game should look fuller and more musical
- late game should feel like the island became a complete living arrangement
- progression should change the composition around the center, not just inflate one object

### Shop Separation
- the Toy Shelf remains a compact right-side UI rack
- the shelf sells and previews items
- bought items should appear in the center world or its surrounding rings
- the shelf should not become the place where progression is staged visually

## What Must Change Technically
The current prototype is too dependent on visuals drawn directly in code.

### Recommendation
Move the project toward an **asset-driven presentation layer**.

That means:
- background art should become imported images or layered scene assets
- yarn stages should use defined art states instead of just scale changes
- cats should be sprite-based or modular part-based visuals, not only circle-and-arc sketches
- shelf cards should use reusable UI components with consistent spacing and art slots

Procedural code can still help with:
- bobbing
- pulsing
- glow
- orbit placement
- parallax
- simple accent effects

But it should stop carrying the full art load.

## Art Pipeline Recommendation
Use a lightweight production pipeline that can later support theme packs.

### For The Slice
Create these real assets first:
- `background_sky`
- `background_island`
- `centerpiece_stage_01` through `centerpiece_stage_05`
- `cat_base_01`
- `cat_base_02`
- `upgrade_icons`
- `toy_shelf_frame`
- `ui_panel_paper`
- `button_base`

### Best Production Method Right Now
- use AI art for early concept and placeholder production
- paint over or simplify anything too noisy
- keep asset shapes broad and game-readable
- prefer a small consistent set of assets over many mismatched ones

## UI Redesign Priorities
The UI should feel more like a game product and less like debug tooling.

### Rules
- keep the yarn scene visually dominant
- reduce horizontal pressure
- make the shelf compact and vertically scannable
- give the top bar a clear visual rhythm
- use fewer competing panels

### Immediate UI Structure
- top bar: title, currency, harmony, theme switch
- center-left: hero scene with centered yarn and beat guide
- bottom-left: progression and action status
- right: compact toy shelf with pinned cards

### UI Quality Targets
- no horizontal scrolling at default window size
- buttons should feel chunky and tactile
- spacing should be consistent in 4/8/12/16px steps
- each panel should have a clear purpose

## Motion And Juice Plan
The slice will still feel cheap if motion is weak.

### Required Interaction Feedback
- yarn press squash and rebound
- beat markers should pulse toward the center on tempo
- on-beat clicks should create a stronger flash, bounce, and sound accent than off-beat clicks
- soft glow pulse on successful clicks
- upgrade purchase pop + shelf card settle
- cats bounce or sway on their rhythm lane
- stage transitions should bloom or unfurl, not just replace abruptly

### Required Ambient Motion
- floating notes
- subtle leaf movement
- gentle background drift
- periodic sparkle or dust accents near the centerpiece

## Audio-Visual Sync Goals
The game's identity depends on sound, so visuals must answer the music.

### Every Important Event Should Trigger Both
- off-beat click: small yarn response + click sound
- on-beat click: stronger yarn response + bonus cue
- auto hit: performer animation + note
- purchase: card reaction + musical add
- stage upgrade: centerpiece transformation + richer layered cue
- prestige: special scene event, not just a reset

## Scope Cuts
To get a polished slice faster, do **not** try to polish these yet:
- Steam Workshop UI
- multiple Islands
- final customization browser
- advanced options menus
- many alternate themes
- deep Harmony Tree visuals

Those stay planned, but the vertical slice should prove the core screen first.

## Recommended Build Order
Build in this order so improvements stack correctly.

### Phase 1: Lock The Visual System
- pick final Cat Mill visual direction
- pick final rhythm-guide presentation: lane or ring
- lock the semi-top-down camera angle
- define palette, line weight, texture level, and UI materials
- collect reference images
- decide the finished target for yarn, cats, shelf, and panels

### Phase 2: Replace Hero Art
- replace procedural yarn with stage-based centerpiece art
- add beat-guide art and timing markers around the centerpiece
- replace rough cats with clean sprite or modular cat assets
- replace scene background with layered island art

### Phase 3: Redesign The Main UI
- tighten layout for default window size
- finalize top bar
- finalize bottom status area
- finalize compact right-side toy shelf
- place upgrade world objects around the center by lane and progression role

### Phase 4: Add Motion Pass
- click bounce
- on-beat reward flash and timing hit response
- purchase pop
- lane-driven cat motion
- stage bloom transitions
- small ambient effects

### Phase 5: Add Premium Feedback
- better hover states
- cleaner transitions
- glow and highlight polish
- stronger purchase and prestige reactions

## Definition Of Done For The Slice
The Cat Mill vertical slice is visually successful when:
- a new player can instantly identify the yarn as the main interaction
- a new player can understand the beat timing without a tutorial wall
- the scene looks intentional at default resolution
- the shelf reads cleanly without layout stress
- the cats look like finished characters, not placeholders
- progression changes both the centerpiece and the surrounding world in interesting ways
- clicking, buying, and stage growth all feel satisfying
- the game is recognizable as Melody Mill after one screenshot

## Immediate Next Implementation Tasks
These are the best next build tasks for the repo.

1. Replace the code-drawn centerpiece with imported stage art slots.
2. Add a visible beat lane or beat ring centered on the yarn.
3. Replace the code-drawn cats with 2-3 reusable cat sprite variants.
4. Replace the procedural island background with layered image assets.
5. Convert the toy shelf into a compact reusable UI component with fixed-width cards.
6. Add tweened click, on-beat reward, purchase, and stage-transition animation hooks.
7. Add asset slot definitions so future Theme Packs can override visuals safely.

## Final Recommendation
Do **not** switch to Unity right now.

The fastest path to a better-looking game is:
- keep Godot
- improve the art pipeline
- improve layout
- improve feedback
- build one beautiful Cat Mill screen before expanding scope
