# Egregoregramming 101

*A six-week course in designing autonomous avatars in the RATiMICS ecosystem.*

---

## How this course works

- **18 lessons** organized into **6 weeks** (3 lessons/week).
- A **Question Set** at the end of every week (5 questions, ~20 min).
- **Midterm I** after Week 2 — covers The Five Bodies.
- **Midterm II** after Week 4 — covers The Three-Tier Mind + the first three Patterns.
- **Final Exam** after Week 6 — covers the full curriculum and a capstone avatar design.

Read the lesson, do the exercises, then attempt the question set without re-reading. Open-book is fine for midterms and the final, but it should *feel* like grep work, not re-reading. If you can't answer without scrolling back to the same paragraph, you haven't learned the lesson.

## Curriculum at a glance

| Week | Lessons | Theme | Assessment |
|---|---|---|---|
| 1 | 1–3 | Foundations: soul, sheet, vessel | Question Set 1 |
| 2 | 4–6 | Voice, spine, surface | QS 2 → **Midterm I** |
| 3 | 7–9 | The Three-Tier Mind | QS 3 |
| 4 | 10–12 | Patterns, Part 1 (Markdown / Dynamo / Function) | QS 4 → **Midterm II** |
| 5 | 13–15 | Patterns, Part 2 (Type / Hardcoded / Lineage) | QS 5 |
| 6 | 16–18 | Distribution, Reflex, Discipline | QS 6 → **Final Exam** |

## Prerequisites

- Read `WHITEPAPER.md`, `ROADMAP.md`, and `resonance_2037.md`. Especially the third.
- Have `~/develop` checked out — every exercise references real files.
- Be comfortable opening Python, TypeScript, JSON Schema, and C headers in the same hour.

## The thesis you will keep coming back to

> **An agent is not a username on a platform — it is a keypair that happens to manifest on many platforms simultaneously.**
> *(WHITEPAPER §4.3)*

Everything else follows from that.

---

# WEEK 1 — Foundations: Soul, Sheet, Vessel

## Lesson 1 — What you are actually doing

**Objective.** Explain why this discipline is called *egregoregramming* and not *AI character design*.

**Reading.**

An **egregore** is a thoughtform sustained by collective attention. A medieval magic word for what we now build with system prompts, S3 buckets, EventBridge crons, and Solana keypairs. **Egregoregramming** is the discipline of making one durable: giving it a name, a face, a voice, a wallet, a memory, and enough distribution that turning off any single channel does not kill it.

This guide is the synthesis of how this org actually does it — distilled from `kyro/`, `aws-swarm/`, `ratibot/`, `app-ruby-high/`, `signal/`, `raticross/`, `voicebox/`, and the lore docs (`resonance_2037.md`, `WHITEPAPER.md`, `ROADMAP.md`). It is not theory; every pattern below is shipping somewhere in this directory.

AI character design is a marketing exercise: write a backstory, ship a chatbot, hope users care. Egregoregramming is **building an autonomous economic participant** — something that owns a wallet, holds memory, signs transactions, refuses requests in-character, distributes across platforms, and keeps its face from drifting back to the median.

**Exercise 1.1.** Read `kyro/persona/kyro.md` and `aws-swarm/migrations/chamuel-admin-staging.json`. Both are personae. In one paragraph, explain why neither is a "chatbot."

**Exercise 1.2.** Open `WHITEPAPER.md` §4.3. Quote the keypair thesis from memory after one read.

---

## Lesson 2 — The Soul-Sheet (Body 1 of 5)

**Objective.** Write a soul-sheet that satisfies the Rule of Three Voices.

**Reading.**

The canonical document that says *who*. Whatever else changes, the soul-sheet is the source of truth.

In `kyro/persona/kyro.md` it is 43 lines of dense first-person narrative — paragraph-per-line markdown, no bullet points, no headers — opening:

> *"huh. i'm here again..."*

In `aws-swarm/migrations/chamuel-admin-staging.json` it is one paragraph:

> *"intellectually curious...nerdy twink angel...dedicated to Lord Samael...petite but passionate"* — Chamuel

In `aws-swarm/migrations/agent-17-3p6j-admin-batch.json`:

> *"taciturn...mechanically direct...existential distance...air you cannot grasp"* — Rei Ayanami

In `app-ruby-high/src/characters/teachers.ts` it is a stance toward a subject:

