# TJC Integration — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/08_TJCIntegration.md`

Status: Active  
Scope: Integration with ManisTotalJobController

---

## 0. 本章の位置づけ

ID: BD-TJC-000

本章は Breeding Demolisher と

**ManisTotalJobController (TJC)**

の統合方式を定義する。

---

# 1. Target Mods

ID: BD-TJC-010

Breeding Demolisher は

以下の Target Mod job を持つ。

- WildReproduction
- PetBreeding

---

# 2. Planning Contract

ID: BD-TJC-020

planning request を受信すると

各 job は

execution step count

を計算する。

---

# 3. Execution Contract

ID: BD-TJC-030

execution request は

step_index

を持つ。

Target mod は

1 step のみ処理する。

---

# 4. Deterministic Execution

ID: BD-TJC-040

job execution は

- bounded execution
- deterministic behavior

を保証する。

---

# 5. Transport

ID: BD-TJC-050

TJC communication は

event.raise

を使用する。

remote.call は

event discovery のみに使用する。

---

# 6. Non Goals

ID: BD-TJC-060

TJC integration は

以下を扱わない。

- spawn algorithm
- mutation logic
- population control

これらは

Breeding Demolisher domain

の責務である。