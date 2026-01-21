# Breeding Demolisher

Breeding Demolisher is a mod that adds a world where demolishers can reproduce and evolve.  
Over time—and through combat—eggs are produced, hatch, and increase the overall population.  
If left unchecked, the threat can grow exponentially.

- Mod Portal: BreedingDemolisher (Factorio 2.0)
- Source: https://github.com/suumani/BreedingDemolisher

---

## Concept

This mod reinterprets demolishers not only as enemies to be defeated,  
but as a **growing ecosystem** that must be observed, managed, and sometimes cultivated.

Rather than a simple “clear the area” enemy, demolishers form a population  
that expands, evolves, and reacts to player interaction.

Breeding Demolisher is designed for players who enjoy  
high-risk, high-density combat and ecosystem management.

---

## Added Gameplay

### Natural Breeding

- Demolishers periodically lay eggs
- Eggs hatch over time
- Reproduction is controlled based on the current population and a global cap
- Eggs may drop when demolishers are defeated
- Hatch quality and egg dispersion scale with the evolution factor
- The total number of demolishers is capped at **200**
  - This cap is fixed to prioritize performance stability across a wide range of PCs

---

### Player Interaction / Pets

- Eggs may be obtained by defeating wild demolishers
- Eggs can be hatched into **pet demolishers**
- Pets can be hostile, neutral, or friendly
- Pets grow by defeating enemies
- Mature pets can reproduce
- Offspring inherit **genetic traits** from their parents
- Eggs produced through breeding tend to be higher quality than dropped eggs
- New-species demolishers act as an intermediate evolutionary stage  
  and may eventually lead to friendly demolishers

---

### Breeding and Genetics (v0.5.6+)

- All genetic parameters follow a unified **two-stage inheritance model**
- Genetic data is preserved through egg transport, storage, and hatching
- Two-parent breeding generally produces more favorable offspring
- Single-parent breeding is possible but less advantageous
- Faction (tameness) of offspring is determined at the egg stage

Note:
- Trait **effects** are not yet activated in v0.5.6  
- This release focuses on genetic structure and future extensibility

---

## Planetary Restrictions

- Demolishers are native to **Vulcanus**
- Egg processing and evolution (size evolution, new-species evolution, freezing/unfreezing)
  can only be performed on Vulcanus
- Hatched demolishers can be transported to and deployed on other planets

---

## Supported Environment

- Factorio 2.0
- Space Age expansion required

---

## Documentation

- Detailed specifications and internal design notes:
  - `spec.md`
  - `design_v0.5.6_mutation.md`
- Japanese documentation:
  - `spec.ja.md`

---

## License

MIT