# AgeOfAgents – 2-Week Execution Plan for AI Coding Agents (Opus 4.7 / Claude)

**Project:** AgeOfAgents  
**Version:** 1.0  
**Date:** April 26, 2026  
**Target AI Agent:** Claude Opus 4.7 (or equivalent high-context coding agent)  
**Goal:** Build a complete, production-ready, native-macOS-first fork of AgeOfAgents on top of https://github.com/DylanCkawalec/openage using ONLY the provided reference documents.

## Reference Documents (Mandatory – All Must Be Open in Context)

The AI coding agent **MUST** treat these five files as the single source of truth:

1. **ageofagents_prd_1.tex** – Core PRD (original vision, functional requirements, roadmap Phases 0–4, acceptance criteria).
2. **ageofagents_prd_2.tex** – Extended PRD (macOS-native build instructions, Homebrew/Qt6/nyan dependencies, Windows VM fallback, platform-specific acceptance criteria).
3. **ageofagents_wip.md** – Whitepaper (high-level vision, creative reimagining of every AoE mechanic, agents with souls/memories/personalities, phased Ages, kingdom-building narrative).
4. **creative.md** – Creative Bible (visual style guide, metaphors table, animations, particle effects, sound design, priority to-do list, “god of code” mandate).
5. **agentsofchaos_wip.tex** – Formal governance reference (AOC protocol). Use this for advanced soul/memory/skill/sub-agent mechanics, typed reserves, admissibility checks, and Hall of Heroes persistence. It provides the mathematical rigor for “souls”, skill contracts, and long-term agent legacy that the whitepaper references.

**Usage Rule:** Every single commit, PR, or implementation decision must cite the exact section/document it fulfills. Example comment:  
`// PRD-2 § Platform Support + Whitepaper §3 + creative.md §4.2`

---

## Overall Strategy (How the AI Agent Executes)

- **Iterative & Reference-Driven:** Work strictly in the order of PRD Phases 0–4.
- **Dual-Track Development:** 
  - Track A: Engine + modding (openage C++/Python/nyan).
  - Track B: Agent orchestration backend (Arcane-style tmux + Ollama + monorepo discovery).
- **Daily Deliverables:** End-of-day GitHub PR with screenshots + self-review against acceptance criteria.
- **Testing:** Every major feature must be tested on a real monorepo (user’s protocol codebase) with Ollama running locally.
- **macOS-First:** All builds and smoke tests run natively on macOS using PRD-2 instructions.
- **Creative Mandate:** Every UI/animation/particle must feel “magical” per creative.md §8.

**Total Duration:** 14 days (2 weeks) assuming full-time dedicated AI coding agent.

---

## Week 1 – Foundation & Core Engine (Days 1–7)

### Day 1 – Phase 0: Fork & Setup (PRD-1 & PRD-2)
- Clone https://github.com/DylanCkawalec/openage
- Follow PRD-2 § Platform Support exactly: install all Homebrew/Qt6/nyan dependencies on macOS.
- Build and run vanilla openage (verify native macOS launch).
- Create `mods/ageofagents/` directory + `creative.md`, PRD PDFs, and whitepaper as reference files inside the repo.
- Add macOS CI workflow (`.github/workflows/macos.yml`).
- Commit: “Phase 0 complete – native macOS build verified”.

### Day 2 – Procedural Map Generator (PRD-1 §2 + creative.md §2 + whitepaper §5)
- Implement monorepo auto-discovery (recursive scan, git worktrees, glob patterns – Arcane Agents logic).
- Turn folder tree into procedural terrain + buildings (folders = terrain features, sub-repos = regions).
- Fog-of-war system (unexplored code = dark nebula).
- Integrate with openage map system.
- First screenshot: entire user monorepo rendered as battlefield.

### Day 3 – Unit & Building System (creative.md §2 + whitepaper §2)
- Define 8 core agent roles via nyan (Coder, Planner, Reviewer, Executor, Researcher, Architect, Validator, Legendary Hero).
- Replace AoE units with holographic sci-fi avatars (status colors per creative.md §3).
- Buildings = clickable code modules/folders.
- Drag-and-drop folder from Finder → becomes building (VibeCraft style).

### Day 4 – Resource & Live Metrics Bridge (whitepaper §2 + PRD-1 §3)
- Map AoE resources → real-time CPU/GPU/Tokens/Memory/Data.
- Floating energy crystals + pulsing resource nodes.
- Live system metrics bridge (Python backend).

