# Population Control — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/03_PopulationControl.md`

Status: Active  
Scope: Territory and surface population control

Related:
- BD-CORE-000 (Core Lifecycle)
- BD-REPRO-000 (Reproduction)

---

## 1. 本仕様書の位置づけ

ID: BD-POP-000

本仕様書は Breeding Demolisher における  
**デモリッシャー個体数管理（Population Control）**を定義する。

Population Control の目的は

- territory 内個体数の制御
- surface 全体個体数の制御
- reproduction による過剰生成の防止

である。

---

## 2. Population Scope

ID: BD-POP-010

population は以下の2つのスコープで管理される。

- territory population
- surface population

---

## 3. Territory Population

ID: BD-POP-020

territory population は

<<<CODEBLOCK START>>>
population(territory) =
  count(territory.units)
<<<CODEBLOCK END>>>

で定義される。

count 対象は

- territory に所属する segmented_unit (demolisher)

である。

---

## 4. Surface Population

ID: BD-POP-025

surface population は

<<<CODEBLOCK START>>>
population(surface) =
  count(all segmented units on surface)
<<<CODEBLOCK END>>>

で定義される。

対象は

- 指定 surface 上のすべてのsegmented_unit entity

である。

---

## 5. Population Caps

ID: BD-POP-030

Breeding Demolisher は以下の population cap を持つ。

- territory cap = **6**
- surface cap = **200**

これらは

- reproduction spawn
- Interaction spawn（例: pet reproduction）

の両方に適用される。

---

## 6. Spawn Suppression

ID: BD-POP-040

spawn は以下の条件を満たす場合、抑止される。

<<<CODEBLOCK START>>>

if population(territory) >= 6:
    suppress spawn

if population(surface) >= 200:
    suppress spawn

<<<CODEBLOCK END>>>

いずれかの cap を満たした場合  
spawn は実行してはならない。

---

## 7. Spawn Evaluation Timing

ID: BD-POP-045

cap 判定は

**spawn 実行直前**

に行う。

そのため

- 同一 evaluation cycle 内でも
- 先行 spawn によって cap が満たされた場合

後続 spawn は suppress される。

---

## 8. Population Update

ID: BD-POP-050

population は以下のイベントで更新される。

### Spawn

<<<CODEBLOCK START>>>
territory_population += 1
surface_population += 1
<<<CODEBLOCK END>>>

### Death

<<<CODEBLOCK START>>>
territory_population -= 1
surface_population -= 1
<<<CODEBLOCK END>>>

---

## 9. Deterministic Behavior

ID: BD-POP-060

Population Control は

- deterministic execution
- multiplayer determinism

を保証する。

population 判定は

- reproduction evaluation
- spawn execution

の両段階で一貫した状態を参照する。

---

## 10. Non Goals

ID: BD-POP-070

本仕様書は以下を扱わない。

- reproduction probability
- spawn entity selection
- movement
- combat behavior

これらは

- Reproduction
- Interaction

の責務である。