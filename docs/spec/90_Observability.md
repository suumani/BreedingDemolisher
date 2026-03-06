# Observability Specification — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/90_Observability.md`

Status: Active  
Scope: Breeding Demolisher Observability Specification

---

## 0. 本書の位置づけ

本書は、Breeding Demolisher における  
**ゲーム挙動を観測可能にするためのログ・観測点仕様**を定義する。

本プロジェクトでは、

- 低レイヤーの単体テストは原則作成しない
- 代わりに、**仕様単位で合否が判断できる観測点**を必須とする

テストは、本書で定義された観測点を  
`TestPolicy.md` の根拠として実施される。

---

## 1. 観測の基本方針

### OBS-POL-001: Every evaluated system must terminate visibly

以下のシステムは、必ず **終端ログ**を出力しなければならない。

- PopulationControl
- Reproduction
- Interaction
- Persistence（Migration / Rebuild）

「何も起きなかった」場合も、  
**必ず `SKIP` として明示**する。

沈黙は不正とみなす。

---

### OBS-POL-002: Outcome is classified into three states

すべての観測対象処理は、以下のいずれかで終端する。

- `OK`   : 仕様どおり処理が実行された
- `SKIP` : 条件不一致・上限到達・対象外などにより実行されなかった
- `FAIL` : 想定外エラー、または仕様違反

---

### OBS-POL-003: Logs are the primary oracle

- テストはログ内容を一次情報として合否判断に利用できる
- ログは **人間が読める**ことを優先する
- ログは **機械的に検証可能**な構造を持つ

---

## 2. ログの共通フォーマット

### OBS-FMT-001: Structured message

ログは以下の構造を持つことを推奨する。

- Mod 名
- 処理カテゴリ（POP / REPRO / INT / PERS）
- 処理種別
- outcome
- 主要パラメータ（key=value 形式）

例:

[BreedingDemolisher][REPRO][Evaluate][SKIP]  
reason=CAP_REACHED  
territory_id=vulcanus-001  
parent_entity=manis-medium-demolisher  
counted_population=128  
soft_cap=128

---

## 3. PopulationControl 観測点

### OBS-POP-001: population cap evaluation log (required)

出力タイミング  
- population cap 判定処理の終了時

必須項目

- outcome : OK | SKIP | FAIL
- reason  :
  - BELOW_CAP
  - TERRITORY_CAP_REACHED
  - SURFACE_CAP_REACHED
  - INVALID_TERRITORY

- territory_id
- territory_population
- territory_cap
- surface
- surface_population
- surface_cap

対応仕様
- BD-POP-010
- BD-POP-020
- BD-POP-025
- BD-POP-030
- BD-POP-040

### OBS-POP-001: population cap evaluation log (required)

**出力タイミング**
- population soft cap 判定処理の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `BELOW_CAP | CAP_REACHED | INVALID_TERRITORY`
- `territory_id`
- `counted_population`
- `soft_cap`

**対応仕様**
- BD-POP-010
- BD-POP-020
- BD-POP-030
- BD-POP-040

---

### OBS-POP-002: population update log (required)

**出力タイミング**
- spawn または death により population が更新された時

**必須項目**
- `outcome` : `OK | FAIL`
- `reason` : `SPAWN | DEATH`
- `territory_id`
- `before_population`
- `after_population`
- `entity_name`

**対応仕様**
- BD-POP-050

---

## 4. Reproduction 観測点

### OBS-REP-001: reproduction evaluation log (required)

**出力タイミング**
- 1 unit に対する reproduction 評価の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `ROLL_FAILED | CAP_REACHED | INVALID_UNIT | SPAWNED`
- `territory_id`
- `parent_entity_name`
- `spawn_entity_name`（`OK` の場合必須）
- `step_index`（利用可能な場合）
- `cycle_tick`（利用可能な場合）

**対応仕様**
- BD-REPRO-000
- BD-REPRO-010
- BD-REPRO-020
- BD-REPRO-CORE
- BD-REPRO-030
- BD-REPRO-040

---

### OBS-REP-002: evolution / mutation decision log (required)

**出力タイミング**
- spawn entity 決定処理の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `parent_entity_name`
- `resolved_entity_name`
- `mutation_applied` : `true | false`
- `evolution_factor`

**対応仕様**
- BD-REPRO-040
- BD-REPRO-050
- BD-REPRO-060

