# Melody Mill - Audio System and Music Rules

## Purpose
This document defines how **Melody Mill** should stay musical, readable, and pleasant over long play sessions.

## Core Recommendation
Treat the soundtrack like a **layered reactive arrangement**, not a pile of random one-shots.

The player should feel like they are assembling a song in real time. Every rule in this document exists to protect that feeling.

## The Main Audio Risk
The biggest danger is audio fatigue.

If too many upgrades trigger noisy or repetitive sounds, the game stops feeling magical and starts feeling exhausting. The music system must make almost any purchase order sound good.

## Core Music Rules
- all note events stay in a fixed key and scale
- all events quantize to a beat grid
- each upgrade family belongs to a defined musical lane
- the game controls timing, pitch boundaries, and density
- custom sounds can change timbre, but not core musical timing rules

## Recommended Lane Model
Use 4 main lanes in version 1.

### Lane 1: Pulse / Percussion
- sets the groove
- short transient sounds
- most reliable lane

### Lane 2: Melody
- carries the most identity
- brighter notes and hooks
- most sensitive to fatigue, so variation matters most here

### Lane 3: Bass
- grounds the track
- slower, simpler pattern set
- should never become too busy

### Lane 4: Harmony / Texture
- pads, sustained layers, soft fills, ambience
- makes late-game music feel "big"

## How to Stop Loops From Getting Annoying
The best path is controlled variation.

### Required Systems
- rotate patterns every `8` or `16` bars
- keep `3-6` pattern variants per lane in version 1
- allow rare fills or accents every `16-32` bars
- slightly vary velocity, octave choice, or note selection within safe bounds
- avoid triggering the exact same sample at full volume too often

### Recommended Rule
No important lane should feel frozen for longer than `30-45 seconds`.

## How Much Variation Per Lane
Version 1 does not need a huge content library, but it does need enough movement.

### Suggested Minimums
- Percussion lane: `4-6` patterns
- Melody lane: `6-10` short phrases
- Bass lane: `3-5` patterns
- Texture lane: `3-4` ambient or chord variations

This is enough to feel alive without becoming hard to manage.

## Can Players Mute, Solo, or Rebalance Parts
Yes. This is not optional for a music-first game.

### Required Controls
- master volume
- music volume
- sound effect volume
- per-lane volume sliders
- mute per lane
- solo per lane

### Strongly Recommended
- a `Low Complexity` mode that reduces arrangement density
- a `Focus Mode` that softens SFX and highlights the musical mix

## What Makes Hour 5 Better Than Minute 5
Do not rely only on bigger numbers. The arrangement itself must mature.

### Best Path
- more lanes unlock over time
- patterns get more sophisticated
- capstone upgrades introduce new phrase variants
- prestige unlocks richer harmony, not just faster production
- later worlds introduce fresh instrument palettes
- Theme Packs let players remix the experience visually and sonically

The song at hour 5 should feel fuller, more expressive, and more personal.

## Audio Progression Goals
- first musical layer: within `30 seconds`
- second clear layer: by `3-5 minutes`
- first "this sounds really good now" moment: by `5-8 minutes`
- first full arrangement feeling: before first prestige

## Scheduling Rules
- quantize most gameplay events to `1/8` notes
- allow some rare accents at `1/16` notes for energy
- avoid unquantized lane events except for cosmetic SFX
- keep loop lengths readable: `1`, `2`, or `4` bars

This keeps the soundtrack clean and the design testable.

## Sound Design Boundaries
- short sounds should dominate most upgrade triggers
- long samples should be reserved for texture or special moments
- harsh transients should be softened by default
- clip loudness should be normalized before use
- similar simultaneous sounds should be voice-limited

## Player-Created Audio Rules
Custom audio should plug into slots, not replace the music engine.

### Recommendation
- assign imported clips to lane or upgrade slots
- let the engine place the clip on the beat grid
- optionally auto-pitch or pitch-limit clips to the active scale
- limit clip duration by slot type

### Suggested Clip Limits
- click sounds: up to `0.35 seconds`
- lane trigger sounds: up to `1.0 second`
- texture sounds: up to `2.0 seconds`

## Performance Rules
Late-game performance matters because lots of upgrades and lots of sounds can stack fast.

### Best Path
- use a single scheduler per Mill, not one timer per object
- pool audio players
- cap simultaneous voices by lane
- pre-load active pack audio
- downgrade low-priority sounds first when the scene gets busy

### Suggested Voice Limits
- Percussion: `8-12`
- Melody: `6-8`
- Bass: `2-4`
- Texture: `2-4`

## Accessibility
Audio-first does not mean audio-only.

### Required
- separate volume controls
- captions or labels for important audio unlock moments
- reduced flashing option
- no mandatory rhythm-perfect clicking
- strong visual feedback for lane activation

### Strongly Recommended
- a visual metronome toggle
- reduced dynamic range option
- low-intensity color mode for overloaded scenes

## Mix and Bus Structure
Keep the mix understandable.

### Suggested Buses
- Master
- Music
- SFX
- Percussion
- Melody
- Bass
- Texture
- UI

This makes user controls, ducking, and later polish much easier.

## Tuning Checklist
If the music feels bad, test these first:

- Is the melody lane repeating too literally
- Are too many events firing at once
- Is the same sample retriggering too often
- Is the bass lane too active
- Are texture layers masking the hook
- Are players missing the ability to turn down a lane they dislike

## Best Path Summary
1. Build a 4-lane quantized arrangement system.
2. Add enough phrase variation to keep the first `30 minutes` pleasant.
3. Add lane-level player controls early.
4. Support custom sounds only through validated slot assignment, never through freeform timing logic.