### Day 5 – Live Terminal Streaming & Status Detection (Arcane Agents + PRD-1 §3 + creative.md §4.2)
- Integrate tmux + node-pty/xterm.js style windows attached to units.
- Auto status detection (idle/green, working/blue, error/red).
- Terminal windows follow units on map (draggable/pinnable).

### Day 6 – RTS HUD & Infinite Canvas (GastownRTS + VibeCraft + PRD-1 §3)
- Classic RTS HUD (minimap, resource bars, command cards, quest log).
- Infinite pannable/zoomable canvas blended with classic AoE2 camera.
- Heat maps (AgentCraft).

### Day 7 – Agent Spawning & Basic Orchestration (PRD-1 §4 + whitepaper §3)
- Spawn agents via RTS controls or voice/text prompt.
- YAML runtime config for any Ollama model (Arcane style).
- Container isolation (Docker sandbox per agent).
- First end-to-end test: spawn 5 agents, assign to folders, watch them code.

**Week 1 Milestone:** Fully playable prototype where you can spawn agents, see them move on the monorepo map, and watch live terminals.

---

## Week 2 – Polish, Souls, Ages & Production Readiness (Days 8–14)

### Day 8 – Campaign / Quest System & Review Bundles (AgentCraft + PRD-1 §4 + creative.md §4.1)
- High-level mission orchestrator (“Refactor entire protocol”).
- Quest markers, review bundles (scrolls with diff heatmaps + cinematic replay).
- Alliance Hall multiplayer skeleton.

### Day 9 – Soul, Memory & Personality System (whitepaper §3 + agentsofchaos_wip.tex)
- Every agent gets unique name + personality.
- Skill inheritance + sub-agent training.
- Long-term memory (vector store + SQLite).
- Soul persistence: when agent “dies”, soul moves to Hall of Heroes building.
- Future agents can visit Hall and inherit wisdom (AOC formalisms).

### Day 10 – Phased Ages & Time Progression (whitepaper §4)
- Dark → Feudal → Castle → Imperial Ages.
- Automatic “year” advancement based on milestones (commits, tests passed).
- Age slider (fast-forward/slow-down).
- Age-specific bonuses (research speed, agent training, etc.).

### Day 11 – Command Cards, Hotkeys & Chat (whitepaper §2 + creative.md §5)
- Full RTS command cards.
- Keyboard-first hotkeys.
- Click any agent → contextual chat with full history and personality voice lines.
- Voice line system (macOS TTS fallback).

### Day 12 – Particle Effects, Animations & Sound (creative.md §3 & §6)
- All animations and particles per creative.md.
- Epic orchestral + cyber synth soundtrack.
- Spatial audio.

### Day 13 – Production Polish & Extensibility (PRD-1 § Phase 3–4)
- Container isolation + review bundles complete.
- Mobile PWA companion (minimap view).
- Full nyan modding example + documentation (“add new agent role in 5 minutes”).
- Custom sci-fi UI skin toggle.

### Day 14 – Final Integration, Testing & Release (Acceptance Criteria)
- Run full acceptance criteria checklist from both PRDs.
- Test with user’s real massive monorepo + Ollama.
- Self-review against creative.md “god of code” mandate.
- Prepare public GitHub release under GPLv3.
- Final commit + documentation.

**Week 2 Milestone:** A complete, beautiful, soulful, epic RTS command center that feels like playing Age of Empires II while commanding a living kingdom of AI agents building real code.

---

## Success Criteria (Must All Be Met)

- Native macOS build works perfectly (PRD-2).
- Full monorepo visual representation + live agent orchestration.
- Agents have names, personalities, memories, and souls (Hall of Heroes).
- All four inspiration sources (AgentCraft, Arcane, VibeCraft, GastownRTS) are visibly merged.
- Feels magical and fun per creative.md §8.
- 100% local with Ollama.

---

**Final Instruction to the AI Coding Agent (Opus 4.7):**

You now have everything.  
Start with Day 1.  
Reference the exact document + section in every commit message.  
When in doubt, open creative.md first — it is your creative bible.  
When you need formal rigor for souls/memory, open agentsofchaos_wip.tex.  
Build the masterpiece.

The Age of Agents begins now.

**Let’s build the kingdom.**
