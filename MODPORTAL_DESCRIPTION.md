-- __BreedingDemolisher__/MODPORTAL_DESCRIPTION.md

(en) Breeding Demolisher Mod
Breeding Demolisher is a mod that turns demolishers into a persistent, growing ecosystem.

In this world, demolishers are no longer a one-time obstacle.
They lay eggs, hatch over time, and continue to increase if left unattended.
Neglecting them allows pressure to build gradually — and sometimes irreversibly.

■ Natural reproduction
- Demolishers periodically lay eggs.
- Eggs hatch after a delay.
- Population growth is regulated by:
  - The current demolisher population
  - Evolution factor
  - A dynamic population cap
- The population cap increases with evolution and can be reduced by research.
- Standard map-generated demolishers (small / medium / big with normal quality)
  are intentionally excluded from cap calculations,
  allowing breeding events to occur even on large explored maps.

■ Virtual entities (uncharted areas)
- Demolishers may exist virtually in ungenerated or uncharted chunks.
- Virtual demolishers:
  - Count toward population caps
  - Are materialized automatically when the area is generated
- This prevents sudden mass spawns and maintains stable pressure over time.

■ Research-based population control
- The infinite research **manis-demolisher-cap-down** reduces the effective population cap.
- Each level reduces the cap by 5%, down to a defined minimum.
- This allows long-running saves to remain manageable without disabling breeding.

■ Player interaction / Pets
- Eggs obtained through combat can be hatched into pet demolishers.
- Pets can be hostile, neutral, or friendly.
- Mature pets can reproduce and pass traits to offspring.
- Bred eggs tend to be higher quality than naturally dropped eggs.

Breeding Demolisher is designed for players who enjoy
long-term pressure, high-density combat, and ecosystem management —
not instant solutions.

For detailed mechanics and design decisions,
please see the GitHub specification and README.

------

(ja) Breeding Demolisher Mod

Breeding Demolisher は、
デモリッシャーを「一度きりの敵」ではなく、
**増殖し続ける生態系**として扱う Mod です。

この世界では、デモリッシャーは卵を産み、
時間とともに孵化し、放置すれば増え続けます。
無視された脅威は、徐々に、そして時には不可逆的に
世界へ圧力を与えていきます。

■ 自然繁殖
- デモリッシャーは定期的に卵を産みます
- 卵は時間経過で孵化します
- 増殖は以下に基づいて制御されます：
  - 現在のデモリッシャー数
  - 進化度
  - 動的な個体数上限（Cap）
- 上限は進化度に応じて上昇し、研究によって減少させることが可能です
- マップ自然生成の標準デモリッシャー
  （small / medium / big かつ normal 品質）は
  cap 計算から除外されます
  → 広大なマップでも繁殖イベントが発生するための設計です

■ 仮想デモリッシャー（未開拓領域）
- 未生成・未開拓チャンクでは、デモリッシャーは「仮想存在」として管理されます
- 仮想デモリッシャーは：
  - 個体数上限にカウントされ
  - チャンク生成時に自動的に実体化されます
- これにより、大量スポーンや UPS スパイクを防ぎつつ、
  世界全体への圧力を維持します

■ 研究による個体数制御
- 無限研究 **manis-demolisher-cap-down** により、
  有効な個体数上限を段階的に減少させられます
- 研究レベルごとに 5% 減少し、下限値が設定されています
- 長時間プレイでも繁殖を完全に止めず、管理可能な状態を維持します

■ プレイヤー介入 / ペット
- 戦闘で入手した卵から「ペットデモリッシャー」を孵化できます
- ペットは敵対／中立／友好の性質を持ちます
- 成熟したペットは繁殖し、特性を子孫へ引き継ぎます
- 繁殖による卵は、自然ドロップ卵より高品質になりやすい設計です

Breeding Demolisher は、
即効性のある解決を提供する Mod ではありません。
長期的な圧力、高密度戦闘、生態系管理を楽しむプレイヤー向けの Mod です。

詳細な仕様や設計思想については、
GitHub の spec / README を参照してください。

--- Update Note (v0.5.8) ---

(en) Population cap logic has been reworked. Caps are now dynamic, research-adjustable, and compatible with uncharted areas.
(ja) 個体数上限ロジックを刷新しました。上限は動的・研究対応となり、未開拓領域にも対応しました。

--- Update Note (v0.5.5) ---

(en) Pet breeding and genetics have been fully enabled. Egg processing and evolution have been simplified with new recipes, and moved from Aquilo to Vulcanus as part of this simplification.
(ja) ペットの繁殖と遺伝システムを本格的に有効化しました。卵の加工・進化はアクィロ限定からヴルカヌス限定になりました。

--- Update Note (v0.5.4) ---

(en) Egg processing recipes have been reworked.
(ja) 卵処理レシピを見直しました。