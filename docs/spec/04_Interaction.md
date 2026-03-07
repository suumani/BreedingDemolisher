# Interaction — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/04_Interaction.md`

Status: Active  
Scope: Player and world interaction

---

## 0. 本章の位置づけ

ID: BD-INT-000

本章は Breeding Demolisher における  
**プレイヤーおよびゲーム挙動との相互作用（Interaction）**を定義する。

対象:

- 撃破イベント
- 卵生成
- 卵孵化（Hatch）
- ペット
- 通知
- UI

本章は以下の仕様を前提とする。

- 個体の存在条件は `01_CoreLifecycle.md`
- 自然生成は `02_Reproduction.md`
- 個体数制御は `03_PopulationControl.md`
- 永続化は `05_Persistence.md`

---

# 1. Combat Death

## 1.1 撃破イベント定義

ID: BD-INT-010

撃破イベントとは  
**デモリッシャーが戦闘により死亡した場合**を指す。

以下を満たす場合、撃破イベントとして扱う。

- プレイヤー勢力による撃破
- プレイヤー関与による間接撃破

---

## 1.2 撃破イベント対象外

ID: BD-INT-011

以下は撃破イベントに含めない。

- despawn
- script removal
- migration cleanup
- 非管理対象 entity

---

# 2. Egg Generation

## 2.1 卵生成定義

ID: BD-INT-020

卵生成とは

**Interaction イベントを起点として卵アイテムを生成する処理**

である。

卵生成は

- Interaction 系イベント
- Reproduction system とは独立

である。

---

## 2.2 卵生成条件

ID: BD-INT-021

以下を満たす場合、卵生成を評価する。

- Interaction イベントが成立
- entity が繁殖対象種
- suppress 条件を満たさない

---

## 2.3 生成結果

ID: BD-INT-022

卵生成成立時

- 卵は **1個のみ生成**
- 卵種別は entity name に基づく

---

## 2.4 責務分離

ID: BD-INT-023

卵生成処理は以下を行ってはならない。

- population count 更新
- reproduction 判定変更
- mutation 判定

---

# 3. Hatch

## 3.1 Hatch 定義

ID: BD-INT-030

Hatch とは

**卵アイテムから entity が生成される処理**

である。

これは

- Reproduction system とは独立
- Interaction 系イベント

である。

---

## 3.2 Hatch 条件

ID: BD-INT-031

以下を満たす場合 Hatch が成立する。

- egg item が有効
- hatch 判定成功

---

## 3.3 Hatch 結果

ID: BD-INT-032

Hatch 成立時

- entity が生成される
- entity force は定義された勢力

---

## 3.4 Population Control

ID: BD-INT-033

Hatch 時には Population Control を適用する。

- cap 判定は **孵化直前** に行う
- cap 到達時は **孵化を行わない**
- この場合 **卵アイテムは消費されない**

---

# 4. Pet Demolishers

## 4.1 ペット定義

ID: BD-INT-040

ペットとは

**卵から孵化したプレイヤー友好 entity**

である。

---

## 4.2 ペット勢力

ID: BD-INT-041

ペットは以下の force に属する。

- player
- enemy
- mod defined force

---

## 4.3 Growth

ID: BD-INT-042

ペットは **growth** を持つ。

growth は

- 数値
- entity 単位

で管理される。

---

## 4.4 Growth 獲得

ID: BD-INT-043

growth は以下で増加する。

- enemy 撃破
- Interaction イベント

---

## 4.5 Growth 可視性

ID: BD-INT-044

growth は

- UI で表示可能
- internal logic に使用

---

# 5. Pet Reproduction

## 5.1 繁殖評価

ID: BD-INT-050

ペット繁殖は

**TJC による定期評価**

として実行される。

評価周期

- **10分 planning cycle**

---

## 5.2 評価単位

ID: BD-INT-051

評価単位は

**1 pet = 1 execution step**

である。

---

## 5.3 繁殖結果

ID: BD-INT-052

繁殖評価の結果は以下の3種類。

1. 成熟度未達  
2. パートナー不在による単為生殖（劣化コピー個体）  
3. パートナー存在による繁殖（強化個体）

---

## 5.4 パートナー探索

ID: BD-INT-053

探索対象

- 成熟ペット

---

## 5.5 相手選択

ID: BD-INT-054

候補が複数存在する場合

**最も近い個体**

を選択する。

---

# 6. Notifications

## 6.1 通知目的

ID: BD-INT-060

通知は

**重要イベントのプレイヤー通知**

である。

---

## 6.2 通知対象

ID: BD-INT-061

対象例

- ペット繁殖
- ペット死亡

---

## 6.3 非対象

ID: BD-INT-062

対象外

- reproduction skip
- internal suppression

---

# 7. UI

## 7.1 UI 目的

ID: BD-INT-070

UI は

**状態の可視化**

である。

---

## 7.2 UI 表示対象

ID: BD-INT-071

例

- growth
- force
- egg info

---

## 7.3 UI 非表示

ID: BD-INT-072

非表示例

- internal probability
- cap state

---

## 7.4 UI 責務

ID: BD-INT-073

UI は

- 状態変更を行わない
- 判定を行わない

---

# 8. Interaction 不変条件

ID: BD-INT-080

以下は Interaction 不変条件である。

- Interaction はイベント起点
- reproduction 判定を変更しない
- population control を変更しない