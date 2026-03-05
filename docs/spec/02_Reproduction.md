# Breeding Demolisher — Reproduction
`__BreedingDemolisher__/docs/spec/02_Reproduction.md`

Status: Draft  
Scope: Demolisher reproduction decision logic  
Related:
- MDL-PROVIDER-000 (MDL Provider Contract)
- BD-POP-000 (Population Control)

---

# 1. 本仕様書の位置づけ

ID: BD-REPRO-000

本仕様書は BreedingDemolisher における  
**繁殖判定アルゴリズム (spawn decision)** を定義する。

spawn 実行は **MDL Engine** が担当する。  
本仕様書は **spawn decision のみ**を扱う。

---

# 2. Reproduction Algorithm

ID: BD-REPRO-CORE

繁殖は以下のアルゴリズムで行う。

<<<CODEBLOCK START>>>

every 10 minutes:

  enumerate Vulcanus territories

  for each territory worker:

    units = territory.segmented_units

    for unit in units:

        if reproduction_roll(unit) is false:
            continue

        if soft_cap_reached:
            continue

        species = determine_species(unit)

        spawn(species)

<<<CODEBLOCK END>>>

制約:

- 繁殖判定は **unit 単位**
- 1回の繁殖で spawn は **最大1体**
- spawn 実行は **MDL Engine が担当**

---

# 3. Spawn Decision

ID: BD-REPRO-DECISION

BD Provider は以下を返す。

<<<CODEBLOCK START>>>

SpawnDecisionDTO {

  spawn_entity_name | nil
  reason

}

<<<CODEBLOCK END>>>

spawn_entity_name が `nil` の場合、spawn は行われない。

---

# 4. Evolution Table

ID: BD-REPRO-EVOLUTION

進化条件は以下の表で定義する。

| Parent Species | Evolution Threshold (evo) | Spawn Species |
|----------------|---------------------------|---------------|
| small          | ≥ 0.25                    | medium        |
| medium         | ≥ 0.50                    | big           |
| big            | ≥ 0.75                    | behemoth      |

解釈規則:

1. 親種が `Parent Species` に一致する行を評価する。
2. `evolution_factor` が `Evolution Threshold` を満たす場合、spawn種は `Spawn Species` となる。
3. 条件を満たさない場合、spawn種は親種を継承する。

---

# 5. Mutation Table

ID: BD-REPRO-MUTATION

変異条件は以下の表で定義する。

| Parent Species Group           | Evolution Threshold (evo) | Mutation Target Species Group |
|--------------------------------|---------------------------|--------------------------------|
| manis medium demolisher 系    | ≥ 0.25                    | manis small speedstar 系      |
| manis big demolisher 系       | ≥ 0.50                    | manis medium speedstar 系     |
| manis behemoth demolisher 系  | ≥ 0.75                    | manis big speedstar 系        |

解釈規則:

1. 親種が `Parent Species Group` に属する場合、本表を評価する。
2. `evolution_factor` が `Evolution Threshold` を満たす場合、mutation 判定を行う。
3. mutation が成立した場合、spawn種は `Mutation Target Species Group` から選択する。
4. mutation が成立しない場合、通常の進化ルールを適用する。

---

# 6. Determinism

ID: BD-REPRO-DETERMINISM

繁殖判定は deterministic execution を保証する。

乱数は以下を seed とする。

- `ctx.rng_material`

---

# 7. Non Goals

ID: BD-REPRO-NONGOAL

本仕様書は以下を扱わない。

- spawn placement
- entity create
- job scheduling
- world scan

これらは **MDL / MJL Engine の責務**である。