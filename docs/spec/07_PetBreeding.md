# Pet Breeding — Breeding Demolisher
`__BreedingDemolisher__/docs/spec/07_PetBreeding.md`

Status: Active  
Scope: Pet demolisher breeding

---

## 0. 本章の位置づけ

ID: BD-PET-000

本章は

**Pet demolisher の繁殖**

を定義する。

Interaction system の一部として扱う。

---

# 1. Job Execution

ID: BD-PET-010

Pet breeding は

**TJC job**

として実行される。

周期

- 10分 planning cycle

---

# 2. Execution Unit

ID: BD-PET-020

execution step は

**1 pet = 1 step**

である。

---

# 3. Planning

ID: BD-PET-030

planning phase は

- pet 一覧取得
- 評価対象 pet 列挙

を行う。

対象

- storage.my_demolishers

---

# 4. Execution

ID: BD-PET-040

execution step は

1 pet を評価する。

<<<CODEBLOCK START>>>

pet = resolve_pet(step_index)

if pet.growth < threshold:
    result = immature
    return

partner = find_partner(pet)

if partner == nil:
    result = parthenogenesis
    spawn_degraded_copy()
else
    result = reproduction
    spawn_enhanced_offspring()

<<<CODEBLOCK END>>>

---

# 5. Breeding Result

ID: BD-PET-050

繁殖結果は3種類。

1. immature
2. parthenogenesis
3. reproduction

---

# 6. Partner Selection

ID: BD-PET-060

候補が複数存在する場合

**最も近い個体**

を選択する。

---

# 7. Egg Creation

ID: BD-PET-070

繁殖成立時

- 卵アイテム生成
- Notification 発生

---

# 8. Population Control

ID: BD-PET-080

pet population cap は

**孵化時**

に適用される。

cap 到達時

- hatch 失敗
- egg は消費しない

---

# 9. Persistence

ID: BD-PET-090

pet state は

storage.my_demolishers

で管理する。