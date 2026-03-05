# Population Control — Breeding Demolisher (MDL Integrated)
`__BreedingDemolisher__/docs/spec/03_PopulationControl.md`

Status: Draft (Revised for MDL Integration)  
Scope: BreedingDemolisher soft population control logic  
Related:
- MDL-ARCH-000 (MDL Architecture — Demolisher Core System)
- MDL-POP-000 (MDL Population Observation Specification)
- MDL-SPAWN-000 (MDL Spawn Engine Specification)
- BD-REPRO-000 (Breeding Demolisher — Reproduction)

---

# 0. 本章の位置づけ

ID: BD-POP-000

本章は Breeding Demolisher における  
**増殖圧力の制御（soft population control）** を定義する。

本章は以下を前提とする。

- spawn実行は **MDL Spawn Engine** が行う
- population観測は **MDL Population Observation** が行う
- 本章は **soft cap のロジックのみ定義する**

本章は以下を扱わない。

- spawn execution
- population observation
- hard cap（MDL安全装置）

---

# 1. 個体数制御の目的

ID: BD-POP-001

soft cap は以下の目的で導入される。

- 過剰な増殖圧力を抑える
- ゲーム進行に応じて増殖強度を調整する
- 長期プレイにおいてバランスを維持する

soft cap は **増殖圧力のみを抑制する装置**である。

---

# 2. Population Model

ID: BD-POP-010

soft cap 判定に使用する population は  
**MDL Population Observation** が提供する。


counted_population


counted_population は以下を除外した物理個体数である。


species ∈ {small, medium, big}
quality ∈ {nil, normal}


理由

- 自然配置個体を増殖制御対象から除外するため

---

# 3. Evolution-based Cap

ID: BD-POP-020

soft cap は進化度（evolution factor）に応じて変化する。

| evo | cap |
|---|---|
| ≤0.05 | 40 |
| ≤0.15 | 55 |
| ≤0.25 | 70 |
| ≤0.35 | 85 |
| ≤0.45 | 100 |
| ≤0.55 | 115 |
| ≤0.65 | 130 |
| ≤0.75 | 145 |
| ≤0.85 | 160 |
| ≤0.95 | 175 |
| ≤0.98 | 190 |
| >0.98 | 200 |

---

# 4. Research Modifier

ID: BD-POP-030

以下の研究が cap に影響する。


manis-demolisher-cap-down


補正


effective_cap = base_cap × (1 − 0.05 × research_level)


---

# 5. Cap Floor

ID: BD-POP-040

研究による cap 減少には下限を適用する。


minimum cap = 50


目的

- 生態系停止を防ぐ

---

# 6. Cap Evaluation

ID: BD-POP-050

soft cap 判定は以下で行う。


counted_population ≥ effective_cap


この場合 spawn decision は **抑止される**。

---

# 7. Cap 到達時の挙動

ID: BD-POP-060

soft cap 到達時

- spawn decision は SKIP となる
- 既存個体は変更されない

soft cap は **是正装置ではない**。

---

# 8. Cap 超過状態

ID: BD-POP-070

counted_population が cap を超過する場合でも

- 個体削除
- despawn
- forced movement

などの是正処理は行わない。

超過状態は許容される。

---

# 9. Cap 復帰

ID: BD-POP-080

counted_population が cap 未満になった場合  
spawn decision は自動的に再開される。

クールダウンは存在しない。

---

# 10. Spawn Engine Integration

ID: BD-POP-090

soft cap 判定は  
**Provider の spawn decision ロジック内で行われる**。

spawn 実行は MDL Spawn Engine が担当する。

処理順


population snapshot (MDL)
↓
provider soft cap evaluation
↓
spawn decision
↓
spawn execution (MDL)


---

# 11. 不変条件

ID: BD-POP-100

以下を不変条件とする。

- 自然配置の標準3種は増殖制御対象ではない
- soft cap は spawn decision のみ抑止する
- 既存個体を変更しない
- cap 超過は許容される