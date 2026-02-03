# System Specification Overview — Breeding Demolisher
`docs/SystemSpecification/00_Overview.md`

**Version:** v1.0 (confirmed)  
**Scope:** Breeding Demolisher

---

## 0. 本書の位置づけ

本書は、Breeding Demolisher における  
**SystemSpecification 全体の構造・規約・運用原則**を定義する。

- 本書は個別挙動を定義しない
- 各 SystemSpecification 文書の **前提・責務境界・命名規約**を定める
- 開発・テスト・修正が迷走した場合に、最初に立ち返る文書とする

本書は `docs/SystemSpecification/` 配下における  
**最上位規範文書**である。

---

## 1. SystemSpecification の目的

SystemSpecification は、以下を満たすために存在する。

- 挙動について **合否判定が可能**であること
- テスト・ログ・観測点が **仕様IDを根拠に説明可能**であること
- 実装・テスト・将来修正の判断材料を **一次資料として保存**すること

本ディレクトリに記載されない挙動は、  
**仕様として未定義**である。

---

## 2. 文書構成（確定）

`docs/SystemSpecification/` 配下は、原則として以下の構成を取る。

docs/SystemSpecification/
00_Overview.md ← 本書（全体規約）
01_CoreLifecycle.md ← 存在条件・管理対象
02_Reproduction.md ← 繁殖・変異・進化・孵化
03_PopulationControl.md ← cap・counted population
04_Interaction.md ← 戦闘・ペット・通知・UI
05_Persistence.md ← storage・virt・migration
90_Observability.md ← 観測点・ログ仕様


- **1ファイル = 1責務領域**を原則とする
- 仕様の重複定義を行ってはならない

---

## 3. 仕様ID体系（最重要）

### 3.1 仕様IDの目的

仕様IDは以下のために付与される。

- テストが **何を検証しているか**を明示する
- ログ・観測点が **どの仕様を観測しているか**を示す
- 仕様変更時に **影響範囲を追跡可能**にする

---

### 3.2 IDフォーマット（確定）

BD-<CATEGORY>-<NNN>


例：
- `BD-CORE-010`
- `BD-REPRO-040`
- `BD-POP-060`
- `BD-INT-045`
- `BD-PERS-031`
- `OBS-REP-001`

---

### 3.3 CATEGORY 一覧（確定）

| CATEGORY | 対象 |
|---|---|
| CORE | CoreLifecycle |
| REPRO | Reproduction |
| POP | PopulationControl |
| INT | Interaction |
| PERS | Persistence |
| OBS | Observability |

---

### 3.4 番号帯の運用ルール

- 各章は **10刻み以上の余白**を持って番号を振る
- 90番台は **横断的・補助的仕様**（Observability 等）に予約する
- 既存IDの意味を変更してはならない
- ID削除は **破壊的変更**として扱う

---

## 4. 仕様・テスト・観測の関係

- 仕様は **SystemSpecification** に定義される
- テストは **Spec ID** を根拠に作成される
- 観測点（ログ）は **仕様の一部**である

観測できない挙動は、  
**テスト不能かつ仕様未完成**とみなす。

---

## 5. 文書間の優先順位（確定）

仕様に矛盾が生じた場合、以下の優先順位で判断する。

1. `spec.md` / `spec.ja.md`（ユーザ向け一次仕様）
2. `docs/SystemSpecification/*.md`
3. `docs/DesignNotes/*`

挙動変更を行う場合は、

- ユーザ向け一次仕様
- 該当する SystemSpecification

を **必ず同時に更新**しなければならない。

---

## 6. 変更ルール

- 仕様変更は必ず **理由を明示**する
- 仕様変更に伴うテスト修正は **同時に行う**
- テストのみの変更は原則不正とする

---

## 7. 未定義の扱い

以下は明示的に扱う。

- 未定義挙動は **実装依存**であり、テスト対象にしてはならない
- 未定義挙動をテストしたい場合は、先に仕様を定義する
- 仮仕様は `DesignNotes` にのみ記載可能

---

## 最後に

SystemSpecification は、

> 「コードの説明」ではなく  
> 「挙動に対する約束」である。

この約束が破られたとき、  
最初に立ち返るべき文書が本書である。