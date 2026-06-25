# Melody Mill - One-Page Game Design Doc

## High Concept
**Melody Mill** is a musical idle game for Steam where players build themed production worlds that generate both resources and songs. Each world, or **Mill**, has its own main object, upgrade set, mechanic flavor, and instrument palette. On top of that, players can apply official or custom **Theme Packs** that change how the world looks and sounds. The core hook is simple: **click, automate, and compose a better song as the factory grows**.

## Player Fantasy
The player is not just making numbers go up. They are building a living music machine where every purchase makes the world richer, busier, and more melodic.

## Core Pillars
1. **Music as Reward**: every upgrade improves output and adds to the soundtrack.
2. **Strong Idle Progression**: satisfying click feedback, clean upgrade pacing, and escalating stage goals.
3. **World Variety**: each Mill feels like a new album, not just a reskin.
4. **Creative Expression**: players can customize how items look and sound without breaking progression.
5. **Meaningful Prestige**: resets feed long-term growth through Harmony Points.

## Core Loop
1. Enter an unlocked Mill.
2. Optionally apply a Theme Pack to change visuals, names, and sounds.
3. Click the Mill's main object to harvest its local resource.
4. Spend resources on Mill-specific upgrades that increase production.
5. Upgrades automatically interact with the main object on timed loops.
6. Each interaction adds a note, beat, chord, or texture layer.
7. When the current object is fully harvested, a bigger stage version appears.
8. Reach a prestige milestone and reset the Mill for Harmony Points.
9. Spend Harmony Points on permanent upgrades, new Mills, and creative unlocks.

## Game Structure
The game should clearly separate progression systems from customization systems.

### Core Terms
- **Mill / World**: an official gameplay space with its own resource, upgrades, visuals, and music identity.
- **Theme Pack**: a swappable presentation layer that can change icons, names, colors, backgrounds, and sounds.
- **Sound Pack**: an optional subset of a Theme Pack focused only on audio.

### Design Rule
- **Mills change gameplay structure**
- **Theme Packs change presentation**

Custom content should not change prices, production values, rhythm rules, or unlock conditions in version 1.

## Progression Model
Progression should be a hybrid:

- players unlock new Mills over time
- once a Mill is unlocked, they can switch between unlocked Mills whenever they want
- each Mill has its own local progress and local resource
- all Mills feed a shared global meta progression through Harmony Points

This keeps the game feeling expandable while still preserving the satisfaction of unlocking new worlds.

## Mill Structure
Each Mill should be built from the same gameplay skeleton, but have its own flavor.

### Every Mill Includes
- one central clickable object
- 8-10 themed upgrades
- 4 musical lanes
- a unique instrument palette
- a background and animation style
- one small mechanic twist that changes the feel
- a local prestige loop tied to that world's fantasy

### Mill Examples
| Mill | Main Object | Visual Tone | Sound Palette | Twist |
|---|---|---|---|---|
| Cat Mill | Yarn Ball | Cozy and playful | Bells, plucks, purr-like pads | Bouncy timing and playful swats |
| Robot Mill | Power Core | Clean and mechanical | Synth arps, metallic percussion, bass pulses | Precision boosts from perfect sync |
| Spooky Mill | Haunted Orb | Eerie and whimsical | Music box, choir, ghostly FX | Slow build into dramatic crescendos |
| Ocean Mill | Coral Pearl | Calm and fluid | Marimba, water percussion, airy pads | Gentle wave timing that shifts patterns |

## Launch World
Version 1 should launch with **Cat Mill** as the flagship Mill.

### Cat Mill Stage Examples
- Small Yarn Ball
- Thick Yarn Ball
- Giant Yarn Bundle
- Royal Yarn Sphere
- Cosmic Yarn Moon

### Cat Mill Upgrade Examples
| Upgrade | Gameplay Role | Musical Role |
|---|---|---|
| Kitten | Basic auto-clicker | High pluck / bell |
| House Cat | Faster batting hits | Main melody notes |
| Scratching Post | Passive bonus | Soft percussion |
| Yarn Basket | Multiplier support | Shaker / texture |
| Cat Tower | Boosts nearby cats | Harmony notes |
| Yarn Mill | Strong production | Mid-range chord stab |
| Cat Choir | Rare buff unit | Vocal-like pad |
| Grand Meowstro | Late-game capstone | Bass / lead phrase |

## Music System
The audio must sound good even when players buy upgrades in a messy order.

