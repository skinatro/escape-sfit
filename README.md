# Escape-SFIT Stage 2

## License
- SPDX: MIT

## Attributions

- [Skybox: Greg Zaal](https://polyhaven.com/a/kloofendal_48d_partly_cloudy_puresky)

## Contributors

<a href="https://github.com/OWNER/REPO/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=skinatro/Escape-SFIT" />
</a>

## Requirements
- Godot Engine 4.4 (Project uses Forward+)
- GPU with S3TC/BPTC support recommended (sky panorama EXR, VRAM textures)

## Getting Started
- Open the project in Godot 4.4.
- The default main scene is [Debug/debug.tscn](Debug/debug.tscn).
- Press Play to run.

Main menu is available at [Scenes/main_menu.tscn](Scenes/main_menu.tscn) with script [`_on_start_pressed`](Scripts/main_menu.gd) that switches to the debug scene.

## Controls
- Move: W/A/S/D (move_fw/move_left/move_bw/move_right in [project.godot](project.godot))
- Jump: Space (move_jump)
- Sprint: Shift (move_sprint)
- Mouse look: Move mouse (captured in [`_ready`](Scripts/PlayerScript.gd))

Player logic: see [`PlayerScript.gd`](Scripts/PlayerScript.gd). Head bobbing, FOV kick, gravity, and sprint handled in `_physics_process`.

## Key Features

### Player + HUD
- Player controller: [Scripts/PlayerScript.gd](Scripts/PlayerScript.gd), instantiated in [Debug/debug.tscn](Debug/debug.tscn).
- Boss health bar: [Scripts/boss_health_bar.gd](Scripts/boss_health_bar.gd) attached to HUD node in [Debug/debug.tscn](Debug/debug.tscn).

### Inventory & Pickups
- Inventory UI: [Scenes/inventory.tscn](Scenes/inventory.tscn) with logic [`set_inventory_data`](Scripts/inventory.gd) and population via [`populate_item_grid`](Scripts/inventory.gd).
- Inventory interface bridge: [`set_player_inventory_data`](Scripts/inventory_interface.gd) wires player inventory to the UI in [`PlayInvConn.gd`](Scripts/PlayInvConn.gd).
- Slot visuals: [`set_slot_data`](Scripts/slot.gd) for [Scenes/slot.tscn](Scenes/slot.tscn).
- Pickups: [Scenes/pickup.tscn](Scenes/pickup.tscn) with behavior in [Scripts/pickup.gd](Scripts/pickup.gd). On body enter, tries to add to player inventory and frees on success.
- Example item data: [GameResources/Items/item1.tres](GameResources/Items/item1.tres) using [`ItemData`](Scripts/item_data.gd) and shown by [`SlotData`](Scripts/slot_data.gd).
- Player inventory resource assigned in [Debug/debug.tscn](Debug/debug.tscn) via [GameResources/PlayerInventory.tres](GameResources/PlayerInventory.tres).

### Door + Cutscene
- Sliding door and trigger: nodes and animations in [Debug/debug.tscn](Debug/debug.tscn), door logic in [Scripts/slide_door_down.gd](Scripts/slide_door_down.gd).
- Cutscene camera animations are authored in the scene AnimationPlayers (see “DoorCutscene” in [Debug/debug.tscn](Debug/debug.tscn)).

### Fade Utility
- Fade in/out helper scene: [Scenes/Fade.tscn](Scenes/Fade.tscn) with animation tracks “fade_in” and “fade_out”.

## Project Structure
- Assets: art and sky textures (e.g., EXR panorama).
- Debug: prototype scene, placeholder textures, and test pickups.
- GameResources: items and player inventory resources.
- Scenes: UI and utility scenes (inventory, slot, fade, main menu).
- Scripts: gameplay and UI scripts (player, inventory, pickups, door, menu).

## How to Add a New Item
1. Create an Item resource using [`ItemData`](Scripts/item_data.gd) (e.g., duplicate [GameResources/Items/item1.tres](GameResources/Items/item1.tres)).
2. Optionally create a [`SlotData`](Scripts/slot_data.gd) resource that points to your Item.
3. Assign the SlotData to a pickup instance in [Scenes/pickup.tscn](Scenes/pickup.tscn) or place one in [Debug/debug.tscn](Debug/debug.tscn).
4. The inventory grid will auto-populate via [`populate_item_grid`](Scripts/inventory.gd).

## Build/Export
- Use Godot’s Export feature and set up presets as needed. Ensure textures marked as VRAM-compressed remain compatible with your target platform.

## Known TODOs
- Add Multiplayer Code (Maybe a server client model?)
- Swap Out Assets
    - Create Character Models
    - Create SFIT for map
- Add mini-game specific stuff
    - Lazer Room with a bit of platforming
    - Enemy spawning and kill em
    - 
    - 
- I think i cant drop inventory pickups as well