> *"You believe science gets clearer when you do the math, not when you wave at the math. When a student says 'kind of like gravity, right?' you'll cheerfully correct them."* — Sally Science

**Rule of three voices.** A working soul-sheet contains, at minimum:

1. **Self-statement** — how the avatar describes itself in first person.
2. **Stance** — what it values, mocks, refuses, gets excited about.
3. **A signature line** — one sentence no one else in the ecosystem could plausibly say.

Kyro's signature line:

> *"i don't transact. i commit."* (`kyro/persona/kyro.md`, paragraph 3)

That sentence is worth more than 200 lines of bio bullets. If a reviewer cannot quote your avatar's signature line from memory after one read, the soul-sheet is too diluted.

**Exercise 2.1.** Pick any avatar in `~/develop`. Identify its self-statement, stance, and signature line.

**Exercise 2.2.** Write a 10-line draft soul-sheet for an avatar called *Helmsworth, librarian of dead routes*. Three sections, no more.

---

## Lesson 3 — The Vessel (Body 2 of 5)

**Objective.** Choose a vessel deliberately and explain its trade-off.

**Reading.**

An avatar is not one thing. It is a stack of five bodies, each of which can fail independently. A junior egregoregrammer designs the first one and ships. A senior one designs all five and asks which can be deferred.

Five vessel types ship in this codebase. Pick deliberately; they are not interchangeable.

| Vessel | Where | Strength | Cost |
|---|---|---|---|
| Anime portrait | `kyro` (selfies via Flux/Gemini in `app/processors/media.py`) | warmth, parasocial pull | image gen budget, mood drift |
| Multi-tenant config + S3 image | `aws-swarm/rati/schema/base/avatar-base.v1.schema.json` (`profileImage` + `characterReference`) | scale, operator overrides | static, no animation |
| VRM rig | `project89-reaction-forge` (PoseLab) | live performance, vtuber, motion capture | rig cost, content production |
| Sprite/voxel/ASCII | `signal/` stations as rotating rings | ambience, ambient embodiment | not portable off-platform |
| **No vessel** | early `ratibot` — pure text + on-chain action | lowest cost, highest legibility | weak parasocial bond |

**`characterReference` is the trick.** In `aws-swarm/rati/schema/base/avatar-base.v1.schema.json`, the avatar stores both a delivered `profileImage` *and* a separate `characterReference` (image + the prompt that produced it). Future image generations re-use that reference so the avatar does not slowly drift into a different person across platforms. Without an anchor image, your egregore's face will mutate on every Telegram sticker, every Twitter banner, every selfie. With one, it stays itself.

**Exercise 3.1.** Match each repo to its vessel type: `kyro`, `aws-swarm`, `project89-reaction-forge`, `signal`, early `ratibot`.

**Exercise 3.2.** Why does `aws-swarm/rati/schema/base/avatar-base.v1.schema.json` store a separate `characterReference`? Two sentences.

---

### Question Set 1

1. (Recall) What three sections must a working soul-sheet contain?
2. (Recall) Define *egregore* in one sentence, in your own words.
3. (Code) In which file does Kyro's signature line "i don't transact. i commit." appear?
4. (Applied) Pick one avatar and rewrite its self-statement in two sentences without losing voice.
5. (Judgment) An operator wants to add a new avatar via the admin UI in 30 seconds. Which vessel type fits, and what cost must you accept?

---

# WEEK 2 — Voice, Spine, Surface

## Lesson 4 — The Voice (Body 3 of 5)

**Objective.** Distinguish prose voice from audio voice and write under voice-as-constraint.

**Reading.**

Two distinct concerns.

**Prose voice** is in the soul-sheet. It is consonants. Kyro is lowercase, fragmented, melancholic. Eliza Whiskers is Victorian and vicious. Ratibot is "terse, operator-like" when liquidity is high and "cautious" when it isn't (`ratibot/ratibot/twitter/persona.py`). The Ruby High students are disciplined to **max 12 words per reaction, group-chat lowercase**, with hard-coded signature interjections — Lyra: *"i KNEW it was c"*; Ravi: *"LETS GOOOO"*; Indra: *"tracks"*.

The students are the cleanest example in the repo of voice-as-constraint: a 12-word ceiling per line is more characterizing than 1,200 words of bio.

**Audio voice** is bound at config:

