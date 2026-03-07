# Persistence — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/05_Persistence.md`

Status: Active  
Scope: Persistence and state recovery

---

## 0. 本書の位置づけ

ID: BD-PERS-000

本書は Breeding Demolisher の  
**永続化と状態復元**を定義する。

対象

- storage
- territory metadata
- pet state
- egg gene
- migration

---

# 1. Persistence 目的

ID: BD-PERS-010

目的

- save/load consistency
- metadata persistence
- migration support

Persistence は

**entity lifecycle を管理しない。**

---

# 2. storage 規約

ID: BD-PERS-020

永続データは

storage

に格納する。

原則

- runtime-only データと分離
- version 互換性を保持

---

# 3. 永続対象

ID: BD-PERS-030

対象

### Territory Metadata

保持する情報は

**再解決可能な最小情報のみ**

例

- territory representative chunk coordinates

LuaTerritory や LuaChunk オブジェクト自体は保存しない。

---

### Pet State

例

- growth
- ownership
- identity metadata

---

### Egg Gene

例

- parent entity
- gene metadata

---

# 4. Entity と storage

ID: BD-PERS-040

entity は

**world 上の physical entity**

である。

storage は

**metadata のみ**

保持する。

---

# 5. Restore

ID: BD-PERS-050

ロード時

- storage を正として復元
- entity と整合

---

# 6. Rebuild

ID: BD-PERS-060

整合不一致時

- rebuild 実行

例

- entity missing
- territory mismatch

---

# 7. Runtime Data

ID: BD-PERS-065

以下は runtime-only データであり永続 source ではない。

例

- reproduction planning result
- execution plan store

---

# 8. Migration

ID: BD-PERS-070

storage 構造変更時

migration を実行する。

結果

OK  
SKIP  
FAIL

---

# 9. Persistence 不変条件

ID: BD-PERS-080

- storage は唯一の永続 source
- entity lifecycle は storage に依存しない
- storage は entity の代替ではない