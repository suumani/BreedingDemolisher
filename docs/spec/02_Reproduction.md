# Breeding Demolisher — Reproduction
`__BreedingDemolisher__/docs/spec/02_Reproduction.md`

Status: Draft  
Scope: Demolisher reproduction algorithm

Related:
- BD-CORE-000 (Core Lifecycle)
- BD-POP-000 (Population Control)

---

## 1. 本仕様書の位置づけ

ID: BD-REPRO-000

本仕様書は BreedingDemolisher における  
**デモリッシャー自然生成アルゴリズム（reproduction）**を定義する。

reproduction は

- territory 単位
- unit 単位判定
- territory 内部イベント

として実行される。

spawn は

- reproduction 判定
- population control

を満たした場合に **Breeding Demolisher が直接実行する。**

---

## 2. Job Execution Model

ID: BD-REPRO-010

reproduction は  
**TJC (ManisTotalJobController) によって駆動される job** として実行される。

Breeding Demolisher は

- job scheduler
- job queue

を持たない。

TJC が

- planning cycle
- execution step dispatch

を担当する。

---

## 3. Reproduction Scope

ID: BD-REPRO-020

reproduction は

**Vulcanus territory**

を対象とする。

各 territory 内の **unit** が  
reproduction 判定対象となる。

---

## 4. Reproduction Algorithm

ID: BD-REPRO-CORE

reproduction は以下のアルゴリズムで実行される。

<<<CODEBLOCK START>>>

for each territory:

  units = territory.units

  for unit in units:

      if reproduction_roll(unit) is false:
          continue

      if population_soft_cap_reached(territory):
          continue

      entity_name = determine_spawn_entity(unit)

      spawn_in_territory(territory, entity_name)

<<<CODEBLOCK END>>>

制約:

- reproduction 判定は **unit 単位**
- 1回の判定で spawn は **最大1体**
- spawn は **territory 内部イベント**

---

## 5. Reproduction Roll

ID: BD-REPRO-030

各 unit は reproduction 判定を行う。

<<<CODEBLOCK START>>>

reproduction_roll(unit)

<<<CODEBLOCK END>>>

roll が失敗した場合  
spawn は行われない。

---

## 6. Spawn Entity Determination

ID: BD-REPRO-040

spawn される entity は  
**親 unit の entity name と evolution factor** によって決定される。

spawn entity は  
**Factorio entity name** として決定される。

---

## 7. Evolution Table

ID: BD-REPRO-050

進化条件は以下の表で定義する。

| Parent Entity | Evolution Threshold | Spawn Entity |
|---|---|---|
| manis-small-demolisher | ≥ 0.25 | manis-medium-demolisher |
| manis-medium-demolisher | ≥ 0.50 | manis-big-demolisher |
| manis-big-demolisher | ≥ 0.75 | manis-behemoth-demolisher |

解釈規則:

1. 親 entity name に一致する行を評価する
2. `evolution_factor` が threshold を満たす場合  
   spawn entity は `Spawn Entity`
3. 条件を満たさない場合  
   spawn entity は親 entity を継承する

---

## 8. Mutation Table

ID: BD-REPRO-060

mutation 条件は以下の表で定義する。

| Parent Entity | Evolution Threshold | Mutation Entity |
|---|---|---|
| manis-medium-demolisher | ≥ 0.25 | manis-small-speedstar |
| manis-big-demolisher | ≥ 0.50 | manis-medium-speedstar |
| manis-behemoth-demolisher | ≥ 0.75 | manis-big-speedstar |

解釈規則:

1. 親 entity が一致する行を評価する
2. `evolution_factor` が threshold を満たす場合  
   mutation 判定を行う
3. mutation が成立した場合  
   spawn entity は `Mutation Entity` となる
4. mutation が成立しない場合  
   evolution table を適用する

---

## 9. Determinism

ID: BD-REPRO-070

reproduction 判定は  
**deterministic execution** を保証する。

乱数は以下を seed とする。

- `ctx.rng_material`

---

## 10. Non Goals

ID: BD-REPRO-080

本仕様書は以下を扱わない。

- spawn placement algorithm
- pathfinding
- demolisher movement
- combat behavior
- player egg hatch

これらは

- Movement system
- Interaction system

の責務である。