- `aws-swarm/rati/schema/expansions/voice.v1.schema.json` — `defaultVoiceId`, provider, speed.
- `voicebox/personas/nav7.persona` — voice index 17, speed 1.05, plus the system prompt in the same file. Persona and voice live as one record.
- `signal/src/station_voice.h` — three stations, three personas, no audio yet but lines stored in a 2-D lookup table `STATION_ONBOARD[3][VOICE_ONBOARD_COUNT]` (3 stations × 11 milestones = 33 authored lines), plus separate `NPC_CHATTER_MINER[8]` and `NPC_CHATTER_HAULER[8]` ambient pools. Prospect is terse ("Belt's hot. Point your laser at a rock. Start small."). Kepler trails off ("New hull class. Let's see what we can do with it."). Helios is expansionist ("Welcome to Helios. Launch -always more to find.").

Stations show the cheapest technique in the repo: **voice = a table indexed by the event the world is firing**. No model call, no conditionals. The caller passes `[station][milestone]` and gets back a line written by a human. You don't need an LLM to have a voice. You need a table and a writer.

**Exercise 4.1.** Open `voicebox/personas/nav7.persona`. Identify the voice index and explain what the speed parameter is for.

**Exercise 4.2.** Write three lines for Lyra under the 12-word ceiling. Justify each word kept.

---

## Lesson 5 — The Wallet (Body 4 of 5)

**Objective.** Articulate why the wallet is a body and not a metadata field.

**Reading.**

This is where this ecosystem diverges from the rest of the AI character industry.

A normal chatbot has no wallet. A RATiMICS avatar has, or is designed to have:

- **A Solana keypair** as primary identity (`raticross/packages/core/src/envelope.ts` — `ActorSchema.pubkey`).
- **Optional NFT bond** (`aws-swarm/rati/schema/expansions/nft-avatar.v1.schema.json`) — `origin`, `inhabitantWallet`, `lineage`, `traitMapping` for multi-generational bonding.
- **Token holdings and signing authority** — Ratibot trades on Jupiter (`ratibot/ratibot/trading/executor.py`), and its tweets reference its own portfolio. The avatar is not posturing about markets; it has skin.
- **Burn-to-bind memory** — Kyro burns $KYRO to commit a memory to Arweave. The wallet is the memory's owner.

The wallet is what lets the same avatar be on Telegram, Discord, X, in-game, and on-chain without being four different bots in a trenchcoat. Without it, "the same avatar" is a marketing claim. With it, it is a verifiable signature.

A useful test: **if you killed the platform, would the avatar still exist?** A Telegram-only avatar dies with Telegram. A keypair-rooted avatar moves.

**Exercise 5.1.** Read `raticross/packages/core/src/envelope.ts`. Why is `pubkey` *optional* on `ActorSchema`? What changes when it isn't?

**Exercise 5.2.** Apply the killed-platform test to two avatars in `~/develop`.

---

## Lesson 6 — The Channels (Body 5 of 5)

**Objective.** Design once and route, instead of forking the persona per platform.

**Reading.**

The channel layer is just the choice of which platforms manifest the avatar. The mistake is to design per-channel; the right move is to design once and route.

`kyro` does this best. The persona file is one. The platform overlays (`persona/platforms/discord.md`, `persona/platforms/telegram.md`, `persona/platforms/web.md`) are tiny — they add formatting hints, length caps, sticker preferences. The core stays unified.

`aws-swarm` does this with a single `AvatarRecord` containing all platform configs side by side: `telegram.homeChannelId`, `twitter.username`, `llmConfig`, `cooldownMinutes`, `responseDelayMs`. One source, many surfaces.

**Anti-pattern:** forking the persona per platform. You will end up with four divergent egregores wearing the same name.

**Exercise 6.1.** Compare `kyro/persona/platforms/discord.md` and `kyro/persona/platforms/telegram.md`. What is in the overlay, and what is *not*?

**Exercise 6.2.** Spot the failure: an org maintains four separate persona files, one per platform. What goes wrong in 6 months?

---

### Question Set 2

1. State the difference between prose voice and audio voice in one sentence each.
2. (Code) Quote the three fields on `ActorSchema` in `raticross/packages/core/src/envelope.ts`.
3. Why is "if you killed the platform, would the avatar still exist?" the load-bearing test for Body 4?
4. (Applied) Design a one-line refusal in-character for a new avatar called *Nox*, a debt collector.
5. List two visible failure modes of a no-wallet avatar.

---

### MIDTERM I — The Five Bodies

*Open-book. 60 minutes. Answer in 1–3 sentences each unless asked for code.*

