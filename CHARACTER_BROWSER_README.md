# Character browser

Open **Characters** from the main menu, or run `Scene/CharacterBrowser.tscn` directly in Godot 4.4.

- Browse all 30 characters, grouped into six clans. Vesper begins Veyra, Aurex, Melora, Tharos, Zekrin.
- Select one or several clan filters; clear the last selected clan or choose All Clans to restore the full roster.
- Use portrait swipes, previous/next buttons, thumbnails, or the left/right keyboard arrows to browse. Navigation wraps at the ends of the filtered roster.
- Tap the portrait, select Story/Overview, or press S to switch pages. Tab retains normal keyboard focus navigation. Escape or Back returns to the main menu.
- Scroll the right panel for ability details and faction bonuses. Each ability expands independently. The special is explicitly marked as an upgrade unlock.

## Data and art

The browser reads the existing CharacterData resources and UpgradeDatabase definitions. Every portrait is the actual existing game artwork; the approved mockup guides the gold-and-black layout. This change does not add a separate photorealistic portrait collection or replace battle art.

`character_catalog.gd` defines clan order and faction descriptions, checked against the existing combat implementation. `character_lore.gd` contains initial original personalities, quotes, and biographies for all 30 characters, ready for narrative revision. Lore uses a referenced script resource so it is included in exports without an extra JSON export filter.

Browsing does not select a team, start a timer, reset a match, or alter battle resources.

## Validation

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/character_browser_smoke.gd
```

With a rendering display available:

```sh
godot --path . --rendering-method gl_compatibility --script res://tests/character_browser_visual.gd
```

The smoke check covers all 30 portraits, ability definitions and expansion, story pages, multi-clan filtering, wraparound, touch gestures, emulated-mouse suppression, keyboard navigation, match-state preservation, and real menu/Back scene transitions. The rendered check exercises GUI hit testing, resizing, and scroll access; it saves captures under `user://character-browser-captures`. Pass `-- --output-dir=/absolute/path` to choose another capture folder.
