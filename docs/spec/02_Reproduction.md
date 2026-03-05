# Breeding Demolisher — Reproduction (MDL Integrated)


Status: Draft (Revised for MDL Integration)  
Scope: BreedingDemolisher spawn decision logic  
Related:
- MDL-ARCH-000 (MDL Architecture — Demolisher Core System)
- MDL-SPAWN-000 (MDL Spawn Engine Specification)
- MDL-PROVIDER-000 (MDL Provider Contract Specification)
- BD-POP-000 (Population Control — Breeding Demolisher)

---

# 0. 本章の位置づけ

ID: BD-REPRO-000

本章は Breeding Demolisher における  
**繁殖ロジック（spawn decision）** を定義する。

本章は以下を前提とする。

- spawn 実行は **MDL Engine が担当する**
- BD は **spawn decision provider** として動作する
- 卵生成および孵化システムは **本統合仕様では使用しない**

本章は以下を扱う。

- spawn種決定
- mutation
- evolution
- derived evolution
- fatal exclusion

---

# 1. 繁殖イベントの基本構造

### 1.1 繁殖イベントの定義

ID: BD-REPRO-010

本 Mod における繁殖イベントとは  
**デモリッシャー spawn decision の評価処理**を指す。

spawn 実行は MDL Engine によって行われる。

---

### 1.2 繁殖イベントの結果

ID: BD-REPRO-011

繁殖イベントの結果は以下のいずれかである。

- spawn種が決定される
- spawnは行われない

spawn実行は MDL Engine が行う。

---

### 1.3 cap との関係

ID: BD-REPRO-012

繁殖イベントは  
`03_PopulationControl.md` に定義された soft cap の影響を受ける。

- cap 到達時、spawn decision は抑止され得る
- 繁殖イベント自体は無効化してはならない

---

### 1.4 評価単位

ID: BD-REPRO-013

繁殖イベントは **親個体を評価単位**として処理される。

- 変異判定は親ごとに1回
- 同一イベント内で複数回の変異判定は禁止

---

### 1.5 単親由来

ID: BD-REPRO-014

本統合仕様では繁殖イベントは  
**単親由来のみ**を扱う。

---

### 1.6 不変条件

ID: BD-REPRO-015

以下を不変条件とする。

- 1イベントにつき spawn は最大1体
- spawn decision は idempotent であってはならない
- 親1体につき変異判定は最大1回

---

# 2. Spawn 種決定

### 2.1 基本原則

ID: BD-REPRO-020

spawn種は以下の順序で決定される。

1. 同種継承
2. 変異判定
3. 進化ルート評価

spawn実行は MDL Engine が行う。

---

### 2.2 spawn可能条件

ID: BD-REPRO-021

spawn decision は以下を満たす場合のみ成立する。

- 親個体が繁殖対象
- soft cap によって抑止されていない
- spawn対象種が存在する

---

### 2.3 spawn抑止

ID: BD-REPRO-022

以下の場合 spawn は行われない。

- soft cap 到達
- 親個体が繁殖対象外
- spawn対象種が存在しない

---

# 3. 同種継承

ID: BD-REPRO-031

spawn種は原則として親個体の種別を継承する。

変異が成立しない限り  
spawn種は親種と同一となる。

---

# 4. 変異判定

### 4.1 評価単位

ID: BD-REPRO-040

変異判定は親個体ごとに1回のみ行う。

---

### 4.2 変異条件

ID: BD-REPRO-041

変異判定は以下条件を満たす場合のみ行う。

- 親種が変異可能
- evo ≥ 変異閾値

---

### 4.3 変異率

ID: BD-REPRO-042

変異率は進化度に依存する。

- evo < threshold → 0%
- evo ≥ threshold → 10% 開始
- evo = 1.0 → 30%

---

### 4.4 線形補間

ID: BD-REPRO-043

threshold から evo=1.0 まで  
変異率は線形補間で増加する。

---

### 4.5 変異成立

ID: BD-REPRO-044

変異成立時

- spawn種は変異先テーブルから抽選
- 抽選は1回のみ

---

### 4.6 変異不成立

ID: BD-REPRO-045

変異不成立時  
spawn種は同種継承を適用する。

---

# 5. 正統進化

### 5.1 small → medium

ID: BD-REPRO-052

条件

- 親種 small
- evo ≥ 0.25

---

### 5.2 medium → big

ID: BD-REPRO-053

条件

- 親種 medium
- evo ≥ 0.50

---

### 5.3 big → behemoth

ID: BD-REPRO-054

条件

- 親種 big
- evo ≥ 0.75
- behemoth 種が存在する

---

# 6. 派生進化

### 6.1 派生進化の位置づけ

ID: BD-REPRO-060

派生進化は副次的進化ルートである。

---

### 6.2 派生進化条件

ID: BD-REPRO-061

派生種が存在する場合のみ有効。

---

### 6.3 主系統 → 派生系

ID: BD-REPRO-062

条件

- 親種 medium
- evo ≥ 0.85

---

# 7. 変異先テーブル

ID: BD-REPRO-070

変異成立時のみ参照する。

複数候補が存在する場合

- テーブル抽選
- 抽選は1回

---

# 8. 繁殖対象外

ID: BD-REPRO-080

以下の個体は繁殖対象外。

- gigantic 系
- crazy-king 系
- その他 FATAL 系

---

# 9. Spawn Decision

ID: BD-REPRO-090

BD Provider は以下を返す。


spawn_entity_name


spawn実行は MDL Spawn Engine が担当する。

---

# 10. 不変条件

ID: BD-REPRO-100

以下を不変条件とする。

- spawn結果は最大1体
- 変異判定は親1体につき1回
- deterministic RNG を使用
- 存在しない種は生成しない