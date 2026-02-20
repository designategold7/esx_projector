# ESX Holographic Projector

A high-performance, server-synchronized presentation system designed for complex roleplay environments like the CID or Highway Patrol. 

Unlike traditional projector scripts that use `AddReplaceTexture` (which notoriously causes `ERR_MEM_EMBEDDEDALLOC_ALLOC` crashes and invisible map textures), this system utilizes a spatial 3D render loop (`DrawSprite`) and a headless Chromium container. It renders presentations as a holographic billboard anchored to specific coordinates, guaranteeing perfect viewing angles, absolute server synchronization, and zero texture memory leaks.

## Key Features

* **Zero Texture Leaks:** Bypasses `.ytd` manipulation entirely. Projects the CEF instance directly into the 3D world space.
* **Perfect Server Sync:** Presentations are managed via a server-sided image array. Late-joining players instantly sync to the active slide.
* **ox_target Integration:** Presenters control the slides natively by interacting with a physical prop (like a laptop or podium) in the briefing room.
* **Secure Execution:** Strict job and rank hierarchy checks prevent unauthorized personnel from hijacking the presentation.
* **Emergency Injection:** Authorized command members can inject new image URLs live during a briefing using an `ox_lib` input dialog.

## Dependencies

Ensure the following resources are installed, running, and up-to-date:
* `es_extended` 
* `ox_lib`
* `ox_target`

## Installation

1. Clone the repository into your `resources` folder:
   ```bash
   git clone [https://github.com/designategold7/esx_projector.git](https://github.com/designategold7/esx_projector.git)
   ```
2. Ensure your file structure perfectly matches the following:
   ```text
   esx_projector/
   ├── html/
   │   └── index.html
   ├── client.lua
   ├── server.lua
   └── fxmanifest.lua
   ```
3. Add the resource to your `server.cfg`. **Start order is critical.**
   ```text
   ensure ox_lib
   ensure ox_target
   ensure es_extended
   ensure esx_projector
   ```

## Configuration

Before restarting your server, you must adapt the script to your specific MLO and departmental hierarchy.

### 1. Spatial Coordinates (`client.lua`)
You must define where the projector screen hovers in the air, and where the presenter stands to control it.
* `screenCoords`: The `vector3` coordinates on the wall where the presentation will be drawn.
* `laptopCoords`: The `vector3` coordinates of the physical object (laptop/podium) the presenter must `ox_target` to change slides.

### 2. The Image Array (`server.lua`)
Export your presentation (e.g., Google Slides, Case Jackets) as individual image files and upload them to a direct image host.
* Place the direct URLs into the `slidesArray` at the top of `server.lua`. 
* **CRITICAL:** The URLs *must* end in a valid image extension (e.g., `.png`, `.jpg`). Do not use album or gallery links.

### 3. Rank Permissions (`server.lua`)
Update the `IsAuthorizedToPresent(xPlayer)` function to match your database's exact job and grade names. By default, it requires leadership or high command ranks within the `police` or `cid` jobs.

## Usage Guide

1.  **Start Presentation:** Target the configured laptop and select "Start Presentation" to turn on the screen and load Slide 1.
2.  **Navigation:** Target the laptop to advance to the "Next Slide" or return to the "Previous Slide".
3.  **Emergency Add:** If a new piece of evidence is discovered mid-briefing, select "Emergency Add URL" to append a new direct image link to the end of the live presentation.
4.  **Clear:** Select "Turn Projector Off" to instantly terminate the presentation and clear the screen for all players.