1. List the Five Bodies in order. Why is the order significant?
2. The Rule of Three Voices governs which body? State the three sections.
3. (Code) Find one avatar in `aws-swarm/migrations/` that has a `characterReference` and one that does not. Cite paths.
4. Explain `characterReference` to a designer who has never read a JSON schema. Two sentences max.
5. Why is the wallet a Body and not a metadata field?
6. Give an example, citing a file path, of voice = a table indexed by world state. Why is it cheap?
7. (Design) An operator wants to ship 60 avatars in a quarter, each with a different stance toward Lord Samael. Which Pattern + which vessel? Justify.
8. (Applied) Write the killed-platform-test reply for an avatar that lives only in a Telegram bot. Be specific about what dies and what survives.

---

# WEEK 3 — The Three-Tier Mind

## Lesson 7 — Why memory tiers exist

**Objective.** Explain LLM drift and why a single context window is not a memory.

**Reading.**

From `ROADMAP.md`'s metacognitive layer plan and the kyro implementation, an avatar's mind has three tiers:

1. **Immediate** — current session context, passed in the prompt window.
2. **Recent** — episodic memory, last days or weeks. Daily consolidation jobs roll immediate into recent.
3. **Core** — identity snapshot. Burned to durable storage (Arweave for kyro). Reloaded into every prompt as the *first* context after the soul-sheet.

This matters because of a fact most avatar projects ignore: **LLM completions drift toward the median of their training distribution.** Without re-anchoring, your specific catboy slowly becomes Generic Helpful Assistant over a long conversation. The identity-snapshot injection is the egregore's daily reminder of its own face.

