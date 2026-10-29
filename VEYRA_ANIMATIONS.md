# Veyra animations

Open `Scene/VeyraAnimationPreview.tscn` in Godot and press **F6** to inspect
idle, walk, attack, hit, and death. The preview enlarges Veyra four times;
normal combat keeps the existing sprite size. Use **Reset Veyra** after death.

In normal combat, idle and walk loop automatically, basic attacks trigger a
short forward thrust, health damage triggers a recoil/flash, and death tilts
and fades her sprite before removal. Dead units stop participating immediately.
Attack and death take priority over hit reactions. Damage timing, movement
speed, cooldowns, targeting, abilities, and upgrades retain their existing logic.

These are whole-sprite animations built from the illustration already in the
project. They do not add individual leg steps, arm articulation, independent
spear movement, or a skeletal rig. Those need layered artwork or sprite frames.

The shared Character scene contains the reusable animation clips and controller.
Prepared Vesper characters now opt in through CharacterData.sprite_animations_enabled.
See VESPER_ART_README.md and Scene/VesperAnimationPreview.tscn for the five-character
preview. Characters without prepared art keep their current combat visuals and
immediate removal.

Validation (Godot 4.5.1 headless):

```sh
godot --headless --path . --script res://tests/veyra_animation_smoke.gd
```

This checks looping, movement/idle transitions, attack damage and animation,
left-facing thrust, attack priority, hit cleanup, zero-damage behavior, death
timing, and the opt-in boundary for other characters. Visual review in your
Godot editor is still needed. The repository declares Godot 4.7; the animation
library uses the dictionary serialization also supported by Godot 4.5.1.
