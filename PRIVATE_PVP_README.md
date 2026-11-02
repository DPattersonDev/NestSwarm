# NESTSWARM private PVP playtest

Two players can play the existing 4 versus 4 combat across two Windows PCs. This is an isolated playtest mode on `feat/private-pvp`; offline Play and the character browser remain available. Use the same build on both PCs.

## Start on Windows

1. Extract the entire Windows ZIP on both PCs. Run `NESTSWARM_Private_PVP.exe`.
2. Install and sign in to Tailscale on both PCs: https://tailscale.com/docs/install/windows . Use your own accounts. The host can share their PC with the friend from the Tailscale Machines page; the friend accepts the invitation: https://tailscale.com/docs/features/sharing . Alternatively, both PCs can belong to an authorized shared tailnet.
3. Confirm the friend can reach the host's Tailscale address. Sharing and access rules must permit the friend to connect to the host. Do not share account passwords.
4. Open **PRIVATE PVP TEST** from the game menu on both PCs.
5. Host: leave the UDP port at **24567** and select **Host Match**. Send your friend the host PC's Tailscale IP (typically `100.x.x.x`) and port.
6. Friend: enter that IP and matching port, then select **Join Match**. A connection error or timeout returns to the lobby with troubleshooting guidance.
7. If Windows Firewall asks, allow this game on the trusted network used for the connection. If blocked, allow inbound UDP 24567 for the game/Tailscale interface. Do not disable the firewall. Tailscale avoids needing a public-IP router port-forward for this setup.
8. Both players choose four different characters. Use each row's placement dropdown to select a lane and depth. All four positions must differ. The whole roster is available for testing; this does not use the offline randomized draft.
9. Select **Lock In and Ready**. Once locked, your choices cannot change for that round. The battle starts only when both players are ready.
10. Between rounds, choose an upgrade for **each** character and adjust formation. Hover over upgrade names to read their effects. Lock in again. First to three wins takes the match. Both players select **Ready for Rematch** to restart.

The host is always the **lower** team; the friend is always the **upper** team. Lane numbers run left to right on the screen for both sides. Depth is relative to each team's own back edge. Players may use the same character on opposite teams; their upgrades remain separate.

## Current test scope

- Direct ENet connection over LAN or Tailscale; one host and one friend, no public matchmaking or ranked service.
- Private formation and upgrade submissions, with host validation of character names, unique cells, fixed teams, current round and offered upgrade choices.
- Host runs the existing battle, abilities and faction/class bonuses. Client receives position, health, shield, facing and pose snapshots 20 times per second; client never runs a second damage simulation.
- The friend sees simplified sprite movement, attack tint, HP labels and shield bubbles. Full client-side projectile/heal effects and the host's detailed animation treatment are future polish.
- Teams stay fixed within a match. Replacement/catch-up decisions are not part of this first PVP version. Initial picks are unrestricted roster selection, not a shared competitive draft.
- A simultaneous defeat or a round reaching 120 seconds is a draw. It awards no point; both players receive new upgrade choices and replay. Planning has no timer in this private mode.
- Leaving or disconnecting cancels the match. Return to Host/Join to start again. No reconnect, host migration or saved online session is included.
- This is for trusted friends. The host controls the simulation; it is not an anti-cheat or public-server system.
- The exported Windows preset uses the compatibility renderer. The editor's existing renderer setting is preserved.

## Test in Godot instead

Check out `feat/private-pvp`, import `project.godot` in Godot 4.4.1 or a compatible Godot 4 version, run the main scene and select **PRIVATE PVP TEST**. Both PCs must use matching files. The Windows export preset is included; install matching Godot export templates before exporting it yourself.

## Validation commands

```sh
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/private_pvp_smoke.gd
godot --headless --path . --script res://tests/board_combat_smoke.gd
godot --headless --path . --script res://tests/character_browser_smoke.gd
```

Run the following in two processes using port 24568. Start host first, then guest within 15 seconds:

```sh
godot --headless --path . --script res://tests/private_pvp_network.gd -- --role=host
godot --headless --path . --script res://tests/private_pvp_network.gd -- --role=guest
```

That test allows four seconds of real combat in each round, then accelerates the result to exercise three rounds, upgrade choices, rematch and disconnect. Add `--natural` to BOTH commands to run the first battle to its natural result instead. These are local two-process tests, not proof of connectivity between your separate Windows networks.

Visual checks require a rendering display:

```sh
godot --path . --rendering-method gl_compatibility --script res://tests/private_pvp_visual.gd
```

Source references: Godot 4.4 high-level multiplayer documentation https://docs.godotengine.org/en/4.4/tutorials/networking/high_level_multiplayer.html and the Tailscale installation/sharing documentation linked above.
