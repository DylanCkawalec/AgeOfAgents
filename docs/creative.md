# Creative.md – AgeOfAgents Creative Vision & Engineering Execution Guide

**Project:** AgeOfAgents  
**Version:** 1.0 (April 26, 2026)  
**Author:** Dylan Kawalec (ChaoticBeautys) in collaboration with Grok AI  
**Purpose:** This document translates the **pure creative vision** of AgeOfAgents into precise, actionable instructions for the engineering team / AI coding agents.  
It sits alongside the official PRD (LaTeX) and tells you exactly **what should feel magical** and **how to make it real** in the openage fork[](https://github.com/DylanCkawalec/openage).

---

## 1. Overall Creative Vision

AgeOfAgents is **not** just a tool — it is a living strategy game where you are the supreme commander of an AI coding army conquering and building the ultimate protocol.

Imagine opening Age of Empires II… but the map is **your actual massive monorepo**. Peasants are now Coder Agents, knights are Architect Agents, castles are microservices, and gold mines are critical dependency files. Every click, every hotkey, every visual explosion of progress feels exactly like classic AoE2 — except you are shipping production code in real time with your own local Ollama models.

**Core Feeling to Preserve:**
- The joy and muscle-memory of Age of Empires II
- The god-like oversight of an RTS command center
- The futuristic sci-fi thrill of commanding hundreds of autonomous AI agents
- The satisfaction of watching your protocol literally grow and evolve on the battlefield

**Tagline:** “Build empires of code. Command legions of agents. Win the protocol.”

---

## 2. Core Metaphors & Theming (Creative Replacements)

Use this exact mapping when implementing any game object:

| AoE2 Element              | Creative AgeOfAgents Replacement                                      | Visual / Thematic Style                     | Engineering Hook (what to implement) |
|---------------------------|-----------------------------------------------------------------------|---------------------------------------------|--------------------------------------|
| Map / Terrain             | Living architecture diagram of your monorepo                          | Procedural terrain with glowing circuit-like rivers, neon data nodes | Procedural map generator using folder depth |
| Units (peasants, etc.)    | AI Agents (Coder, Planner, Reviewer, Executor, Researcher, etc.)     | Sci-fi holographic avatars with role icons  | nyan unit definitions + status color system |
| Buildings                 | Code modules, services, sub-repos, folders                           | Futuristic towers, data citadels, server farms | Clickable entities that spawn context menus |
| Resources (food/wood/etc) | Compute (CPU), Tokens, Memory, Data                                   | Floating glowing orbs / energy crystals     | Real-time system metrics bridge |
| Tech Tree                 | Agent skill upgrades & new capabilities                               | Holographic research lab UI                 | nyan tech system + Ollama model swaps |
| Fog of War                | Unexplored code sections / unknown dependencies                      | Dark nebula that lifts as agents explore    | Dynamic visibility based on agent scans |
| Campaign / Scenario       | High-level mission orchestrator (“Refactor entire protocol”)         | Epic quest log with cinematic briefings     | Campaign JSON + AgentCraft-style decomposition |
| Minimap                   | Overview of entire monorepo structure                                 | Mini circuit-board map                      | openage minimap + folder hierarchy overlay |

**Global Theme:** Cyber-futuristic “Digital Age of Empires”. Keep the classic AoE2 UI chrome (gold borders, parchment feel) but tint everything with neon cyan/magenta/purple and subtle terminal glows.

---

## 3. Visual Style Guide

- **Color Palette:** Deep space black + neon cyan accents, magenta highlights, electric blue for working agents, crimson red for errors.
- **Unit Avatars:** Small holographic figures (use simple SVG or low-poly models). Each role has a unique silhouette + floating status badge.
- **Animations:**
  - Idle: gentle pulse
  - Working: coding particles / terminal text floating upward
  - Error: red sparks + alarm strobe
  - Victory: golden data explosion
- **Camera:** Classic AoE2 zoom + VibeCraft infinite pannable canvas (seamless blend).
- **Fonts:** Mix of classic AoE serif titles + modern monospace for terminal windows.
- **Particle Effects:** Use openage particle system for:
  - Token spend = glowing currency flying into buildings
  - Commit success = green data beams shooting into the sky
  - Agent collision = warning electric arcs

**Custom Asset Folder:** `assets/ageofagents/` (create this in the fork). All new sprites, icons, sounds go here.

---

## 4. Creative Feature Specs (Merged from All 4 Inspirations)

### 4.1 AgentCraft Ideas (Video: https://www.youtube.com/watch?v=kR64LOqBBCU)
- **Hero Units** → Named, upgradable “legendary” agents with skill scrolls and achievements.
- **Alliance Hall** → Beautiful multiplayer lobby with shared battlefield (real-time agent visibility across machines).
- **Review Bundles** → When an agent finishes a task, it drops a glowing “scroll” on the map. Click it → cinematic review mode with diff heatmaps and video replay.
- **Heat Maps** → Buildings glow brighter where many agents are working (visual density of activity).
- **Quest System** → Floating quest markers above buildings (“Implement auth service”).

### 4.2 Arcane Agents Ideas
- **Live Terminal Windows** → When you select an agent, a resizable xterm.js-style window pops up attached to the unit (streaming real Ollama output).
- **Auto Status Detection** → Agents automatically change color and play voice lines (“Task complete!”, “Error in build!”).

### 4.3 VibeCraft Ideas
- **Infinite Canvas** → The battlefield is infinite. You can drag folders from Finder directly onto the map and they become new buildings.
- **Entity Placement** → Folders, terminals, and agents are all draggable “units” on the same plane.

### 4.4 GastownRTS Ideas
- **Classic RTS HUD** → Resource bars at top, command cards on the right, minimap bottom-left, quest log on the side.
- **Specialized Roles** → Visually distinct unit classes with unique command cards.

---

## 5. Gameplay Loops & User Experience Flows (Creative Direction)

**Primary Loop:**
1. Open AgeOfAgents → select or auto-detect your massive monorepo root.
2. The map explodes into view — your protocol as a living battlefield.
3. You issue commands exactly like AoE2:
   - Select 10 Coder Agents → right-click a building → they march over and start working.
   - Hold Shift to queue multiple tasks.
   - Press “Q” hotkey to spawn a new Planner Agent with your voice prompt.
4. Watch real-time progress: agents write code, run tests, commit, and create PRs **inside** the game world.
5. Zoom in → terminal windows show live output. Zoom out → see the entire empire of code at a glance.

**Epic Moments to Engineer:**
- “All agents, focus fire on the legacy auth module!”
- Watching 50 agents light up the map like a Christmas tree during a full refactor.
- A legendary agent earning an achievement and glowing gold on the battlefield.

---

## 6. Sound & Immersion Design

- **Background Music:** Epic orchestral + cyber synth (think AoE2 soundtrack meets Blade Runner).
- **Unit Voice Lines:** Classic AoE2-style (“Yes, my liege!” becomes “Ready to code!”, “Error detected!”).
- **Sound Effects:** Terminal typing, successful compile chimes, error buzzers, data upload whooshes.
- **Spatial Audio:** Agents farther away sound quieter (openage already supports this).

---

## 7. Creative To-Do List for Engineering Implementation

**Priority 1 – Must Feel Magical**
- [ ] Implement nyan definitions for 8 core agent roles with unique sprites and command cards.
- [ ] Live terminal streaming windows that follow their unit on the map (draggable & pinnable).
- [ ] Procedural map generator that turns any folder tree into terrain + buildings.
- [ ] Real-time status color system + particle feedback.
- [ ] Infinite canvas mode toggle that blends with classic AoE2 camera.

**Priority 2 – Polish & Delight**
- [ ] Review bundle cinematic mode.
- [ ] Heat map visualizer for agent density.
- [ ] Drag-and-drop folder → building conversion.
- [ ] Voice line system (text-to-speech fallback using macOS built-in voices).
- [ ] Custom sci-fi UI skin that can be toggled with classic AoE2 skin.

**Priority 3 – Future-Proof Creativity**
- [ ] Modding guide: “How to add a new agent role in 5 minutes using nyan + SVG icon.”
- [ ] Mobile companion PWA that shows a minimap of your battlefield.

---

## 8. Final Creative Mandate

Every single screen, animation, and interaction must make the user feel:
> “I am not just managing agents — I am commanding an empire of intelligence that is actively building the future.”

If it doesn’t feel as fun and epic as playing Age of Empires II while simultaneously shipping real production code with your local Ollama models, it is not done.

**Engineering teams / AI coding agents:** Use this document as your creative bible. When in doubt, ask: “Does this make the player feel like a god of code?”

---

**Let’s build the masterpiece.**

This `creative.md` file is now complete and ready to be dropped into the root of the AgeOfAgents repository.

You can copy-paste the entire content above into `creative.md`.