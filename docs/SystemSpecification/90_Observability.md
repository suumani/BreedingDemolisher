# Observability Specification — Breeding Demolisher
`docs/SystemSpecification/90_Observability.md`

**Version:** v1.0 (confirmed)  
**Scope:** Breeding Demolisher  
**Note:**  
本書は Manis Boss Demolisher における Observability Specification v1.0 を踏襲し、  
Breeding Demolisher 向けに拡張したものである。

---

## 0. 本書の位置づけ

本書は、Breeding Demolisher における  
**ゲーム挙動を観測可能にするためのログ・観測点仕様**を定義する。

本プロジェクトでは、

- 低レイヤーの単体テストは原則作成しない
- 代わりに、**仕様単位で合否が判断できる観測点**を必須とする

テストは、本書で定義された観測点を  
`TestPolicy.md` および `99_TestPlan.md` の根拠として実施される。

---

## 1. 観測の基本方針

### OBS-POL-001: Every evaluated system must terminate visibly

以下のシステムは、必ず **終端ログ**を出力しなければならない。

- PopulationControl（cap 判定）
- Reproduction（繁殖イベント）
- Interaction（撃破 / ペット繁殖 / 通知）
- Virtual Demolisher 管理（生成 / 実体化）

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

- テストはログを一次情報として合否を判断する
- ログは **人間が読める**ことを優先する
- ログは **機械的に検証可能**な構造を持つ

---

## 2. ログの共通フォーマット

### OBS-FMT-001: Structured message

ログは以下の構造を持つことを推奨する。

- Mod 名
- 処理カテゴリ（POP / REPRO / INT / VIRT）
- 処理種別
- outcome
- 主要パラメータ（key=value 形式）

**例**
[BreedingDemolisher][REPRO][Evaluate][SKIP]
reason=CAP_REACHED
parent=manis-medium
evo=0.62
counted=128 cap=130


---

## 3. PopulationControl 観測点

### OBS-POP-001: cap 判定ログ（required）

**出力タイミング**
- cap 判定処理の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason`  : `CAP_REACHED | BELOW_CAP | FLOOR_APPLIED`
- `evo`
- `counted_population`
- `cap`
- `cap_floor_applied` : true | false

**対応仕様**
- BD-POP-060 ～ BD-POP-065

---

## 4. Reproduction 観測点

### OBS-REP-001: 繁殖イベント評価ログ（required）

**出力タイミング**
- 繁殖イベント評価の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `reason`  : `CAP_REACHED | NOT_ELIGIBLE | NO_PARTNER | FATAL_EXCLUDED`
- `parent_species`
- `evo`

**対応仕様**
- BD-REPRO-010 ～ BD-REPRO-027

---

### OBS-REP-002: 変異判定ログ（required）

**出力タイミング**
- 変異判定処理の終了時

**必須項目**
- `outcome` : `OK | SKIP | FAIL`
- `mutation_applied` : true | false
- `from_species`
- `to_species`
- `route` : `MAIN | DERIVED`

**対応仕様**
- BD-REPRO-040 ～ BD-REPRO-068

---

## 5. Interaction 観測点

### OBS-INT-001: 撃破イベントログ（required）

**出力タイミング**
- デモリッシャー撃破時

**必須項目**
- `outcome`
- `surface`
- `entity_name`
- `force`

**対応仕様**
- BD-INT-010 ～ BD-INT-023

---

### OBS-INT-002: ペット繁殖ログ（required）

**出力タイミング**
- ペット繁殖評価の終了時

**必須項目**
- `outcome`
- `reason` : `NO_PARTNER | SUCCESS | NOT_MATURE`
- `parent_a`
- `parent_b`
- `growth_a`
- `growth_b`

**対応仕様**
- BD-INT-040 ～ BD-INT-047

---

## 6. Virtual Demolisher 観測点

### OBS-VIRT-001: Virtual Demolisher 更新ログ（required）

**出力タイミング**
- 仮想デモリッシャーの生成 / 実体化 / 削除時

**必須項目**
- `action` : `CREATE | MATERIALIZE | REMOVE`
- `surface`
- `vid`
- `position`

**対応仕様**
- BD-POP-010
- BD-PERS-xxx（Persistence 章で定義）

---

## 7. RNG 観測（任意・推奨）

### OBS-RNG-001: RNG usage trace (debug)

- 使用する乱数源は Deterministic RNG のみ
- 以下の情報を DEBUG レベルで出力してよい：
  - 使用箇所（POP / REPRO / INT）
  - 使用回数（概数）

---

## 8. 観測点追加ルール

### OBS-RULE-001: New behavior requires new observability

- 新しい仕様・分岐を追加する場合：
  - それを観測できるログ項目を **必ず追加**する
- 観測できない挙動は、**テスト不能**とみなす

---

## 9. テストとの関係

- 本書で定義された観測点は、
  `TestPolicy.md` および `99_TestPlan.md` における  
  **合否判定の根拠**となる
- 観測点の無い仕様は、テスト対象にしてはならない

---

### まとめ

Breeding Demolisher において、

> **ログはデバッグ用ではなく、仕様の一部である。**

本書は、その前提を明文化するための文書である。