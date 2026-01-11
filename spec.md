# Breeding Demolisher — Specification (spec)

This document records the **design intent, specifications, and agreed decisions** of Breeding Demolisher.  
It preserves criteria, priorities, and the boundary between intended behavior and bugs that cannot be fully described in the Mod Portal/README.

---

## 0. Purpose and Non-goals

### 0.1 Purpose
- Provide an experience where demolishers are treated as a **reproducing ecosystem**, not a one-off threat.
- Prevent the game from breaking by controlling growth via **caps and growth logic**, while still keeping pressure.
- Create meaningful decisions around **culling / ignoring / breeding (pets)**.

### 0.2 Non-goals
- It does not guarantee “safe and manageable” difficulty at all times.
- Eggs/breeding are not intended to be a mere collection feature; neglect must have consequences.
- It does not aim to replace global enemy behavior entirely.

---

## 1. Mod Positioning
- Category: Content / Enemies
- Target: Factorio 2.0 (Space Age) :contentReference[oaicite:9]{index=9}
- Core experience: manage demolisher population by hunting, containment, or breeding.

---

## 2. Core Loop
1. Eggs are generated through time and combat.
2. Eggs hatch and population increases.
3. Population pressure requires defense, culling, and movement control.
4. The player chooses containment, thinning, or breeding.

---

## 3. Natural Reproduction (Wild)
- Demolishers reproduce periodically and create eggs.
- Eggs hatch after some time.
- Total population is capped.
- Growth is controlled based on current population and the cap.
- Eggs may occasionally drop from defeated demolishers.
- With higher evolution:
  - hatched demolishers may have higher quality
  - egg dispersion range increases
- Total population is capped.
  - The cap is **fixed at 200** (performance stability prioritized).
- Growth is controlled based on current population and the cap.

---

## 4. Player Interaction / Pets
- Eggs can sometimes be obtained by defeating wild demolishers.
- Hatched demolishers are treated as “pets”.
- Pets can be hostile / neutral / friendly.
- Mature pets begin reproducing and laying eggs.
- Offspring may inherit traits and abilities from parents.
- Eggs produced through breeding tend to be higher quality than dropped eggs.

---

## 5. Difficulty and Pressure Design
- This mod targets players who enjoy high-risk, high-density combat.
- It reduces early-game frustration while preserving meaningful population pressure.
- As the game progresses, quality, dispersal, and pressure increase.

---

## 6. Reaction to Rocket Launches (Vibration Trait)
- From the mid-game onward, when a rocket is launched, demolishers gradually move toward the rocket silo during that 30-minute cycle (intended behavior).
- This is expressed as a trait: demolishers dislike the vibrations caused by rocket launches (worldbuilding).

---

## 7. Determinism / Multiplayer
- Randomness uses deterministic methods and assumes multiplayer reproducibility.
- Any deviation from determinism is treated as a bug.

---

## 8. Save Data
- Global storage is maintained under `storage` (keys follow implementation).
- If a breaking change requires migration, the migration steps must be documented.

---

## 9. Status of This Specification
- This document takes precedence over the README and Mod Portal descriptions.
- If discrepancies arise:
  - either treat implementation as authoritative,
  - or update this specification,
  and make the decision explicitly.