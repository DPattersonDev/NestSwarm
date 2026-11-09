# Anttalope 4×2 frame integration (test branch)

The requested animation atlases are **not yet committed**: the current GitHub connector supports code changes but does not have a binary local-file upload path. This test branch contains only validation code and instructions. Do not merge as "complete" until five files are present and pass verification.

Required files in `Art/Animations/`:
- `Droven.png` — armored horned heavyweight with hooked forearms
- `Kaelor.png` — twin-bladed leaf-armored fighter
- `Nyxis.png` — white-haired masked rifle user
- `Syrra.png` — agile female mantis assassin
- `Velkara.png` — female pink-bladed caster

Atlases are RGBA 1774 × 887 and use **4 columns × 2 rows**. The first four cells are walking, the next four are basic attack poses. Keep all original `Art/Characters/Anttalope/` PNGs unchanged.

Once the images are uploaded, run:
```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/anttalope_animation_smoke.gd
godot --headless --path . --script res://tests/all_characters_art_smoke.gd
```

For a visual check, open `Scene/AllCharactersAnimationPreview.tscn` with F6 and inspect walk, attack, idle, hit and death. Confirm there are no background boxes, clipped weapons or changes in perceived figure size. Preserve existing combat speed and targeting while testing.