---

### OBS-REP-003: territory spawn log (required)

**出力タイミング**
- territory 内 spawn 実行の終了時

**必須項目**
- `outcome` : `OK | FAIL`
- `territory_id`
- `entity_name`
- `surface`
- `position`（取得可能な場合）

**対応仕様**
- BD-CORE-000
- BD-REPRO-CORE

---

## 5. Interaction 観測点

### OBS-INT-001: combat death log (required)

**出力タイミング**
- 管理対象デモリッシャーが撃破イベントとして処理された時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `COMBAT_DEATH | NON_COMBAT | OUT_OF_SCOPE`
- `surface`
- `entity_name`
- `force`

**対応仕様**
- BD-INT-010
- BD-INT-011

---

### OBS-INT-002: egg drop log (required)

**出力タイミング**
- 卵ドロップ評価の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `DROPPED | NOT_ELIGIBLE | FATAL_EXCLUDED | SUPPRESSED`
- `source_entity_name`
- `egg_item_name`（`OK` の場合必須）

**対応仕様**
- BD-INT-020
- BD-INT-021
- BD-INT-022
- BD-INT-023

---

### OBS-INT-003: pet hatch log (required)

**出力タイミング**
- 卵からの hatch 結果が確定した時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `HATCHED | INVALID_EGG | CANCELLED`
- `egg_item_name`
- `result_entity_name`（`OK` の場合必須）
- `result_force`（`OK` の場合必須）

**対応仕様**
- BD-INT-030
- BD-INT-031
- BD-INT-036

---

### OBS-INT-004: pet reproduction log (required)

**出力タイミング**
- ペット繁殖評価の終了時

**必須項目**
- `outcome`
- `reason` : `SUCCESS | NO_PARTNER | NOT_MATURE`
- `parent_a_entity_name`
- `parent_b_entity_name`（相手不在時は省略可）
- `growth_a`
- `growth_b`（相手不在時は省略可)

**対応仕様**
- BD-INT-040
- BD-INT-041
- BD-INT-042
- BD-INT-043
- BD-INT-044
- BD-INT-045
- BD-INT-046
- BD-INT-047

---

### OBS-INT-005: notification log (optional)

**出力タイミング**
- プレイヤー通知を表示した時

**必須項目**
- `outcome`
- `event_kind`
- `player_index`（取得可能な場合）

**対応仕様**
- BD-INT-050
- BD-INT-051
- BD-INT-052
- BD-INT-053
- BD-INT-054
- BD-INT-055
- BD-INT-056

---

## 6. Persistence 観測点

### OBS-PERS-001: migration result log (required)

**出力タイミング**
- migration 実行の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason`（必要に応じて）
- `from_version`（取得可能な場合）
- `to_version`（取得可能な場合）
- `affected_count`（取得可能な場合）

**対応仕様**
- BD-PERS-070

---

### OBS-PERS-002: rebuild result log (required)

**出力タイミング**
- rebuild 実行の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason` : `NO_ACTION | REPAIRED | FAILED`
- `territory_id`（対象がある場合）
- `affected_count`（取得可能な場合）

**対応仕様**
- BD-PERS-060

---

## 7. RNG 観測（任意・推奨）

### OBS-RNG-001: deterministic rng usage trace (debug)

- 使用する乱数源は Deterministic RNG のみ
- 以下の情報を DEBUG レベルで出力してよい
  - 使用カテゴリ（POP / REPRO / INT）
  - 使用箇所
  - 使用回数（概数）

**対応仕様**
- BD-REPRO-070
- BD-INT-075

---

## 8. 観測点追加ルール

### OBS-RULE-001: New behavior requires new observability

- 新しい仕様・分岐を追加する場合、
  それを観測できるログ項目を **必ず追加**する
- 観測できない挙動は、**テスト不能**とみなす

---

## 9. テストとの関係

- 本書で定義された観測点は、
  `TestPolicy.md` における **合否判定の根拠**となる
- テストは原則として
  - ワールド状態（primary）
  - ログ内容（secondary）
  の組み合わせで実施される
- 観測点の無い仕様は、テスト対象にしてはならない

---

## まとめ

Breeding Demolisher において、

ログはデバッグ用ではなく、**仕様の一部である。**

本書は、その前提を明文化するための文書である。