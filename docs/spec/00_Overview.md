# System Overview — Breeding Demolisher
`docs/spec/00_Overview.md`

**Status:** Active  
**Scope:** Breeding Demolisher

---

# 0. 本書の目的

本書は Breeding Demolisher における  
**SystemSpecification 全体の入口（Overview）**として機能する。

本書は以下を整理する。

- Breeding Demolisher が **どのようなシステムであるか**
- システムの **責務と境界**
- システムの **実行モデル**
- SystemSpecification 文書構成

本書は **個別挙動の詳細を定義しない。**

繁殖条件、人口制御、各種判定などの詳細は  
後続の SystemSpecification 文書に委譲する。

---

# 1. システムの全体像

Breeding Demolisher は、

> **デモリッシャーの生態系を形成する Mod**

である。

ヴルカヌス上のデモリッシャーは

- 繁殖
- 個体増加
- テリトリー内での自然生成

を行う。

これにより

- デモリッシャーの持続的存在
- プレイヤー拠点への圧力
- 生態系としての敵勢力

が形成される。

---

# 2. プレイヤー体験

Breeding Demolisher は次のプレイヤー体験を提供する。

- デモリッシャーの個体数が自然増加する
- 生態系としての敵勢力が形成される
- プレイヤーが個体群を管理・制御できる

また、本 Mod では

- **野生デモリッシャーの自然繁殖**
- **プレイヤーが飼育するペットデモリッシャー**

という二種類の繁殖システムを提供する。

プレイヤーは

- 野生個体群の脅威
- ペット個体群の育成

という異なる関係性を持つ。

---

# 3. システム責務

Breeding Demolisher の責務は次の通り。

| Responsibility | Owner |
|---|---|
| デモリッシャー生態管理 | Breeding Demolisher |
| 繁殖判定 | Breeding Demolisher |
| 人口制御 | Breeding Demolisher |
| プレイヤーとのインタラクション | Breeding Demolisher |

本 Mod は次を責務としない。

- デモリッシャーAI制御
- デモリッシャー移動ロジック
- world generation
- 敵AI行動制御

---

# 4. 実行モデル

Breeding Demolisher の処理は  
**ManisTotalJobController（TJC）**によって駆動される。

```
TJC
↓
territory enumeration
↓
reproduction decision
↓
spawn execution
```

Breeding Demolisher は

- scheduler
- tick driver

を持たず、

**ドメインロジックのみを実装する。**

---

# 5. デモリッシャーライフサイクル

デモリッシャーは  
次のライフサイクルに従う。

```
spawn
↓
lifecycle management
↓
reproduction
↓
population control
```

ライフサイクルの詳細は  
`01_CoreLifecycle.md` に定義される。

---

# 6. 繁殖システム

Breeding Demolisher の中核は  
**Reproduction System** である。

繁殖は次の二種類に分類される。

```
Wild Reproduction
Pet Breeding
```

| System | Role |
|---|---|
| Wild Reproduction | 野生個体の自然増殖 |
| Pet Breeding | プレイヤー所有個体の繁殖 |

詳細は次の文書に定義される。

- `02_Reproduction.md`
- `06_WildReproduction.md`
- `07_PetBreeding.md`

---

# 7. Population Control

Breeding Demolisher は  
個体数制御を行う。

人口制御は

- spawn 上限
- counted population
- territory context

を基準として行われる。

詳細は  
`03_PopulationControl.md` に定義される。

---

# 8. Interaction

Breeding Demolisher は  
プレイヤーとのインタラクションを提供する。

例：

- ペットデモリッシャー
- 通知
- 戦闘関係

詳細は  
`04_Interaction.md` に定義される。

---

# 9. Persistence

Breeding Demolisher は  
デモリッシャー状態を保存する。

保存対象は

- 個体情報
- 繁殖状態
- 所属テリトリー

などである。

詳細は  
`05_Persistence.md` に定義される。

---

# 10. 境界と依存関係

Breeding Demolisher は  
次のシステムと連携する。

| System | Responsibility |
|---|---|
| TJC | job orchestration |
| Factorio enemy system | AI / pathfinding |

本 Mod は次の処理を行わない。

- AI制御
- 移動ロジック
- world generation

---

# 11. 観測性

Breeding Demolisher は  
システム挙動を観測可能にする。

観測情報には次が含まれる。

- reproduction result
- population state
- lifecycle state

観測仕様は  
`90_Observability.md` に定義される。

---

# 12. テスト方針

Breeding Demolisher のテストは  
**仕様を基準として設計される。**

テストの基本方針は  
`TestPolicy.md` に定義される。

---

# 13. SystemSpecification 文書構成

Breeding Demolisher の仕様は  
以下の文書で構成される。

```
00_Overview.md
01_CoreLifecycle.md
02_Reproduction.md
03_PopulationControl.md
04_Interaction.md
05_Persistence.md
06_WildReproduction.md
07_PetBreeding.md
08_TJCIntegration.md
90_Observability.md
TestPolicy.md
```

---

# 14. 設計意図

Breeding Demolisher は、

> **デモリッシャーを単なる敵ではなく、生態系として存在させる**

ことを目的として設計された。

このシステムは

- 生態系としての敵勢力
- 個体群の自然増殖
- プレイヤーによる飼育

を通じて

**Factorio に新しい敵生態システムを導入する。**

---