# Breeding Demolisher — Specification (spec)

This document records the **design intent, specifications, and agreed rules** of the Breeding Demolisher mod.  
Its purpose is to preserve decision criteria, priority rules, and the boundary between *intended behavior* and *bugs* that cannot be fully explained in the Mod Portal or README.

---

## 0. Purpose and Non-goals

### 0.1 Purpose
- To treat Demolishers not as a one-time threat, but as a **growing ecosystem**
- To ensure that neglect increases danger, while **hard caps and control logic** prevent total game collapse
- To create meaningful player decisions around **containment, thinning, and breeding**

### 0.2 Non-goals
- Guaranteeing a consistently safe or manageable difficulty
- Reducing eggs or breeding to a mere collection mechanic (neglect must always carry risk)
- Replacing all global enemy behavior systems

---

## 1. Mod Positioning
- Category: Content Addition / Enemies
- Target: Factorio 2.0 (Space Age)
- Core Experience: Managing proliferating Demolishers through **hunt / neglect / controlled breeding**

---

## 2. Core Gameplay Loop
1. Eggs are generated through time passage or combat
2. Eggs hatch, increasing the population
3. Population growth creates pressure, requiring defense, elimination, or relocation
4. The player chooses between **containment, culling, or breeding**

---

## 3. Natural Breeding (Wild)
- Demolishers reproduce at fixed intervals, generating eggs
- Eggs hatch after a fixed duration
- The total population is capped
- Breeding is regulated based on **current population vs. cap**
- Eggs may rarely drop when a Demolisher is defeated
- Depending on evolution factor:
  - Hatched Demolishers may gain higher quality
  - Egg dispersal range may increase
- Population cap:
  - **Fixed at 200** to prioritize performance stability
- Each breeding cycle also enforces an upper limit on generated eggs to prevent spikes

---

## 4. Player Interaction and Pets
- Eggs may be obtained by defeating wild Demolishers
- Demolishers hatched from eggs are treated as *pets*
- Pets may have alignment states (hostile / neutral / friendly)
- Mature pets may begin breeding
- Offspring may inherit traits or abilities from parents
- Eggs produced via breeding are more likely to have higher quality than dropped eggs

---

## 5. Difficulty and Pressure Design
- This mod targets players who prefer **high-risk, high-density combat**
- Early-game unfairness is mitigated, while **neglect-based escalation** is preserved
- As progression advances, the following intensify:
  - Individual quality
  - Breeding success rate
  - Movement and dispersion pressure

---

## 6. Movement Behavior and Pressure Diffusion

### 6.1 Movement Target Scope
- This mod controls movement only for the following Demolishers:
  - **manis-small / manis-medium / manis-big**
- Gigantic and King-class Demolishers are explicitly excluded
- Movement targets are selected via dedicated MovePlanner and Executor systems

### 6.2 Periodic Movement (Normal Behavior)
- Movement evaluation occurs approximately **once per minute**
- Movement exists to **redistribute pressure** and create shifting frontlines
- Destinations are determined within the bounds of generated map chunks

### 6.3 Density Cleanup (Legacy Save Remediation)
- Some legacy saves contain **unintended high-density clusters of default Demolishers**
  caused by earlier mods
- These cases are treated not as bugs, but as **ecosystem correction (cleanup)**

#### Cleanup Rules
- 대상 (Targets):
  - Default Demolishers
  - Quality is **normal or undefined**
- Detection:
  - Instead of full scans, **a small random sample** (e.g., up to 5 entities) is examined
  - If a sampled entity has **≥ N Demolishers (e.g., 5)** within a fixed radius (e.g., 50 tiles),
    the area is classified as an abnormal cluster
- Effect:
  - When detected, **exactly one Demolisher** is randomly selected from that cluster
    and added as an additional movement target
- Constraints:
  - Cleanup adds **at most one entity per evaluation cycle**
  - Lightweight checks are mandatory to preserve performance

---

## 7. Reaction to Rocket Launches (Vibration Response)
- From mid-game onward, rocket launches cause Demolishers to gradually move toward silos
  over a fixed cycle
- This behavior is framed as an aversion to **vibration and activity** within the game world

---

## 8. Determinism and Multiplayer
- All randomness must be deterministic to ensure multiplayer consistency
- RNG is centrally managed within the mod
- Any reproducibility issue is treated as a **bug**

---

## 9. Save Data
- All global data is stored under `storage` (keys follow implementation definitions)
- Any change requiring data migration must explicitly document migration steps

---

## 10. Status of This Specification
- This document takes precedence over README and Mod Portal descriptions
- When discrepancies arise between implementation and specification:
  - Either the implementation is accepted as correct, or
  - The specification must be updated explicitly
