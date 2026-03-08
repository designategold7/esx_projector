#  Standalone Holographic Projector 

A lightweight, standalone FiveM resource that allows players to dynamically place and anchor holographic web-screens in the game world. Designed for the Arkansas State Roleplay community to facilitate realistic briefings without external dashboard dependencies.

##  Features
* **Dynamic Placement**: Use a ghost-prop preview to align your hologram perfectly before anchoring.
* **Direct URL Injection**: In-game prompt allows you to point the projector at any valid `http/https` URL.
* **VRAM Optimized**: Uses unique runtime texture dictionaries (TXD) to prevent the "Purple Texture" memory leak.
* **Standalone Architecture**: No ESX/QB-Core or Database dependencies required.

##  Installation
1. Download the repository files.
2. Place the `esx_projector` folder into your server's `resources` directory.
3. Add `ensure esx_projector` to your `server.cfg`.
4. (Optional) Edit the `prop_model` in `client.lua` if you wish to use a custom holographic entity.

##  How to Use
1. Use the command `/hologram` in-game.
2. Move your crosshair to position the "Ghost" preview.
3. Press **[E]** to lock the position.
4. An input box will appear—type or paste your desired URL (e.g., `https://google.com`).
5. The hologram will anchor and begin streaming.

##  Troubleshooting & Optimization
* **Blank Screen**: Ensure the URL begins with `https://`. If it still fails, check your local firewall settings.
* **Texture Loss**: This script is capped at 720p. Avoid placing more than 5 holograms in a single area to stay within GTA V's VRAM limits.
* **Performance**: The script runs at **0.00ms** when idle.

---
*Maintained by Poke Bayou Farms LLC (@designategold7)*
