# Melody Mill - Theme Pack Format

## Purpose
This document defines the best path for player-made visual and audio customization in **Melody Mill**.

## Core Recommendation
Separate gameplay from customization completely.

- `Islands` define major progression themes
- `Mills` define mechanics and local progression inside each Island
- `Theme Packs` define presentation
- `Sound Packs` optionally replace only audio-facing slots

This keeps UGC fun without letting it break balance.

Official Island unlocks and Theme Packs are related but separate. Unlocking a new Island gives the player a new core world theme and Mill. Applying a Theme Pack remixes the look, names, colors, and optional sounds of an Island the player already has access to.

## Version 1 Scope
Version 1 should support local and swappable Theme Packs, but with strong limits.

### Players Should Be Able To Change
- upgrade icons
- upgrade display names
- main object art
- stage art
- background art
- UI palette colors
- lane or upgrade sound slots

### Players Should Not Be Able To Change
- prices
- production values
- unlock conditions
- timing rules
- rhythm quantization
- prestige formulas
- code or logic

## Best Path for Pack Types
Use three pack categories:

### Visual Theme Pack
- icons
- sprites
- names
- colors
- backgrounds

### Sound Pack
- click sounds
- lane trigger sounds
- texture sounds

### Full Theme Pack
- visual + audio together

This lets players remix parts cleanly instead of forcing one giant format.

## Recommended Folder Structure
Use a folder-based format in version 1 so it is easy to inspect and edit.

```text
theme_packs/
  my_cat_pack/
    manifest.json
    preview.png
    text.json
    colors.json
    visuals/
      main_object.png
      background.png
      upgrades/
        kitten.png
        house_cat.png
    audio/
      click_primary.ogg
      lane_melody_01.ogg
      lane_bass_01.ogg
```

## Manifest Rules
Every pack should include a `manifest.json`.

### Required Fields
- `id`
- `name`
- `author`
- `version`
- `target_game_version`
- `pack_type`

### Optional Fields
- `description`
- `supported_mills`
- `preview_image`
- `license`

## Can Players Rename Upgrades
Yes, but only through text replacement fields.

### Recommendation
- allow display-name overrides
- keep internal gameplay IDs unchanged
- set a visible character limit for UI safety

Suggested display limit: around `24-28 characters`

## Can Players Swap Animations or Only Sprites
Best path for version 1: **sprites only**.

### Why
- much easier to validate
- much easier to support in custom packs
- much less likely to break performance or UI layout

If animation support is added later, it should use fixed templates, not arbitrary custom behavior.

## How Custom Sounds Should Be Assigned
Use explicit slot IDs.

### Example Slot Types
- `click_primary`
- `main_object_hit_light`
- `main_object_hit_heavy`
- `lane_percussion_01`
- `lane_melody_01`
- `lane_bass_01`
- `lane_texture_01`
- `purchase_common`
- `purchase_rare`

The engine should decide when and how those sounds are played. The pack only supplies the source files.

## Import and Validation Rules
Every pack should be validated before use.

### Image Rules
- allow `png` and possibly `webp`
- set max recommended resolution per asset
- auto-scale oversized images where safe

### Audio Rules
- allow `ogg` and `wav`
- normalize loudness on import
- reject clips that exceed slot length limits
- optionally resample to a standard format

### Text Rules
- reject missing required fields
- fall back to defaults for optional missing fields

## What Happens If a Pack Is Broken
The game should fail gracefully.

### Best Path
- if `manifest.json` is invalid, disable the pack and show a clear error
- if an asset is missing, use the default asset for that slot
- if an audio file is invalid, mute only that slot and report the issue
- never corrupt a save because a pack is broken

## UI Structure
Players need to understand where world choice ends and pack choice begins.

### Separate Menus
- `Mill Select`: choose the gameplay world
- `Theme Packs`: choose visual presentation
- `Sound Packs`: choose audio presentation
- `Community Packs`: browse subscribed Workshop items
- `Import / Validate`: inspect custom packs and warnings

Do not bury pack management inside the prestige tree or world unlock flow.

## Save Data and Steam Cloud
Progression and custom content should be stored separately.

### Best Path
- save progression in a core save file
- store only active pack IDs and versions in the save
- store pack files separately from progression
- if a pack is missing on load, use defaults and keep the save intact

### Cloud Recommendation
- cloud-sync progression and pack references
- do not depend on raw local recordings syncing perfectly across devices
- if shared packs exist later, redownload them by ID instead of embedding them in the save

## Sharing and Legal Risk
Private local customization is easy. Shared audio is not.

### Version 1
- local packs only
- no public upload system yet

### Later Version
- Workshop or curated sharing
- report system
- takedown process
- copyright policy acceptance during upload

This is the safest path and avoids turning the first release into a moderation problem.

## Steam Workshop Goal
Steam Workshop should be the main community-sharing path once the local pack system is stable.

### What Players Should Be Able To Do
- browse Theme Packs and Sound Packs made by other players
- subscribe to a pack through Steam Workshop
- have the game detect and import the subscribed pack automatically
- preview and apply Workshop packs the same way as local packs

### Best Path
- use the same `manifest.json` and folder structure for local packs and Workshop packs
- run Workshop packs through the exact same validation pipeline as local imports
- install or mirror Workshop content into a managed local pack directory
- if a Workshop item updates, revalidate it before making it active
- if a Workshop item is removed or unsubscribed, fall back to defaults without damaging the save

### Versioning Rule
- saves should reference pack `id` and `version`
- if the exact version is unavailable, load the closest valid version or defaults
- progression saves must remain valid even if community content changes

## Accessibility and Safety
- warn users if imported audio is unusually loud
- support preview-before-apply
- allow quick reset to defaults
- allow disabling community content globally

## Implementation Order
1. Local visual Theme Packs
2. Local Sound Packs with slot validation
3. Pack preview and import warnings
4. Steam Workshop import and subscription flow
5. Shared packs only after the local system is stable and the validation pipeline is proven

## Best Path Summary
Start with tightly scoped, local, slot-based customization. Let players personalize the look and sound of the game, but do not let packs touch gameplay logic in version 1.
