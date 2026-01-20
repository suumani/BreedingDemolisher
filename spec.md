# Breeding Demolisher — Specification (spec)

This document records the **design intent, specifications, and agreed decisions** of the Breeding Demolisher mod.  
Its purpose is to preserve criteria, priorities, and the boundary between bugs and intended behavior that cannot be fully explained in the Mod Portal or README.

---

## 0. Goals and Non-goals

### 0.1 Goals (Purpose)
- Provide an experience where demolishers are treated not as a one-time threat, but as a **growing ecosystem**
- Allow threats to escalate if left unattended, while keeping the game from breaking through **caps and control logic**
- Create meaningful decision-making around high-density combat, containment, culling, and breeding

### 0.2 Non-goals
- Guarantee that the player can always manage demolishers safely
- Turn eggs or breeding into a simple collection mechanic (there must always be a cost to neglect)
- Completely replace global enemy behavior

---

## 1. Mod Positioning
- Category: Content addition / Enemies
- Target: Factorio 2.0 (Space Age)
- Core experience: Managing proliferating demolishers through *hunt / ignore / raise*

---

## 2. Core Gameplay Loop
1. Eggs are generated through time and combat
2. Eggs hatch, increasing the population
3. Population growth creates pressure, requiring defense, culling, and movement control
4. The player chooses between containment, thinning, or breeding

---

## 3. Natural Breeding (Wild)

### 3.1 Purpose of the Population Cap
- The cap exists to stabilize performance (UPS)
- In large, explored maps where standard demolishers are widely and naturally distributed,
  counting all individuals equally would prevent breeding events from occurring
- Therefore, the cap is designed to **avoid blocking entities that are meant to increase through breeding or additional content**

### 3.2 Counted Population
- The population used for cap checks excludes the following enemy demolishers:

#### Exclusion Conditions
- **The three standard types (small / medium / big)**
- And **quality is `nil` or `normal`**

Notes:
- Standard types with customized quality (non-normal) are *not* excluded
- Non-standard demolishers added by this mod or related mods are included in cap calculations
- Standard demolishers with no quality customization are considered part of natural map generation
  and are neither targets nor controllable entities of this mod

### 3.3 Cap Scaling by Evolution
- The cap increases stepwise with the evolution factor
- Higher evolution leads to higher pressure in late game

#### Evolution → Cap (counted population)
- evo ≤ 0.05 → cap 40  
- evo ≤ 0.15 → cap 55  
- evo ≤ 0.25 → cap 70  
- evo ≤ 0.35 → cap 85  
- evo ≤ 0.45 → cap 100  
- evo ≤ 0.55 → cap 115  
- evo ≤ 0.65 → cap 130  
- evo ≤ 0.75 → cap 145  
- evo ≤ 0.85 → cap 160  
- evo ≤ 0.95 → cap 175  
- evo ≤ 0.98 → cap 190  
- evo > 0.98 → cap 200  

### 3.4 Egg Species Determination
- Eggs normally hatch into the same species as their parent
- Once evolution exceeds certain thresholds, eggs may mutate into **higher or derived species**
- Mutation is *additive*, not replacement; lower-tier eggs still appear alongside higher ones

### 3.5 Mutation Rate
- Mutation probability starts at **10%** upon reaching the threshold
- It increases linearly to **30% at evolution 1.0**
- General rule:
  - evo < threshold → 0%
  - evo ≥ threshold → 10% → 30% (at evo 1.0)

> These values apply uniformly across all mutation rules below.

### 3.6 Mutation Evaluation (Important)
- Mutation is evaluated **once per parent**
- If mutation occurs, the target is selected from a mutation table
- Even if multiple mutation targets exist, probabilities must not stack

---

## 3.7 Canonical Evolution (Main Line)
The canonical evolution line is the primary progression and must be preserved over derived lines.

Mutation thresholds:
- evo ≥ 0.25  
  - **small** → **medium** egg
- evo ≥ 0.50  
  - **medium** → **big** egg
- evo ≥ 0.75  
  - **big** → **behemoth** egg (if behemoth exists)

> Behemoth is a higher-tier species of the normal line added by this mod.

---

## 3.8 Derived Evolution (Speedstar Line)
The speedstar line is treated as a derived series with its own internal canonical progression.
- Speedstar species do not exist in this mod alone
- They are enabled only when related mods (e.g. SpeedstarDemolisher / BossDemolisher) are installed
- If those mods are absent, all rules in this section are ignored

Mutation thresholds:
- evo ≥ 0.85  
  - **medium** → **speedstar small** egg
- evo ≥ 0.95  
  - **big** → **speedstar medium** egg  
  - **speedstar small** → **speedstar medium** egg
- evo ≥ 0.98  
  - **behemoth** → **speedstar big** egg  
  - **speedstar medium** → **speedstar big** egg

---

## 3.9 Mutation Table Policy
- When multiple mutation targets exist, selection is performed via table-based random choice
- Derived lines must not undermine the canonical evolution line
- Exact weighting is a balance concern and is not fixed in this specification

---