### Rules for the System
- All notes stay in a fixed key and scale.
- All hits are quantized to a beat grid.
- Each upgrade family has a musical lane:
  - light units = melody
  - support/buildings = percussion or texture
  - heavy units = bass
  - rare/special units = harmony or pads
- New purchases add variation without breaking the groove.
- Players can mute or solo lanes to tune the mix.
- Custom sounds are still routed through these lanes and timing rules.

### Audio Goal
The player should feel like they are gradually assembling a song, not creating random noise.

## Prestige and Harmony
Melody Mill should have a prestige system, but it should feel musical rather than generic.

### Prestige Structure
- each Mill can be reset independently
- resetting a Mill grants **Harmony Points**
- Harmony Points are global and persist across all Mills
- prestige should unlock when the player reaches a major stage milestone in a Mill

### Cat Mill Example
In Cat Mill, the player can **spin the giant yarn ball into Harmony**, resetting Cat Mill progress in exchange for Harmony Points.

### What Harmony Points Should Buy
- permanent production boosts
- faster early-game starts
- new Mills
- automation improvements
- extra music lanes or stronger music layering
- more customization slots or Theme Pack tools

## Harmony Tree
Harmony Points should feed a **small global skill tree**, not a giant one.

### Suggested Branches
- **Rhythm**: faster auto-hits, stronger timing bonuses, better tempo effects
- **Harmony**: richer chords, extra layers, stronger melodic complexity
- **Craft**: cheaper upgrades, stronger offline gains, better starting boosts
- **Discovery**: new Mills, extra Theme Pack slots, more customization features

### Tree Guidelines
- keep version 1 to roughly 15-25 nodes
- avoid trap choices and confusing branches
- basic quality-of-life features should not be hidden too deep
- the tree should shape playstyle, not punish experimentation

## Art Direction
- Each Mill needs a bold silhouette and color language so themes read instantly.
- The main clickable object must feel tactile and rewarding.
- Upgrade animations should match the personality of the theme.
- Late-game scenes should feel full, not cluttered.

## Customization and UGC Roadmap
Customization should sit on top of the world system, not replace it.

### Phase 1: Safe Theme Packs for Launch
- recolor items
- swap approved cosmetic parts
- custom icons and names
- background and palette swaps
- official or player-made visual Theme Packs

### Phase 2: Controlled Custom Sounds
- let players record or import short samples
- enforce max length, loudness normalization, and file limits
- route custom sounds into existing musical lanes so they stay musical
- optionally auto-pitch or pitch-limit clips to match the current scale

### Phase 3: Sharing
- Steam Workshop support for browsing, downloading, and applying community Theme Packs and Sound Packs
- optional in-game browser for installed community packs
- moderation and reporting tools
- clear rules for copyrighted audio

### Version 1 Limits
Custom Theme Packs should not edit:
- prices
- production values
- unlock conditions
- rhythm rules
- prestige formulas

## MVP Scope
Ship the smallest version that proves the hook.

- 1 Mill at launch: Cat Mill
- 5 Cat Mill stages
- 8-10 Cat Mill upgrades
- 4 musical lanes
- 1 local prestige loop that grants Harmony Points
- 1 small Harmony Tree
- save/load
- basic settings for volume and accessibility
- support for simple Theme Pack swapping
- strong polish on click feel, animation, and mix

## Expansion Plan
Once the first Mill feels great, add new Mills as major content drops.

- update 1: Robot Mill
- update 2: Spooky Mill
- update 3: Ocean Mill
- future platform feature: Steam Workshop pipeline for community pack sharing and importing

This keeps the game expandable without requiring every theme on day one.

## Risks
- **Audio chaos**: solved with key-locking, beat quantization, and defined musical roles.
- **Theme bloat**: solved by shipping one great Mill before expanding.
- **System confusion**: solved by clearly separating Mills from Theme Packs.
- **Over-scope**: avoid unrestricted modding and raw audio upload in version 1.
- **Weak prestige**: solved by tying Harmony Points to permanent progress and new unlocks.
- **Late-game clutter**: use lane controls, clean UI, and capped on-screen effects.

## Steam Pitch
**Build music-powered worlds where every upgrade adds to a living song.**

## Immediate Next Step
Prototype a single screen with:
- Cat Mill only
- clickable yarn
- 3 upgrades
- 1 looping beat
- upgrades triggering notes on a fixed rhythm
- a stub for spinning yarn into Harmony later
- data structure support for separate Mill data and Theme Pack data

If that prototype feels good, the rest of **Melody Mill** is worth building.
