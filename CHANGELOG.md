# Changelog

## v0.5.5

### EN

#### Gameplay / Core Systems
- Added full **genetic breeding system** for pet demolishers
- Eggs now carry genetic data persistently via item tags
- Genetic information is preserved across transport, storage, and hatching

#### Pet Demolishers
- Pet demolishers now grow by defeating enemies nearby
- Growth-based breeding triggers implemented
- Breeding occurs when mature demolishers are close to each other
- Nearest mature partner is selected automatically
- Breeding produces **genetic eggs** with inherited traits

#### Death & Drops
- When a pet demolisher is defeated, it may drop a genetic egg
- Drop conditions depend on growth and faction
- Clear notifications are shown when:
  - A pet demolisher is defeated
  - A breeding egg is laid

#### Recipes & Progression
- Introduced **dual progression routes** for new species evolution:
  - **Cryogenics (deterministic, high-cost)**
  - **Biochamber (probabilistic, high-cost, 20% success)**
- Biochamber evolution failures now yield spoilage
- All egg processing and evolution recipes are now **restricted to Vulcanus**
  (pressure 4000 condition)

#### UI & Feedback
- Added clear, localized notifications for:
  - Egg laying (breeding)
  - Pet demolisher death
  - Genetic egg drops
- Fixed localization handling to fully support localized strings
- Improved clarity so players can recognize important events immediately

#### Design Notes
- Demolishers are native to **Vulcanus**
- Egg processing and evolution must be performed on Vulcanus
- Hatched demolishers can be transported and deployed elsewhere
- New species evolution eventually leads to **friendly demolishers** usable by the player

---

### JP

#### ゲームプレイ / 中核システム
- ペットデモリッシャー向けの **遺伝繁殖システム**を実装
- 卵が遺伝情報を item tag として恒久的に保持するようになりました
- 輸送・保管・孵化を通して遺伝情報が失われません

#### ペットデモリッシャー
- ペットは周囲の敵を倒すことで成長するようになりました
- 成長度に基づく繁殖判定を導入
- 成熟したデモリッシャー同士が近距離にいる場合に繁殖が発生
- 複数候補がいる場合は **最も近い個体**が自動選択されます
- 繁殖により **遺伝情報を持つ卵**が生成されます

#### 死亡・ドロップ
- ペットデモリッシャーが倒された際、条件に応じて遺伝子付き卵をドロップ
- ドロップ条件は成長度および勢力に依存します
- 以下の状況で明確な通知が表示されます：
  - ペットデモリッシャーが倒されたとき
  - 繁殖によって卵が産まれたとき

#### レシピ / 進行ルート
- 新種進化に **2系統の進行ルート**を追加：
  - **低温プラント（確定・高コスト）**
  - **バイオチャンバー（確率・高コスト、成功率20%）**
- バイオチャンバー進化の失敗時は spoilage を生成
- 卵の加工・進化レシピはすべて **ヴルカヌス限定**になりました  
  （気圧4000条件）

#### UI / フィードバック
- 以下の重要イベントにローカライズ対応の通知を追加：
  - 卵の産卵（繁殖）
  - ペットデモリッシャーの死亡
  - 遺伝子付き卵のドロップ
- ローカライズ処理を整理し、文字列置換の不具合を解消
- プレイヤーが重要な出来事に気づきやすくなりました

#### 設計メモ
- デモリッシャーは **ヴルカヌス原産**の生物です
- 卵の加工・進化はヴルカヌスでのみ可能
- 孵化後のデモリッシャーは他惑星へ輸送・運用できます
- 新種進化は最終的に **友好的なデモリッシャー**へとつながります


## v0.5.4

### EN

#### UI / Structure
- Reorganized BreedingDemolisher egg definitions
- Introduced dedicated subgroups for clearer item/recipe ordering
- Egg workflow is now clearly separated into:
  Egg → Processing → Growth

#### Recipes (Major Changes)
- Freeze / Unfreeze recipes have been significantly simplified
- Removed excessive material requirements from preservation steps
- New species creation remains a high-cost process by design

#### Localization
- Completed localization for all egg-related recipes
- Fixed mixed-language tooltip issues

#### Design Notes
- Active demolishers cannot be crafted directly
- They are born only through egg growth and breeding

---

### JP

#### UI / 構造
- BreedingDemolisher の卵関連定義を再構成
- 独自 subgroup を導入し、表示順を整理
- 卵 → 処理 → 成長 の流れを明確化

#### レシピ（大きな変更）
- 凍結 / 解凍レシピを大幅に簡素化
- 過剰だった素材要求を撤廃
- 新種生成は引き続き高コスト工程として維持

#### ローカライズ
- 卵関連レシピ全体の翻訳を整備
- 言語混在のツールチップ問題を解消

#### 設計メモ
- 有効種デモリッシャーは直接クラフト不可
- 卵の繁殖・成長によってのみ誕生します