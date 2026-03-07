# Wild Reproduction — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/06_WildReproduction.md`

Status: Active  
Scope: Natural demolisher reproduction

---

## 0. 本章の位置づけ

ID: BD-WILD-000

本章は Breeding Demolisher における

**Wild Demolisher の自然生成**

を定義する。

本仕様は

- `02_Reproduction.md`
- `03_PopulationControl.md`

を実装レベルで具体化する。

---

# 1. Job Execution

ID: BD-WILD-010

Wild Reproduction は

**TJC job**

として実行される。

周期

- 10分 planning cycle

---

# 2. Execution Unit

ID: BD-WILD-020

execution step は

**1 territory = 1 step**

である。

---

# 3. Planning Phase

ID: BD-WILD-030

planning phase は

以下を実行する。

1. surface 取得
2. `surface.get_territories()` で territory 列挙
3. reproduction 対象 territory を決定

planning result は

- runtime-only

で保持される。

---

# 4. Execution Phase

ID: BD-WILD-040

execution phase は

1 territory を評価する。

処理:

<<<CODEBLOCK START>>>

territory = resolve_territory(chunk)

units = territory.get_segmented_units()

for unit in units:

    if reproduction_roll(unit) == false:
        continue

    entity_name = resolve_spawn_entity(unit)

    if population_cap_reached():
        continue

    spawn_entity(territory, entity_name)

<<<CODEBLOCK END>>>

---

# 5. Spawn Placement

ID: BD-WILD-050

spawn は

**unit が属する territory 内**

で行う。

spawn placement は

territory context 内で決定される。

---

# 6. Population Control

ID: BD-WILD-060

spawn 実行直前に

`03_PopulationControl.md`

の cap 判定を適用する。

---

# 7. Determinism

ID: BD-WILD-070

wild reproduction は

- deterministic execution
- multiplayer determinism

を保証する。

乱数は

`DeterministicRandom`

を使用する。

---

# 8. Persistence

ID: BD-WILD-080

Wild reproduction は

以下のみ永続化する。

- territory metadata
- chunk coordinate

planning result は

runtime-only とする。