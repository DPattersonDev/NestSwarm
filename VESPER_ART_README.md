# Vesper character art and shared animations

This test copy includes Veyra plus new transparent character artwork for Zekrin,
Melora, Tharos, and Aurex. Combat resources use the new art and opt into the
existing whole-sprite idle, walk, attack, hit, and death clips. This is the first
faction art batch. The other 25 characters keep their current placeholders.

## Test in Godot

Extract the ZIP into a separate folder. Import its `project.godot` in Godot.
Open `Scene/VesperAnimationPreview.tscn` and press F6. Use the character dropdown
and the animation buttons. Reset brings a character back after death. The
original `Scene/VeyraAnimationPreview.tscn` remains available.

All art is displayed at approximately 70 pixels tall during combat. The preview
enlarges it four times for inspection. Combat stats, abilities, targeting,
cooldowns, and damage timing have not been changed. Ranged units currently use
the same whole-sprite attack motion; no new projectile effect is included.
These clips do not articulate individual limbs, wings, or weapons.

## Keep the changes using GitHub Desktop

Veyra's original artwork already exists on main; these new animations and the
four new images need to be committed and merged to become part of main.

1. Close Godot before replacing project files.
2. In GitHub Desktop select your existing NestSwarm repository. Preserve any
   uncommitted work before importing this copy; compare files if you have newer
   local changes. This package is based on the earlier add8e7c project version.
3. From Current branch choose New branch; name it `vesper-art-test`.
4. Open the existing repository folder with Repository > Show in Explorer.
5. Copy the CONTENTS of the extracted NestSwarm folder into the repository
   folder (the folder that already contains project.godot). Do not nest a second
   NestSwarm folder inside it. Do not replace or delete its .git folder. Do not
   copy a .godot cache. Review replacements rather than overwriting newer work.
6. Review the Changes list, commit on `vesper-art-test`, then Publish branch or
   Push origin. This uses your own GitHub Desktop sign-in.
7. Test that branch in Godot. When satisfied, switch Current branch to main,
   choose Branch > Merge into current branch, select vesper-art-test, and review
   the merge. Push origin to save main on GitHub. Resolve any conflicts before
   continuing; do not discard newer work.

The repository branch for this batch is `codex/vesper-character-art`.
After this batch is merged, use GitHub Desktop's Fetch origin / Pull origin
on main to retrieve the character artwork and animations.

## Art locations and design prompts

Created with the built-in image generator, using existing Veyra art as the
faction/style reference. The original generated PNGs retain their alpha.

| Character | Image | Role / prompt direction |
| --- | --- | --- |
| Veyra | character/Veyra/Veyra.png.png and Data/Veyra.png.png | Existing gold-armored wasp vanguard; original artwork preserved. |
| Zekrin | Art/Characters/Vesper/Zekrin.png | Lean adult wasp assassin, dark hair, narrow gold/black chitin armor, two stinger daggers with restrained venom-green tips. |
| Melora | Art/Characters/Vesper/Melora.png | Royal nectar support, chestnut hair, elegant gold/ivory light armor, honeycomb healing staff and amber nectar orb, delicate wings. |
| Tharos | Art/Characters/Vesper/Tharos.png | Muscular adult wasp fighter, short auburn hair, broad gold/black armor, twin hook blades and burnt-orange cloth. |
| Aurex | Art/Characters/Vesper/Aurex.png | Slender adult wasp marksman, tied-back pale blond hair, compact wrist-mounted needle launcher, jade-tipped darts and spare hip quiver. |

Shared generation constraints: one character per image; polished anime fantasy
painted finish matching Veyra, honey-gold metallic chitin over black, amber-veined
insect wings and antennae, full body and equipment visible, grounded standing
pose, slight three-quarter view, genuine transparent background, soft front
lighting, no scenery, text, UI, or cast shadow.

## Validation

Godot 4.5.1 headless import and runtime checks:

- `tests/veyra_animation_smoke.gd`: original combat/animation behavior checks.
- `tests/vesper_art_smoke.gd`: all five resource/texture assignments, actual
  transparency, consistent sizing, preview character switching, attack/hit/death
  transitions, and recreation after death.

Visual approval of the new images and clips in your Godot editor remains useful.
