# Core Lifecycle — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/01_CoreLifecycle.md`

Status: Active  
Scope: Demolisher lifecycle and management boundary

Related:
- BD-REPRO-000 (Reproduction)
- BD-POP-000 (Population Control)

---

## 0. 本章の位置づけ

本章は Breeding Demolisher が扱う  
**デモリッシャー個体の存在条件とライフサイクル境界**を定義する。

本章は以下を扱う。

- 管理対象となるデモリッシャー
- デモリッシャーのライフサイクル段階
- territory との関係
- 他サブシステムとの責務境界

本章は以下を扱わない。

- 繁殖確率
- cap 数値
- mutation / evolution アルゴリズム

これらは **Reproduction / PopulationControl** で定義する。

---

## 1. 管理対象となるデモリッシャー

### 1.1 管理対象の定義

Breeding Demolisher が管理対象とするデモリッシャーは  
以下を満たす **Factorio entity** である。

条件:

- entity name が **Breeding Demolisher が生成する custom entity**
- territory に所属する

例:

manis-small-demolisher  
manis-small-demolisher-alt  
manis-medium-demolisher  

---

### 1.2 管理対象外

以下は本 Mod の管理対象外とする。

- Factorio 標準デモリッシャー
- 他 Mod が生成した非互換 entity
- FATAL 系 entity（gigantic / crazy-king 等）

これらの entity は

- reproduction
- population control

の対象にならない。

---

## 2. デモリッシャーの存在形態

Breeding Demolisher では  
**仮想デモリッシャーという概念は存在しない。**

すべてのデモリッシャーは

- Factorio world 上の **physical entity**

として存在する。

旧仕様に存在した

- virtual demolisher
- logical demolisher
- storage-only demolisher

は **廃止された概念である。**

---

## 3. Territory 所属

すべての自然生成デモリッシャーは  
**必ず territory に所属する。**

自然生成は

**territory 内部イベント**

として発生する。

生成された個体は

- territory の unit として登録される
- reproduction / population control の対象となる

---

## 4. ライフサイクル段階

デモリッシャーのライフサイクルは  
以下の3段階で構成される。

### 4.1 Spawn

Spawn は **自然生成イベント**である。

特徴:

- territory 内部イベントとして発生
- Breeding Demolisher が実行する
- 新しい physical entity が生成される

Spawn のトリガーは

**Reproduction System**

によって決定される。

---

### 4.2 Active

Active は通常活動状態である。

条件:

- entity が world 上に存在する
- territory unit として登録されている

Active 状態の個体は

- reproduction
- population control
- interaction

の対象となる。

---

### 4.3 Death

Death は個体の消滅を意味する。

原因例:

- 戦闘による死亡
- script による削除
- map cleanup

Death が発生した場合

- territory unit から除外される
- population count が更新される

---

## 5. Hatch（プレイヤー卵）

Hatch は

**プレイヤーが所有する卵アイテムからの生成**

である。

これは

- reproduction system
- 自然生成

とは **別系統のイベント**である。

Hatch の詳細は  
**Interaction / Item 系仕様**で定義する。

---

## 6. サブシステム責務境界

デモリッシャー lifecycle に関する責務は以下の通り。

| Responsibility | Owner |
|---|---|
| Job orchestration | TJC |
| Territory enumeration | Breeding Demolisher |
| Reproduction decision | Breeding Demolisher |
| Spawn execution | Breeding Demolisher |
| Population control | Breeding Demolisher |

TJC は

- planning cycle
- execution dispatch

のみを担当する。

デモリッシャーの生成・削除などの  
**world mutation は Breeding Demolisher が担当する。**

---

## 7. ライフサイクル不変条件

以下は Breeding Demolisher が破ってはならない前提である。

1. すべての自然生成デモリッシャーは territory に所属する
2. virtual demolisher は存在しない
3. spawn は territory 内部イベントである
4. lifecycle は Spawn → Active → Death である

---

## 8. 本章の変更ルール

本章を変更する場合、以下への影響確認を必須とする。

- Reproduction
- PopulationControl
- Persistence

特に

- spawn ownership
- territory 所属

の変更は **破壊的変更**として扱う。