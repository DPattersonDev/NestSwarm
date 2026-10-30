# Placement board and combat presentation preview

## Test

Pull main in GitHub Desktop and reopen project.godot. F5 runs the normal game.
Choose four characters and click their bench portraits, then teal squares to place
or move them. The front faces RIGHT, matching combat. Coral squares mark the enemy
side. Pause timer gives more planning time. Four placed units enable Start Round.

Open Scene/CombatAnimationPreview.tscn and press F6 to inspect Veyra and Aurex.
They have eight-pose atlases: four alternating walk poses and four spear-thrust /
wrist-launcher attack poses. The other 28 characters retain whole-sprite motions
until this prototype is reviewed. Idle artwork, faction designs and combat stats
are preserved. The viewport is explicitly 1152 x 760 to fit the controls.

## Board

scripts/board_layout.gd defines the same logical-cell centers for placement and
combat. The existing arena art remains underneath visible square tiles, colored
team areas and front labels. Original spawn coordinates and spacing are retained.
Placement no longer rotates the formation ninety degrees relative to combat.

## Effects and timing

All units use lightweight code-drawn hit, melee, healing, shield, venom and bleed
cues. Marksmen and support attacks have visible needles, arrows, cannon shells,
venom bolts or sparks according to character. Healing shows actual restored HP.
Effects belong to the scene so they can outlive a defeated sprite safely.

Basic attacks reserve cooldown immediately, anticipate for 0.07 seconds, then
apply melee damage or launch a 0.12-second projectile. Ranged damage occurs at
arrival. Attacks canceled by attacker defeat or round shutdown do not apply late
damage. This intentionally changes impact timing, not damage or cooldown values.

## Artwork

Built-in image generation edited the existing Veyra and Aurex designs into 4 x 2
transparent atlases. Prompt: preserve the character's gold/black armor and identity;
four successive alternating-leg walk poses above four anticipation, release,
extension and recovery poses; face right; consistent cell scale and baseline;
full equipment within each cell; no labels. Aurex's atlas was cleaned of baked
projectiles so the game draws each shot once. These are initial frame prototypes,
not final hand-animated production cycles.

## Validation

Godot 4.5.1 import; all_characters_art_smoke.gd; veyra_animation_smoke.gd;
board_combat_smoke.gd (all 40 board coordinate mappings, placement/movement,
occupied-cell protection, cooldown reservation, delayed impact, frame selection,
healing/shields, cancellation at round stop). A live 4v4 battle and rendered
placement/battle/animation views were also inspected.

## Arena and privacy follow-up

Planning uses an enlarged player board. A small Previous formation card uses a
snapshot saved when the last battle began, never current enemy setup. Round 1 is
empty; snapshots reset for a new match. Character details are a toggle so they do
not crowd the player board.

Combat draws the actual opaque honeycomb floor, without setup squares or side
labels. All spawn squares fit inside the floor; live units are bounded away from
decorative walls during movement and knockback. Shields have a faint persistent
bubble while current_shield is positive, and healing shows the actual +N HP.

Additional validation: tests/arena_privacy_smoke.gd covers hidden current setup,
snapshot independence/reset, tile containment, movement bounds, persistent shield
visibility/depletion, and the actual healed-HP indicator. Rendered planning and
battle views were inspected.