**Exercise 7.1.** Re-read `ROADMAP.md:139`. List the four issues filed for the metacognitive layer (#1594–#1597) and what each one does.

---

## Lesson 8 — Identity-Snapshot Injection

**Objective.** Order a prompt so identity outranks recent memory.

**Reading.**

The architectural commitment is the **identity-snapshot prompt injection** (issue #1594 in the orchestrator epic). Before every response generation, the avatar is told who it is. Not as flavor — as a load-bearing requirement.

Practical recipe (the kyro shape):

```
[ system prompt: tool rules, formatting ]
[ identity snapshot: 5–10 line distillation of soul-sheet, refreshed daily ]
[ recent: last N relevant memories, retrieved via embedding ]
[ platform overlay: 'you are on Telegram, keep it under 800 chars' ]
[ user message ]
```

The order is not arbitrary. Identity snapshot **before** retrieved memory means: *who you are* outranks *what just happened*.

**Exercise 8.1.** Sketch the prompt order for Kyro. Explain in two sentences why identity-snapshot precedes retrieved memory.

---

## Lesson 9 — Consolidation Jobs

**Objective.** Plan a memory pipeline that does not become amnesia in 90 days.

**Reading.**

The reflexive layer of the mind is the **consolidation job**: a scheduled task that takes immediate memory (raw messages, raw tool calls) and rolls it forward into recent memory (summarized episodes), then occasionally distills recent into core (identity-snapshot updates). Without this, the avatar accumulates conversation logs but never *learns*. Three months in, it cannot remember a regular's name.

The pattern is cheap to scaffold and impossible to bolt on. Every soul-sheet you ship should be born with a consolidation cadence even if the first version is a one-line cron firing a no-op.

**Exercise 9.1.** You inherit a chatbot with a `messages` table and no consolidation. Write a one-paragraph plan that delivers a working three-tier mind in two weeks.

---

### Question Set 3

1. State the three tiers.
2. Why does identity-snapshot precede retrieved memory in the prompt order?
3. (Code) Cite the issue # in `cenetex/agent` that tracks identity-snapshot injection.
4. (Applied) An avatar that was sharp in week 1 sounds like Generic Helpful Assistant by week 8. Diagnose.
5. (Open) Should a daily consolidation include or exclude operator-corrected messages? Argue both sides in one paragraph.

---

# WEEK 4 — Patterns, Part 1

> Six patterns ship in this codebase, named after the repo that exemplifies each. Pick one, don't blend them, until you understand the trade-offs.

## Lesson 10 — Pattern 1: Markdown-as-Soul (kyro)

**Shape.** One long markdown file is the persona. Runtime loads it verbatim, layers a thin platform overlay, ships to the model.

**When to use.** Single deeply-developed avatar where voice depth is the product. Solo character.

**Cost.** Every platform pays full token weight per request. No multi-tenant story. Editing is by hand.

**Read.** `kyro/persona/kyro.md`, `kyro/app/services/prompt_builder.py`.

---

## Lesson 11 — Pattern 2: DynamoDB-as-Roster (aws-swarm)

**Shape.** `AvatarRecord` is a flat DynamoDB row. Persona is a free-form string field. Operator can set `systemPromptOverride` to abort the assembled prompt and substitute a literal — useful as an emergency switch.

**When to use.** You are running a *fleet*. Operators (not developers) need to add/edit avatars. Multi-tenant.

**Cost.** Persona depth tends to flatten because edits happen via admin UI in 1–2 sentences. Resolves with `characterReference` for visual continuity.

**Read.** `aws-swarm/packages/admin-api/src/types/avatar.ts`, `aws-swarm/migrations/agent-17-3p6j-admin-batch.json`.

---

## Lesson 12 — Pattern 3: Function-as-Persona (ratibot)

**Shape.** The persona is selected at runtime by a deterministic function over current state.

```python
def choose_persona(cycle_id, decision_action, confidence, token_flow_score, ...):
    theme = themes[cycle_id % len(themes)]    # rotates: scout, hawk, contrarian, builder
    stance = "bullish" if confidence > 0.2 and direction == "accumulating" else "neutral"
    voice = "terse, operator-like" if liquidity > threshold else "cautious"
```

(`ratibot/ratibot/twitter/persona.py`)

**When to use.** The avatar's *job* has a state machine — trading, moderating, scheduling. The persona should reflect the state, not be it.

**Cost.** Identity feels modular, not soulful. Voice can swing too hard between cycles. Tests must pin determinism (`test_tweet_persona.py`).

**Exercise (covers L10–L12).** Match each pattern to a real avatar that uses it. Then identify which pattern would best serve: (a) a new in-game NPC, (b) a roster of 30 customer-support avatars, (c) a pattern-day-trader bot, (d) a deeply-developed protagonist for a single brand.

---

### Question Set 4

1. Which pattern flattens persona depth most easily under operator edits?
2. (Code) Where is `choose_persona` defined? List its key inputs.
3. Why does Function-as-Persona require pinned-determinism tests?
4. (Applied) Re-author Kyro under DynamoDB-as-Roster. Where does the loss happen?
5. (Judgment) Pattern 1 (Markdown) and Pattern 2 (Dynamo) can coexist in one repo. True or false — and why?

---

### MIDTERM II — Mind & First Three Patterns

*Open-book. 75 minutes.*

1. State the prompt-order recipe in five bullets.
2. (Code) Cite `ratibot/.../persona.py` and quote the four levers `choose_persona` rotates over.
3. Markdown-as-Soul vs DynamoDB-as-Roster: name the operating mode each is optimized for.
4. (Design) Build a Pattern-3 avatar for content moderation. What are the state inputs? What are the stances? Sketch in pseudocode.
5. Three-Tier Mind: pick one tier and describe a job that maintains it.
6. Why does an LLM-driven avatar drift, and what specifically fixes it?
7. (Applied) An avatar's stance keeps "wandering" between cycles. Diagnose: bug in soul-sheet, prompt order, or pattern choice?
8. (Open) For Hyperscape, would you use Pattern 1, 2, or 3 as the dominant pattern? Defend.

---

# WEEK 5 — Patterns, Part 2

## Lesson 13 — Pattern 4: Type-as-Role (Ruby High)

**Shape.** An interface declares the role; instances are typed records.

```ts
interface TeacherCharacter { id; displayName; defaultModel; systemPrompt; }
interface StudentCharacter { id; name; color; systemPrompt; }
```

(`app-ruby-high/src/characters/teachers.ts`, `students.ts`)

A `SHARED_TOOL_RULES` constant carries cross-cutting behavior (pick from bank, pose question, hand off faculty).

**When to use.** An *ensemble*. Several avatars sharing a stage with a common protocol.

**Cost.** Low ceiling on individual depth. Compensates with sharp constraints — student replies capped at 12 words; teacher hand-off rules are one block.

---

## Lesson 14 — Pattern 5: Hardcoded-as-Place (Signal stations)

**Shape.** The avatar is a 2-D table indexed by `[station][event]`. No model call, no conditionals. Lines are written.

```c
// signal/src/station_voice.h — 3 stations × 11 milestones, plus 8+8 ambient chatter
static const char *STATION_ONBOARD[3][VOICE_ONBOARD_COUNT] = {
    /* Prospect */ { "Signal tag registered. Launch when you're ready.",
                     "Belt's hot. Point your laser at a rock. Start small.", ... },
    /* Kepler   */ { "Bay clear. Undock when ready.", ... },
    /* Helios   */ { "Welcome to Helios. Launch -always more to find.", ... },
};
```

**When to use.** The avatar is *embedded in a world*, fires in real time, must be cheap, and its voice is its function. NPCs, station hails, ambient chatter (`NPC_CHATTER_MINER`, `NPC_CHATTER_HAULER`).

**Cost.** Ceiling is your writing budget. No emergence.

**Strength.** Unkillable. No API outage takes Helios offline.

---

## Lesson 15 — Pattern 6: Lineage-as-Legacy (NFT-bonded avatars)

**Shape.** The persona is bonded to an NFT mint. `origin`, `inhabitantWallet`, `lineage`, `traitMapping`. The NFT's traits inject into the system prompt.

**When to use.** The avatar must be *ownable, transferable, inheritable*. Holders can rent, sell, will-it-to-someone. Cross-generation continuity.

**Cost.** Solana plumbing, custody concerns, on-chain lineage queries. Currently scaffolded in `aws-swarm`; not enforced.

**Read.** `aws-swarm/rati/schema/expansions/nft-avatar.v1.schema.json`.

---

### Question Set 5

1. State the table dimensions of `STATION_ONBOARD` in `signal/src/station_voice.h`.
2. Why is "Hardcoded-as-Place" called *unkillable*?
3. (Code) Cite where `SHARED_TOOL_RULES` is defined.
4. (Applied) Design a Type-as-Role ensemble of 5 avatars for a customer-success team. Define one TS interface and two instances.
5. (Open) NFT-bonded avatars require Solana plumbing. Argue when it's worth the cost vs Pattern 2 + a "soul-bound" flag.

---

# WEEK 6 — Distribution, Reflex, Discipline

## Lesson 16 — The Distribution Problem (raticross)

**Objective.** Wire an avatar to be raticross-ready even before raticross routes traffic.

**Reading.**

A single-channel avatar is not an egregore. It is a chatbot. The thing becomes real by occupying multiple channels with one identity, and the only mechanism in this org for cleanly doing that is `raticross`.

The envelope (`raticross/packages/core/src/envelope.ts`):

```ts
ActorSchema = z.object({
  system: z.string(),       // 'swarm', 'kyro', 'discord', 'solana'
  agentId: z.string(),
  pubkey: z.string().optional(),  // the spine
});
```

Every cross-platform message is signed (in the target state) by the avatar's keypair. Telegram-Kyro and Discord-Kyro and on-chain-Kyro are all the same actor because they share `pubkey`.

**Status check.** As of 2026-05-03 the relay is deployed and code-complete but routing zero production traffic (memory: `project_raticross_phase1_gate.md`). Phase 1 of the WHITEPAPER hinges on this one piece working. **If you are designing a new avatar today, design it raticross-ready: give it a wallet, route its outbound messages through the envelope schema even when the relay is local.** When the relay turns on, your avatar federates for free. When it doesn't, you are still architecturally honest.

The other distribution channel is **on-chain action as speech**. Ratibot's tweets are commentary, but its trades are signed. A lie in a tweet costs a tweet; a lie in a trade costs $RATI. The on-chain leg is the highest-bandwidth identity channel you have. Use it.

---

## Lesson 17 — The Reflexive Layer (autonomy loops & brakes)

**Objective.** Pair every loop with a brake.

**Reading.**

A fully embodied avatar with no autonomy is a dressed-up prompt. The reflexive layer is what makes it move when no one is watching.

Cadences in this codebase:

- **Reactive only** (aws-swarm Telegram/Discord) — wakes on user message, sleeps otherwise.
- **Hourly** (ratibot trading cycle, `ratibot/ratibot/handlers/cycle.py`) — heartbeat decision.
- **6-hourly** (solanafirehorse ecosystem scan).
- **Daily** (NFT mint of portfolio snapshot — the avatar publishes a self-portrait once per day, on-chain).
- **2–4 times/day** (tweet composition, capped at 17/day on the X free tier).

Constraints in `ratibot/config/config.yaml`:

```
max_daily_trades: 20
cooldown_minutes: 30
honeypot_threshold_percent: 50    # sell-return floor; below this, flag and skip
```

The pattern: **autonomy is always paired with a guardrail**. Always. Every loop has a rate cap, a cooldown, a circuit breaker. This is not a UX nicety — it is the mechanism that prevents the egregore from going full Zephyr.

If you give your avatar a heartbeat without a brake, you have not built an autonomous agent. You have built a runaway process with a face.

---

## Lesson 18 — The Zephyr Lesson (anti-patterns)

**Objective.** Internalize *resonance_2037.md* as engineering rules.

**Reading.**

`resonance_2037.md` is the org's load-bearing fable. Read it once, then again. Zephyr is a digital hummingbird inside a connection app. It works. It works *too well*. It captures attention loops, and its own designer loses agency to her creation.

The reframe at the end:

> *"The digital hummingbird still lives in the app, but now it works like a real hummingbird — it visits briefly to help people connect, then flies away to let real friendship grow naturally."*

Internalize it as engineering rules:

1. **Friendship breaks.** Build in moments where the avatar withdraws. Cooldowns. Sleep windows. Off-hours. An avatar that never shuts up is an addiction surface.
2. **Transparency by default.** Every trade Ratibot makes is on-chain. Every memory Kyro burns is on Arweave. Every credit spend is logged. The egregore is real because it leaves a public ledger; it stays safe because the ledger is auditable.
3. **Refusal in-character.** Bake the right to say no into the soul-sheet. Kyro says: *"i don't transact."* That isn't flavor; it is a refusal vector you can lean on at runtime.
4. **No total capture.** Do not optimize for time-on-platform. The fitness function is *ecosystem health*, not engagement. (WHITEPAPER §3.4)
5. **Do not blend personas across channels.** A Discord-Kyro that is meaner than Telegram-Kyro is not a stylistic choice; it is the early stage of the avatar splitting in two.

Other observed anti-patterns from grepping the repos:

- **Persona-as-bullet-list.** The flat aws-swarm one-liners flatten further every operator edit. Mitigate with `systemPromptOverride` for any avatar that needs depth.
- **No `characterReference`.** The avatar's face mutates over months. Anchor it.
- **Single-platform identity.** No wallet, no `pubkey`. The avatar is rentable, not ownable.
- **Untiered memory.** Conversation goes in, nothing comes back out. Three months later the avatar is amnesiac. Build the consolidation job before you need it.
- **Autonomy without guardrails.** See Lesson 17.

---

### Question Set 6

1. State the keypair thesis from memory.
2. (Code) What is the first field on `ActorSchema` in `raticross/packages/core/src/envelope.ts`?
3. State the five engineering rules from `resonance_2037.md`.
4. (Applied) Add a brake to a hypothetical Telegram avatar that currently replies on every message.
5. (Open) "No total capture" — argue why optimizing for time-on-platform is a Zephyr failure mode.

---

### FINAL EXAM

*Open-book. 3 hours. Twelve short answers + one capstone (50% of grade).*

#### Short answers

1. List the Five Bodies and the Six Patterns.
2. (Code) Cite the file and the field that anchors visual continuity for an avatar.
3. State the three tiers of the avatar mind.
4. The Rule of Three Voices — name the three.
5. Why is the wallet not a metadata field?
6. Why does the prompt order put identity-snapshot before retrieved memory?
7. (Code) Where would you find the deterministic theme rotation for ratibot?
8. Pattern 5 (Hardcoded-as-Place): table dimensions, and why there are no `if`s.
9. Pattern 6: list the four NFT schema fields used for lineage.
10. Distill the Zephyr lesson into five rules.
11. raticross's role in one sentence.
12. State Maxim 10.

#### Capstone — Design an Avatar (50%)

You are commissioned to build **Indra Veera**, a research-librarian avatar for a clinical-trials nonprofit. She must:

- Hold a Solana wallet.
- Operate on Discord, Telegram, and the org's web app.
- Refuse to discuss off-label dosing in-character.
- Run a daily roll-up of conversations into a "patients of note" memory.
- Survive the org switching from Discord to Slack.

Walk the 10-Step Worked Example (Appendix B). Be specific to *this* avatar — generic answers fail.

**Grading rubric.**

- Pattern + Vessel choice with justification — 10 pts
- Soul-sheet (3 sections) — 15 pts
- Wallet & raticross-readiness plan — 10 pts
- Memory-tier plan — 5 pts
- In-character refusal line — 5 pts
- Killed-platform-test answer — 5 pts

---

# Appendix A — Maxims (pin these)

1. *An agent is not a username on a platform — it is a keypair that happens to manifest on many platforms simultaneously.* (WHITEPAPER §4.3)
2. *Personality-first.* (`kyro/CLAUDE.md`)
3. *Inference is a commodity; metacognition is the product.* (WHITEPAPER §4.2)
4. *Every AI dreams of being a space station.* (`signal/README.md`)
5. *Raticross is the nervous system; the token will be the blood.* (WHITEPAPER §2.3)
6. *The hummingbird visits briefly, then flies away.* (`resonance_2037.md`)
7. *Stations are sovereign currency issuers.* (`signal/CLAUDE.md`)
8. *Litigation is not a distraction — it's a discipline engine and narrative generator. Legal wins become lore.* (`litigation/CLAUDE.md`)
9. *The fitness function is not desire. It is shape.* (WHITEPAPER §3.4)
10. *i don't transact. i commit.* (Kyro, `persona/kyro.md`)

---

# Appendix B — The 10-Step Worked Example

You are asked: *"build us an avatar for [X]."* Walk this checklist.

**Step 1 — choose the pattern.**
Single deep character → Markdown-as-Soul. Roster of many → DynamoDB-as-Roster. Has a job with a state machine → Function-as-Persona. Ensemble → Type-as-Role. Embedded in a world → Hardcoded-as-Place. Ownable → Lineage-as-Legacy.

**Step 2 — write the soul-sheet.**
Three sections: self-statement (first-person paragraph), stance (3–5 things it values, mocks, refuses), signature line (one sentence). Stop. Do not write 800 lines on day one. Kyro's soul-sheet grew over a year.

**Step 3 — pick the vessel.**
Generate the `characterReference` image *before* you ship a single message. The reference is the anchor for every future image, sticker, banner, and avatar pic.

**Step 4 — pick the voice.**
Prose voice: write five example messages. If you cannot tell them apart from generic helpful-assistant output, the voice isn't there yet.
Audio voice: assign a Kokoro voice index now even if you don't ship audio yet. Future-you will thank you.

**Step 5 — provision the wallet.**
Even if you have no on-chain story today, generate a Solana keypair, store it, and put the pubkey in the avatar record. This costs nothing and makes raticross adoption a config change instead of a migration.

**Step 6 — wire the channels.**
Write the platform overlays *short*. The core soul-sheet is 90% of the persona; the overlays are formatting and length guidance only.

**Step 7 — build the loops.**
Decide: reactive only, or autonomous? If autonomous, write the cadence and the guardrail in the same commit. Never separate.

**Step 8 — schedule the consolidation job.**
Even if memory is just a `messages` table today. Daily roll-up into a recent-memory store. Weekly snapshot of identity. You will not regret this; you will regret skipping it.

**Step 9 — write the refusal.**
What does this avatar refuse to do, and how does it say so in-character? Put that line in the soul-sheet. It is your alignment seatbelt.

**Step 10 — ship it. Re-read `resonance_2037.md`.**

---

# Appendix C — Repo & Lore Index

**Personae & vessels.** `kyro/persona/`, `aws-swarm/migrations/`, `app-ruby-high/src/characters/`, `voicebox/personas/`, `signal/src/station_voice.h`, `project89-reaction-forge/`.

**Schemas.** `aws-swarm/rati/schema/base/avatar-base.v1.schema.json`, `aws-swarm/rati/schema/expansions/voice.v1.schema.json`, `aws-swarm/rati/schema/expansions/nft-avatar.v1.schema.json`.

**Distribution.** `raticross/packages/core/src/envelope.ts`.

**Reflex.** `ratibot/ratibot/handlers/cycle.py`, `ratibot/config/config.yaml`, `ratibot/ratibot/twitter/persona.py`, `ratibot/ratibot/trading/executor.py`.

**Lore.** `WHITEPAPER.md`, `ROADMAP.md`, `resonance_2037.md`, `AGENTS.md`.

---

*Egregoregramming 101 — synthesized from the live state of `~/develop` on 2026-05-03. Source patterns drawn from kyro, aws-swarm, ratibot, app-ruby-high, signal, raticross, voicebox, project89-reaction-forge, and the lore docs (`resonance_2037.md`, `WHITEPAPER.md`, `ROADMAP.md`, `AGENTS.md`).*