## 3.10 Excluded from Breeding (FATAL Types)
- Gigantic / crazy-king and other **FATAL-class** demolishers are added by related mods
- Due to extreme size, mobility, and terrain impact, they are excluded from breeding and mutation
- Such entities must be managed through events, scenarios, or dedicated spawn logic

---

## 4. Player Interaction and Pets

### 4.1 Becoming a Pet
- Eggs may drop when wild demolishers are defeated
- Demolishers hatched from eggs are treated as **pets**
- Pets belong to one of the following factions:
  - enemy (wild)
  - demolishers (new species)
  - player (friendly)

### 4.2 Growth
- Pets gain growth by defeating nearby enemies
- Growth is stored as an internal parameter and visible via UI
- Growth is used for breeding, evolution, and death-drop checks

### 4.3 Breeding (Pets)
- Breeding is evaluated approximately once per minute
- Basic conditions:
  - Parent is mature (growth ≥ 20)
  - Parent has reached a **new growth stage (every 20 points)**
- Only **one breeding chance per growth stage** is allowed

### 4.4 Partner Search
- When a breeding chance occurs, nearby pets are searched
- If multiple valid partners exist:
  - The **nearest mature individual** is selected
- Search radius is intentionally broad and designed to be practical
  (approximately **240 tiles in radius**)

### 4.5 Breeding Outcome
- If a mature partner exists: **two-parent breeding**
- If no partner exists: **breeding does not occur** (as of v0.5.5)
- Breeding produces eggs that **carry genetic information**
- Clear notifications are shown when breeding occurs

---

## 5. Genetics

### 5.1 Genetic Data Storage
- Genetic data is stored in **egg item tags**
- Genetic data persists across:
  - Transport
  - Storage
  - Stacking
  - Hatching

### 5.2 Inheritance
- Eggs produced through breeding may inherit parent traits and quality
- Two-parent breeding is designed to yield more favorable results than single-origin eggs

---

## 6. Egg Processing and Evolution Routes

### 6.1 Planetary Restriction (Important)
- Demolishers are native to **Vulcanus**
- The following egg processes are only possible on Vulcanus:
  - Size evolution (small → medium → big)
  - New species evolution
  - Freezing / unfreezing
- This restriction is implemented via a **pressure 4000** surface condition

### 6.2 Dual Evolution Routes
New species evolution has two parallel routes:

#### A. Cryogenics (Deterministic Route)
- High cost, guaranteed result
- Intended for end-game progression
- Produces a new species demolisher egg on success

#### B. Biochamber (Probabilistic Route)
- High cost, probabilistic result
- Success rate: **20%**
- Failure produces **spoilage**
- Intended as a risky mid-to-late game option

### 6.3 New Species and Friendly Demolishers
- New species demolishers (force=demolishers) are an **intermediate stage**
- They ultimately evolve into **friendly demolishers (force=player)**
- This progression is explicitly described in recipes and descriptions

---

## 7. Egg Drops on Death

- Pets may drop eggs when defeated
- Conditions:
  - Growth must exceed a defined threshold
- The type of egg dropped depends on the pet’s faction
- Pet death always triggers a **dedicated notification**

---

## 8. Difficulty and Pressure Design
- The cap is not merely to suppress growth, but to balance:
  - Performance stability (UPS)
  - Increasing pressure over progression
  - Continued breeding events on large maps

---

## 9. Movement Behavior and Pressure Diffusion

### 9.1 Movement Scope
- The mod assumes large maps with many standard demolishers
- Standard species are not suppressed or restricted
- Pressure is managed by adjusting **which entities are counted**
- Movement control applies only to:
  - **manis-small / manis-medium / manis-big**
- Gigantic and King-class demolishers are excluded due to excessive impact
- Movement selection and execution are handled by dedicated planners/executors

### 9.2 Periodic Movement
- Movement is evaluated approximately once per minute
- The goal is pressure diffusion and shifting battle lines
- Destinations are chosen based on generated chunk areas

### 9.3 Density Cleanup (Legacy Data)
- Some saves contain abnormal concentrations of default demolishers
- These are treated as ecological cleanup, not bug fixes

#### Cleanup Rules
- Targets:
  - Default demolishers (no quality filtering)
- Method:
  - Randomly sample a small number (e.g. up to 5)
  - If excessive density is detected within a radius (e.g. 50 tiles)
- Effect:
  - Select **one** entity from that area for relocation
- Constraints:
  - At most one additional relocation per evaluation
  - Performance stability is prioritized

---

## 10. Reaction to Rocket Launches
- From mid-game onward, rocket launches gradually attract demolishers
- This is expressed as aversion to vibration and activity

---

## 11. Determinism and Multiplayer
- All randomness is deterministic
- RNG is centrally managed within the mod
- Reproducibility issues are treated as bugs

---

## 12. Save Data
- All global data is stored under `storage`
- Any changes requiring migration must document the procedure

---

## 13. Handling of This Specification
- This document takes precedence over README and Mod Portal descriptions
- When implementation diverges:
  - Decide whether implementation defines the behavior, or
  - Update this specification explicitly