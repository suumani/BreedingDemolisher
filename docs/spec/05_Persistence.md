# Persistence — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/05_Persistence.md`

**Version:** v0.1 (draft)  
**Scope:** Breeding Demolisher

---

## 0. 本書の位置づけ

**ID: BD-PERS-000**

本書は、Breeding Demolisher における  
**永続化（Persistence）と状態復元**に関する仕様を定義する。

対象は以下である。

- `storage` を用いた永続データの保持
- 仮想デモリッシャー（Virtual Demolishers）の永続管理
- セーブデータ移行（Migration）
- 再計算・再構築（Rebuild）

本書は、以下の仕様を前提とする。

- 個体数制御は `03_PopulationControl.md` に従う
- 繁殖・進化は `02_Reproduction.md` に従う
- Interaction の通知・UIは `04_Interaction.md` に従う
- 観測点は `90_Observability.md` に従う

---

## 1. 永続データの基本方針

### 1.1 永続化の目的

**ID: BD-PERS-010**

永続化の目的は以下である。

- セーブ／ロードを跨いでも挙動を一貫させる
- 仮想個体を含む管理状態をロストさせない
- 更新・移行が必要な変更を安全に適用できるようにする

---

### 1.2 永続化の責務境界

**ID: BD-PERS-011**

Persistence は以下の責務を持つ。

- 永続データの **格納形式・復元規約** を定義する
- 更新時の **移行手順・互換性方針** を定義する

Persistence は以下を直接決定しない。

- 繁殖判定・変異判定・進化ルート
- cap の数値・抑止条件
- UI 表示・通知の有無

---

## 2. storage 使用規約

### 2.1 収納先の原則

**ID: BD-PERS-020**

本 Mod の永続データは、原則として `storage` 配下に集約する。

- グローバルデータを `global` 直下に散在させない
- runtime-only な一時値は、永続データと混在させない

---

### 2.2 キー設計方針

**ID: BD-PERS-021**

storage のキーは以下を満たすこと。

- 意味が明確であること（名前から用途が追える）
- 将来の拡張に耐えること（ネスト・version付与を許容）
- 破壊的変更が発生する場合、Migration で吸収可能であること

---

## 3. 仮想デモリッシャーの永続管理（概念）

### 3.1 仮想デモリッシャーの定義

**ID: BD-PERS-030**

仮想デモリッシャーとは、  
**未生成または未開拓チャンク内に存在する論理的な個体**である。

仮想個体は以下の性質を持つ。

- サーフェイス上には物理的に存在しない
- `storage` に構造化データとして保持される
- 対応チャンク生成時に実体化され得る

---

### 3.2 仮想個体の必須保持情報（未確定）

**ID: BD-PERS-031 (TBD)**

仮想個体が保持すべき必須情報は以下を含む必要がある。

- 識別子（vid）
- サーフェイス
- 位置（チャンクまたはタイル座標）
- 種別（species）
- 生成経路（wild / pet / drop 等、必要に応じて）

※ 実際の storage 形式はコード確認後に確定する。

---

### 3.3 cap との関係（再掲）

**ID: BD-PERS-032**

仮想デモリッシャーは、  
`03_PopulationControl.md` に定義された counted population に含まれる。

- 仮想個体は counted population の計算対象である
- 他 Mod 管理の仮想個体は counted population から除外する

---

### 3.4 観測要件

**ID: BD-PERS-033**

仮想個体の生成・実体化・削除は、  
`90_Observability.md` の OBS-VIRT-001 に従い観測可能でなければならない。

---

## 4. 復元・再構築（Rebuild）

### 4.1 復元の基本原則

**ID: BD-PERS-040**

ロード時の復元処理は以下を満たす。

- storage の内容を正として状態を復元する
- 可能な限り軽量であること
- ワールド状態を破壊的に変更しないこと

---

### 4.2 再計算が必要となる契機（未確定）

**ID: BD-PERS-041 (TBD)**

再計算（Rebuild）が必要となる契機は、実装確認後に確定する。

候補：
- Mod 更新によりデータ形式が変わった場合
- 仕様変更により整合維持が必要となった場合

---

## 5. セーブデータ移行（Migration）

### 5.1 移行が必要となる条件

**ID: BD-PERS-050**

以下の場合、Migration を実施しなければならない。

- storage の構造や意味が変わる（破壊的変更）
- 旧形式データのままでは仕様が満たせない

---

### 5.2 移行の原則

**ID: BD-PERS-051**

Migration は以下を原則とする。

- 移行対象と変換内容が明示的であること
- 暗黙的な吸収（サイレント変換）を行わないこと
- 失敗時は FAIL として観測できること

---

### 5.3 移行と観測

**ID: BD-PERS-052**

Migration の実行結果は、必ず観測可能でなければならない。

- outcome : OK | SKIP | FAIL
- reason（必要に応じて）
- 影響件数（可能な範囲で）

※ 観測点IDは Observability 側で追加定義する。

---

## 6. Persistence の不変条件

**ID: BD-PERS-060**

以下は Persistence の不変条件である。

- storage を唯一の永続ソースとして扱う
- 仮想／物理の二重管理を起こさない
- 復元・移行はワールドを破壊しない
- 観測不能な変更を行わない

---

## 7. 未確定項目（コード確認が必要）

本書の以下は、実装確認後に確定する。

- BD-PERS-031: 仮想個体の storage 形式・必須フィールド
- BD-PERS-041: Rebuild の契機と範囲
- Migration の観測点IDとログ項目（Observability 側）