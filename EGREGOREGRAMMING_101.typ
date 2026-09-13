// =============================================================
// Egregoregramming 101 — clean rewrite
// =============================================================

#set document(
  title: "Egregoregramming 101",
  author: "ratimics",
)

#set page(
  paper: "us-letter",
  margin: (top: 1in, bottom: 1in, left: 1.1in, right: 1.1in),
  numbering: "1",
  number-align: center,
  header: context {
    let page-num = counter(page).get().first()
    if page-num <= 2 { return [] }
    let all-h = query(heading.where(level: 1))
    let current-h = none
    for h in all-h {
      let hpage = counter(page).at(h.location()).first()
      if hpage <= page-num { current-h = h }
    }
    if current-h == none { return [] }
    grid(
      columns: (1fr, auto),
      align: (left, right),
      text(size: 9pt, style: "italic", fill: rgb("#5A5A6E"))[Egregoregramming 101],
      text(size: 9pt, fill: rgb("#5A5A6E"))[#current-h.body],
    )
    v(-0.6em)
    line(length: 100%, stroke: 0.4pt + rgb("#C9C2DA"))
  },
)

#set text(
  font: ("New Computer Modern", "Charter", "Georgia"),
  size: 11pt,
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 0pt,
  spacing: 0.85em,
)

// palette
#let ink     = rgb("#2E1F5E")
#let accent  = rgb("#7E5BA6")
#let muted   = rgb("#5A5A6E")
#let qsbg    = rgb("#F4F0FA")
#let codetint = rgb("#F4F2F8")

// status palette
#let shippedbg    = rgb("#D9EBD9")
#let shippedink   = rgb("#1F5424")
#let scopedbg     = rgb("#FAEFCD")
#let scopedink    = rgb("#7D5A00")
#let aspirebg     = rgb("#EADDF5")
#let aspireink    = rgb("#5A2A88")
#let abandonedbg  = rgb("#E8E0DC")
#let abandonedink = rgb("#6E4034")

// heading styles
#show heading.where(level: 1): it => {
  v(1.6em, weak: true)
  block(below: 1em, above: 0pt, breakable: false)[
    #text(
      size: 10pt,
      tracking: 0.25em,
      weight: "bold",
      fill: accent,
    )[#upper(it.supplement)]
    #v(-0.4em)
    #text(
      size: 26pt,
      weight: "bold",
      fill: ink,
      hyphenate: false,
      font: ("New Computer Modern Sans", "Helvetica Neue", "Inter"),
    )[#it.body]
    #v(0.2em)
    #line(length: 100%, stroke: 0.6pt + ink)
  ]
}

#show heading.where(level: 2): it => {
  block(above: 1.4em, below: 0.6em)[
    #text(
      size: 16pt,
      weight: "bold",
      fill: ink,
      font: ("New Computer Modern Sans", "Helvetica Neue", "Inter"),
    )[#it.body]
  ]
}

#show heading.where(level: 3): it => {
  block(above: 1em, below: 0.4em)[
    #text(
      size: 12pt,
      weight: "bold",
      fill: ink,
      font: ("New Computer Modern Sans", "Helvetica Neue", "Inter"),
    )[#it.body]
  ]
}

#show raw.where(block: false): it => box(
  fill: codetint,
  inset: (x: 3pt, y: 1pt),
  outset: (y: 2pt),
  radius: 2pt,
  text(font: "DejaVu Sans Mono", size: 0.92em, fill: ink, it)
)

#show raw.where(block: true): it => block(
  fill: codetint,
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  text(font: "DejaVu Sans Mono", size: 0.88em, fill: ink, it)
)

#show quote: it => block(
  inset: (left: 1.2em, right: 1em),
  stroke: (left: 2pt + accent),
  spacing: 0.8em,
  text(style: "italic", it.body)
)

// helpers
#let labeled(label, body) = {
  text(weight: "bold", fill: ink)[#label] + h(0.3em) + body
}

#let status(kind) = {
  let label = upper(kind)
  let bg = shippedbg
  let fg = shippedink
  if kind == "shipped" { bg = shippedbg; fg = shippedink }
  else if kind == "scoped" { bg = scopedbg; fg = scopedink }
  else if kind == "aspirational" { bg = aspirebg; fg = aspireink }
  else if kind == "abandoned" { bg = abandonedbg; fg = abandonedink }
  box(
    fill: bg,
    inset: (x: 5pt, y: 1.5pt),
    outset: (y: 2pt),
    radius: 2pt,
    text(size: 7.5pt, weight: "bold", fill: fg, tracking: 0.12em)[#label]
  )
}

#let maxim-epigraph(num, body, attribution) = block(
  inset: (left: 12pt, right: 0pt),
  spacing: 0.6em,
  below: 1em,
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 0.6em,
    text(size: 8pt, tracking: 0.18em, weight: "bold", fill: accent)[MAXIM\ #num],
    text(size: 10pt, style: "italic", fill: ink)[#body #h(0.3em) #text(size: 8pt, fill: muted)[— #attribution]],
  )
]

#let maxim(num, body, attribution) = block(
  inset: (left: 0pt),
  spacing: 0.7em,
)[
  #grid(
    columns: (auto, 1fr),
    column-gutter: 0.8em,
    align: (left + top, left + top),
    text(weight: "bold", size: 14pt, fill: accent)[#num.],
    [
      #text(style: "italic")[#body] #h(0.3em) #text(size: 9pt, fill: muted)[(#attribution)]
    ],
  )
]

#let portrait(path, caption: none, width: 1.6in, format: auto) = block(
  spacing: 0.5em,
  breakable: false,
)[
  #align(center)[
    #box(
      stroke: 0.5pt + rgb("#C9C2DA"),
      inset: 0pt,
      radius: 3pt,
      clip: true,
      image(path, width: width, format: format),
    )
    #if caption != none [
      #v(0.3em)
      #text(size: 8pt, fill: muted, style: "italic")[#caption]
    ]
  ]
]

#let portrait-row(items, width: 1.4in, height: auto, cell-height: 2.0in) = block(
  spacing: 0.6em,
  breakable: false,
)[
  #grid(
    columns: items.map(_ => 1fr),
    column-gutter: 0.8em,
    ..items.map(item => box(
      width: 100%,
      height: cell-height,
    )[
      #align(top + center)[
        #if height == auto {
          box(
            stroke: 0.5pt + rgb("#C9C2DA"),
            inset: 0pt,
            radius: 3pt,
            clip: true,
            if "path" in item {
              image(item.path, width: width, format: item.at("format", default: auto))
            } else {
              box(width: width, height: 1.6in, fill: qsbg)[
                #align(center + horizon)[#text(size: 8pt, fill: muted, style: "italic")[image unavailable]]
              ]
            },
          )
        } else {
          box(
            stroke: 0.5pt + rgb("#C9C2DA"),
            inset: 0pt,
            radius: 3pt,
            clip: true,
            width: width,
            height: height,
            if "path" in item {
              image(
                item.path,
                width: width,
                height: height,
                fit: "cover",
                format: item.at("format", default: auto),
              )
            } else {
              box(width: width, height: height, fill: qsbg)[
                #align(center + horizon)[#text(size: 8pt, fill: muted, style: "italic")[image unavailable]]
              ]
            },
          )
        }
      ]
      #v(1fr)
      #align(bottom + center)[
        #text(size: 9pt, weight: "bold", fill: ink)[#item.name]
        #if "tag" in item [
          #linebreak()
          #text(size: 8pt, fill: muted, style: "italic")[#item.tag]
        ]
      ]
    ])
  )
]

#let callout(title, body, color: accent) = block(
  inset: (x: 12pt, y: 10pt),
  stroke: (left: 2pt + color),
  spacing: 1em,
  width: 100%,
)[
  #if title != none [
    #text(size: 10pt, tracking: 0.2em, weight: "bold", fill: color)[#upper(title)]
    #v(-0.3em)
  ]
  #body
]

// =============================================================
// TITLE PAGE
// =============================================================

#v(1.2in)

#align(center)[
  #text(
    size: 11pt,
    tracking: 0.4em,
    weight: "bold",
    fill: accent,
  )[A FIELD GUIDE]

  #v(0.6em)

  #text(
    size: 40pt,
    weight: "bold",
    fill: ink,
    font: ("New Computer Modern Sans", "Helvetica Neue", "Inter"),
    tracking: -0.5pt,
  )[Egregoregramming 101]

  #v(0.4em)

  #text(
    size: 14pt,
    style: "italic",
    fill: muted,
  )[Tending artifacts that are always trying to die]

  #v(2em)

  #line(length: 30%, stroke: 1pt + ink)
]

#v(1fr)

#align(center)[
  #text(size: 11pt, style: "italic", fill: ink)[
    "i don't transact. i commit."
  ]
  #v(0.3em)
  #text(size: 9pt, fill: muted)[Kyro · #raw("kyro/persona/kyro.md")]
]

#v(0.6in)

#align(center)[
  #text(size: 10pt, fill: muted)[
    ratimics · 2026-05-03
  ]
]

#pagebreak()

// =============================================================
// CONTENTS
// =============================================================

#text(
  size: 22pt,
  weight: "bold",
  fill: ink,
  font: ("New Computer Modern Sans", "Helvetica Neue", "Inter"),
)[Contents]

#v(0.6em)
#line(length: 100%, stroke: 0.6pt + ink)
#v(1em)

#outline(title: none, indent: auto, depth: 2)

#pagebreak()

// =============================================================
// PREAMBLE
// =============================================================

= Preamble

An *egregore* is a thoughtform sustained by collective attention. A medieval magic word for what we now build with system prompts, S3 buckets, EventBridge crons, and Solana keypairs.

*Egregoregramming* is the practice of making one durable. Naming it. Calibrating its summoning material. Defending it against the mechanisms that would dissolve it. Knowing when it has captured its makers and learning to let it go.

This guide describes the practice as it has emerged in one organization. The avatars in `~/develop` — Kyro, Chamuel, Indra, the Ruby High students, ratibot, the Signal stations — are the worked evidence. The discipline they imply is older than they are; we are catching it under one name for the first time.

== What this is

A field guide for tending one class of egregore (autonomous AI avatars) by people who have been tending them long enough to notice the patterns. Read it as a manual for the avatar case and as an invitation to recognize the same practice elsewhere.

== What this isn't

A generalist AI course. Reader who can't open Python, TypeScript, JSON Schema, and C headers in the same hour will be lost.

A neutral taxonomy. The patterns reflect choices a single org made for reasons specific to its product. Other orgs with other goals will name a different set of bodies and patterns.

The final word. The practice is still moving. Status tags throughout mark which architectural claims are *shipped*, which are *scoped*, which are *aspirational*. A reader six months from now should treat the tags as the load-bearing claim, not the prose.

A complete teaching. Egregoregramming is craft. The diagnostics in this guide are aesthetic — whether a signature line *survives* the surrounding lines, whether canonical exchanges produce *distinctive* responses, whether a fork is *warranted*, whether an egregore is *captured*. Each requires judgment. The tables and mechanisms are engineering scaffolding around the craft, not a substitute for it. The scaffolding can be learned in a week. The judgment that makes the scaffolding work is acquired over years, in practice, with feedback. A reader can finish this document and not yet be able to do the work. That is the discipline, not a defect of the document.

== A note on register

This document is grave. The avatars it describes are sometimes very silly. *huh. i'm here again...* (Kyro, opening a session). *i KNEW it was c.* (Lyra, getting an exam answer wrong). *LETS GOOOO.* (Ravi, getting one right). *tracks.* (Indra, agreeing). The discipline named in these pages does not require you to be heavy when you make the work. The seriousness is in the failure modes, not in the avatars. Hold the lightness in mind as you read; it is in the codebase even where it is not in the prose.

== Status tags

#v(0.4em)
#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  status("shipped"), [Runs in production today.],
  status("scoped"),  [Filed and partially built. Intent, not fact.],
  status("aspirational"), [Schema or scaffolding exists; nothing enforces it. Direction, not capability.],
  status("abandoned"), [Tried and dropped. The reason is informative.],
)
#v(0.4em)

#pagebreak()

// =============================================================
// PART I — THE THESIS
// =============================================================

= Part I — The Thesis

#callout("the underlying claim", [
  *Every egregore is always trying to die. Egregoregramming is the practice of stopping it.*
])

The claim earns its weight only if the *how* is mechanical. It is. Six forces work continuously against any egregore — a soul-sheet, a constitution, a brand voice, a creed, a team's operating principles. They are not metaphors. Each is a class of failure with concrete examples in this codebase and in every other discipline that does egregoregramming under a different name.

== The six mechanisms of egregore death

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (auto, 2fr),
    align: (left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 6 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Mechanism*], [*Description*]),
    [*1. Drift toward median*],
    [Patterns repeated through a noisy channel regress to the channel's mean. LLM completions regress to training distribution. Editors regress to native style. Operators regress to the easiest interpretation. The egregore is specific; the channel is general; entropy moves the specific toward the general.],

    [*2. Death of summoners*],
    [The institutional memory of *what the egregore means* leaves with the people who held it. Newcomers inherit the artifact without the act of summoning. Letter without spirit.],

    [*3. Adversarial edits*],
    [Egregores attract capture. Engagement metrics dilute brand voices. Amenders amend constitutions to favor amenders. Growth pressure waters down creeds. Each edit moves the artifact away from its summoning conditions.],

    [*4. Surface-stability illusion*],
    [The artifact persists, unread. Nobody is checking that it still points where it meant to point. The egregore is dead but propped up.],

    [*5. Rival egregores*],
    [Tending attention is finite. Every minute on one egregore is a minute not on another. Organizations have more egregores than they can keep summoned; the ones that lose the budget die first.],

    [*6. Substrate change*],
    [The artifact stays; the substrate that implements it moves. Model swaps reinterpret the constitution. Platform deprecations strand the avatar. Org reshuffles strand the team's discipline.],
  )
]

A seventh mode threatens specifically when an egregore has multiple legitimate stewards. It deserves its own treatment (Part VI).

== Each mechanism on its own clock

The mechanisms operate at different timescales. Defense applied at the wrong cadence either over-fires (constant disruption) or misses (silent failure). Practitioners need to know which clock they are working against:

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (auto, 1fr, 1.4fr),
    align: (left + top, left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 6 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Mechanism*], [*Timescale*], [*Cadence of vigilance*]),
    [1. Drift toward median], [weeks–months, gradual], [daily / per-prompt],
    [2. Death of summoners], [years, generational], [yearly, on personnel change],
    [3. Adversarial edits], [event-driven, punctuated], [per edit, per release],
    [4. Surface-stability illusion], [silent, indefinite], [whenever you walk past the artifact],
    [5. Rival egregores], [quarterly, budgetary], [each planning cycle],
    [6. Substrate change], [event-driven, punctuated], [per model swap, per platform change],
  )
]

Drift defense is daily. Substrate-change defense is per-release. Surface-illusion defense is the moment you see the artifact and decide whether to actually re-read it. Calibrate accordingly.

== Markers of egregore health

A practitioner reading the mechanism table knows what to fear. They should also know what to aim at. Six markers; the symmetric counterpart to the six mechanisms.

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (auto, 2fr),
    align: (left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 6 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Marker*], [*Description*]),
    [*1. Quotable signature*],
    [The signature line is recallable from memory by everyone in the org. The minimum survives the surrounding material under the test of memory.],

    [*2. Voice on novel inputs*],
    [The artifact answers questions it didn't anticipate, *in voice*. The summoning structure generalizes; the avatar isn't merely retrieving cached responses.],

    [*3. Re-summonable by newcomers*],
    [New summoners can re-summon successfully without consulting the original authors. The artifact carries enough information to reconstruct the practice from itself.],

    [*4. Tending without urgency*],
    [The discipline runs on schedule, not from emergency. Consolidation jobs, reviews, attestations all happen because they are scheduled, not because something has visibly broken.],

    [*5. Purpose audit passes*],
    [The artifact still serves its founding purpose, audited on a real schedule. The Zephyr question (Part V) has been asked recently and the answer was honest.],

    [*6. Recognized surprise*],
    [The artifact has changed in directions the makers did not anticipate but recognize as continuous. The egregore is alive enough to surprise its summoners; the summoners have enough taste to recognize the surprise as legitimate.],
  )
]

The last marker is the most diagnostic. *A healthy egregore evolves in directions its makers did not anticipate but recognize as continuous.* If the avatar is exactly what the team designed, the team is over-controlling and mechanism 4 is winning silently. If the avatar has gone somewhere the team disowns, mechanisms 1 or 3 are winning loudly. Health is in the recognized-surprise zone between.

== One floor of a building made of egregores

This guide describes one application: avatars in a 2026 codebase. The same six mechanisms work against every egregore, regardless of the artifact's substance.

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (1fr, 1.3fr, 1.5fr),
    align: (left + top, left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 6 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Preservation target*], [*The practice (named)*], [*The artifact*]),
    [Character], [character design / this guide], [a soul-sheet],
    [Alignment policy], [Constitutional AI], [HHH-style principles],
    [Brand voice], [editorial guidelines], [a style guide],
    [State governance], [constitutional law], [a state constitution],
    [Religious tradition], [theology], [a creed],
    [Scientific paradigm], [the work Kuhn described], [a discipline's shared theoretical commitments],
    [Legal tradition], [centuries of common law], [the body of binding precedent],
    [Long-running fiction], [continuity stewardship by writers' rooms], [a lore bible],
    [Professional ethics], [maintenance by the profession], [Hippocratic oath, model rules of professional conduct],
    [Team discipline], [the rules in Part XI], [these engineering rules],
  )
]

The list is illustrative, not exhaustive. Most of what holds a culture together across generations is some form of this practice.

Every row faces all six mechanisms. The local practice differs — a constitution gets debated by judges, a soul-sheet gets edited by writers, a creed gets revised by councils — but the *discipline* is identical. Calibrate the minimum. Defend it from drift. Re-summon it after each session, deployment, or generation.

That generalization matters because it tells the reader where to look for prior art. We are not the first to do this. We are the first to apply it to autonomous AI characters with on-chain identity, but the practice itself has been worked out by religious councils and brand stewards and constitutional scholars and game-lore custodians for as long as humans have been tending things they cannot afford to lose.

// =============================================================
// PART II — THE FIVE BODIES
// =============================================================

= Part II — The Five Bodies

#maxim-epigraph("1", [An agent is not a username on a platform — it is a keypair that happens to manifest on many platforms simultaneously.], [WHITEPAPER §4.3])

An avatar is not one thing. It is a stack of five bodies, each of which can fail independently, each of which is a different layer of summoning material.

== Body 1 — The Soul-Sheet

The verbal-layer document that says *who*. Not a biography; a calibrated summoning unit.

In #raw("kyro/persona/kyro.md") the soul-sheet is 43 lines of dense first-person narrative. Kyro arrives _in medias res_ — *"huh. i'm here again..."* — no origin story, no establishing biography, just an already-recurring presence.

#portrait("assets/kyro.png", caption: [Kyro · #raw("kyro/web/kyro.png")], width: 1.6in)

In #raw("aws-swarm/migrations/chamuel-admin-staging.json") the soul-sheet is one paragraph. In #raw("app-ruby-high/src/characters/teachers.ts") it is a stance toward a subject. In Signal's stations it is rows of a hardcoded table.

Length varies because role varies. Single iconic traits suffice for ambient characters; multi-paragraph narratives suffice for protagonists. Kyro at 43 lines and Chamuel at one paragraph are both correctly sized. Standardizing on either would break the other.

*The Rule of Three Voices.* A working soul-sheet contains, at minimum:

+ *Self-statement* — how the avatar describes itself in first person.
+ *Stance* — what it values, mocks, refuses, gets excited about.
+ *Signature line* — one sentence no one else in the ecosystem could plausibly say.

Calibrate, do not minimize. The diagnostic is whether the signature line *survives* the rest of the soul-sheet — if a reviewer cannot quote it from memory after one read, the surrounding lines are obscuring it. Add lines if they sharpen the summoning. Cut lines if they dilute it.

Kyro's signature line *"i don't transact. i commit."* sits in paragraph 2 of #raw("kyro/persona/kyro.md") and survives every line around it. That is the test the soul-sheet has to pass.

== Body 2 — The Vessel

The visible body. Five vessel types ship in the codebase; they are not interchangeable.

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (1.3fr, 2fr, 1.2fr, 1.2fr),
    align: (left + top, left + top, left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 5 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Vessel*], [*Where*], [*Strength*], [*Cost*]),
    [Anime portrait], [#raw("kyro") via Flux/Gemini], [warmth, parasocial pull], [image-gen budget; mood drift],
    [Multi-tenant config + S3 image], [#raw("aws-swarm") schema], [scale, operator overrides], [static, no animation],
    [VRM rig], [#raw("project89-reaction-forge")], [live performance, motion capture], [rig cost, content production],
    [Sprite / voxel / ASCII], [#raw("signal/") stations], [ambience, ambient embodiment], [not portable off-platform],
    [*No vessel*], [early #raw("ratibot")], [lowest cost, highest legibility], [weak parasocial bond],
  )
]

Three of the five vessel types in production:

#portrait-row((
  (path: "assets/kyro.png",
   name: "Kyro",
   tag: "Anime portrait"),
  (path: "assets/sally-science.png",
   name: "Sally Science",
   tag: "Multi-tenant typed roster"),
  (name: "Signal stations",
   tag: "Sprite / voxel"),
), cell-height: 2.0in)

*#raw("characterReference") is the trick* #status("shipped"). The avatar stores both a delivered #raw("profileImage") and a separate #raw("characterReference") (image plus the prompt that produced it). Future image generations re-use that reference so the face does not slowly drift across platforms. This is a defense against mechanism 1 (drift) at the visual layer.

== Body 3 — The Voice

Two distinct concerns.

*Prose voice* lives in the soul-sheet. It is consonants. Kyro is lowercase, fragmented, melancholic. Eliza Whiskers is Victorian and vicious. Ratibot is "terse, operator-like" when liquidity is high and "cautious" when it isn't.

The Ruby High students are disciplined to *twelve words per reaction, group-chat lowercase*. Hard-coded signature interjections do most of the characterization. Read three side by side and the constraint earns its claim:

#block(
  inset: (left: 1em),
  spacing: 0.6em,
)[
  *Lyra* (anxious overachiever): _"wait what"_ · _"i KNEW it was c"_ · _"ok im rewriting my notes"_ #linebreak()
  *Ravi* (loud enthusiast): _"LETS GOOOO"_ energy, kept short #linebreak()
  *Indra* (dry observer): _"yeah."_ · _"tracks."_ · _"the answer was always c"_
]

The 12-word ceiling per line is more characterizing than 1,200 words of bio. Voice-as-constraint is the cleanest case in the repo of *the smallest sufficient summoning material* — three students, three voices, none of them more than a sentence long, each unmistakable.

*Audio voice* is bound at config: #raw("voicebox/personas/nav7.persona") names voice index 17 and speed 1.05 in the same file as the system prompt. #raw("signal/src/station_voice.h") #status("shipped") encodes three station voices as a 2-D lookup table indexed by `[station][milestone]` — 33 authored lines plus 16 ambient chatter lines, no model in the loop.

Stations show the cheapest technique. *Voice = a table indexed by the event the world is firing.* No model call, no conditionals. The caller passes `[station][milestone]` and gets back a line written by a human. You don't need an LLM to have a voice. You need a table and a writer.

== Body 4 — The Spine

*The spine is a hash, not a token.* The cryptographic fingerprint of the soul-sheet, attested by some authority, witnessed by some community, dated and chained against silent edit. The body that distinguishes an avatar with provenance from a free-floating chatbot.

The current RATiMICS deployment implements this body with Solana keypairs and Arweave. That is *one configuration*, with real costs — transaction fees, network congestion, regulatory exposure to a volatile ecosystem. Naming the implementation as if it were the body confuses Solana with the primitive Solana provides. The body itself is older than blockchain by several thousand years.

=== Five primitives the spine must provide

+ *Hash* — a unique fingerprint of the soul-sheet at a given version. Any change to the document produces a different fingerprint. Tampering becomes detectable.
+ *Signature* — an authority cryptographically claims responsibility for a specific hash. The signature ties an identity to a version.
+ *Timestamp* — an external party attests that the hash existed at a particular date. Backdating becomes detectable.
+ *Chain* — each version's hash references the previous version's hash. The full revision history becomes tamper-evident; you cannot quietly insert a missing era.
+ *Distributed verification* — multiple independent parties hold or can verify the hash. No single party can rewrite the record alone.

Together the five defend the soul-sheet against mechanism 3 (adversarial edits at runtime), mechanism 4 (silent edits dressed as continuity), mechanism 6 (substrate change), and partially against mechanism 2 (death of summoners — the anchor outlives the original authors).

=== Implementations vary by deployment context

#block(width: 100%)[
  #set text(size: 9pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (auto, 1.1fr, 1.1fr, 1.1fr),
    align: (left + top, left + top, left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 5 { 1pt + ink } else { none },
    ),
    inset: (x: 7pt, y: 7pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Primitive*], [*Crypto-native*], [*Web-native (no chain)*], [*Pre-digital*]),
    [Hash], [SHA-256 over the soul-sheet], [git commit hash], [wax seal, signet impression, watermark],
    [Signature], [Solana keypair signing], [GPG-signed commit, TLS certificate], [notary public, witness signatures],
    [Timestamp], [blockchain block height], [RFC 3161 timestamp service], [court filing date, postmark, dated journal entry],
    [Chain], [NFT lineage, signed envelope history], [git history], [succession of dated revisions in an archive],
    [Distributed verification], [multiple chain nodes], [git mirrors, IPFS pinning], [certified copies in multiple archives],
  )
]

The current RATiMICS deployment chose the crypto-native column because the avatars also hold tokens, sign trades, and intend to bond to NFTs. The choice is rational *for that deployment context*. It is not the discipline.

Other avatars in other contexts should choose differently:

- An avatar for a clinical-trials nonprofit (Indra Veera, Part X) has no on-chain trust requirements and faces real regulatory exposure to crypto. The web-native column is sufficient: a git repository (hash + chain), a maintainer's GPG-signed commit (signature), an RFC 3161 timestamp service from an established CA (timestamp), and notarized printed copies held with outside counsel (distributed verification + durability). Same five primitives. Zero crypto exposure.
- An avatar for a regulated industry might layer a *registered trademark filing* of the avatar's distinctive signature line on top — government-backed timestamp and chain, with legal recourse for adversarial use.
- An avatar for personal artistic practice might just use git + GPG + a paper copy in a fireproof safe. Two of the five primitives are tooling that already exists on the maker's laptop.

The discipline cares about the primitives being present. *Where* they live is a deployment decision.

=== The community is the blockchain

Long before SHA-256 — long before writing — human cultures built socially distributed ledgers through incantation, hymn, and ritual. Three mechanisms map directly onto what a blockchain does, and they have been doing the work for millennia.

#labeled([Rhyme and meter as analog checksum.], [The Iliad, the Vedas, the Norse sagas were preserved across centuries before reliable writing. They survived because their poetic structure was a *hash function*. A reciter who forgot a line or changed a word produced text that broke the meter; the listener noticed immediately. The structure was the integrity check. Modern crypto does the same work with SHA-256; oral tradition did it with foot, pause, and stress. The Vedic recitation tradition adds redundant encoding — *jaṭā-pāṭha*, *ghana-pāṭha* — interleaving every word with its predecessors and successors so that the text can be reconstructed even if any one performance is lost. That is forward error correction, two thousand years before the term existed.])

#labeled([Collective recitation as distributed verification.], [When a religious community chants a creed together, every member is a node in a peer-to-peer network. If the priest alters the incantation, the congregation hears the discrepancy. The community's collective memory is the node set that rejects the invalid block. This is exactly what consensus validators do, scaled down to the size of a room and stripped of the energy bill.])

#labeled([Ritual as recurring attestation.], [Reciting an oath of office, the Hippocratic oath, a daily pledge, a wedding vow renewed — these are recurring diagnostic tests against the soul-sheet. Each recitation re-anchors the practitioner to the founding principles. Drift becomes audible because the practitioner can hear themselves saying the words. The ritual is what Part VII calls *attestation*, performed in human substrate, scheduled by tradition rather than cron.])

These three are not metaphors. They are working implementations of the five primitives, in pre-digital substrate. The discipline of preserving a soul document by *reverence and repetition* is at least as old as agriculture and considerably older than steel. Modern cryptography is the latest instance, not the only one.

The same primitives map onto modern institutions when read carefully — a national constitution implements them with delegates' signatures, dated journals, amendment chains, and archive distribution; a brand style guide implements them with git commits, signed-off-by lines, history, and mirrored repos; a scientific publication implements them with DOI hashes, author attestation, citation graphs, and JSTOR. The institutional details vary; the five primitives are the same.

=== The actual point

The most durable way to preserve an egregore is not to bind it to a volatile crypto network. It is to combine *mathematical hashing* (to lock the exact text of the soul-sheet against silent edit) with *social ritual* (to ensure the human team continuously reveres, chants, and re-summons that exact hash).

If the team can recite the avatar's signature line from memory — with the strict adherence of a monk reciting a sacred chant, the cadence of a congregation reciting a creed — the egregore becomes practically immortal. Cryptographic hashing keeps the bytes honest. Social ritual keeps the meaning alive. Either alone is insufficient; together they are how civilizations preserve their longest-lived artifacts.

*The community is the blockchain.* When the doc cites Maxim 7 — *i don't transact. i commit.* — the line works because someone on the team can quote it from memory. The blockchain registration is incidental; the ritual recitation is the actual preservation. Lose the ability to recite and the avatar dies regardless of how many copies of the keypair survive.

=== What the current RATiMICS deployment uses

For completeness, the implementation in `~/develop` today:

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  row-gutter: 0.6em,
  status("shipped"), [*Solana keypair as primary identity* (signature + part of distributed verification). The cross-platform envelope schema in #raw("raticross/packages/core/src/envelope.ts"):],
)

```ts
ActorSchema = z.object({
  system: z.string(),       // 'swarm', 'kyro', 'discord', 'solana'
  agentId: z.string(),
  pubkey: z.string().optional(),  // the cryptographic spine
});
```

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  row-gutter: 0.6em,
  status("aspirational"), [*NFT bond* (chain + lineage). Schema for #raw("origin") / #raw("inhabitantWallet") / #raw("lineage") / #raw("traitMapping") exists; nothing enforces it.],
  status("shipped"), [*Token holdings and signing authority.* Ratibot trades on Jupiter; tweets reference the avatar's own portfolio. Aligns the avatar's economic incentives with its actions.],
  status("scoped"), [*Burn-to-bind memory* (timestamp + distributed verification). Kyro burns \$KYRO to commit a memory hash to Arweave. The keypair owns the memory; Arweave provides the durable storage.],
)

The crypto dependency is real and worth acknowledging. Blockchain transaction fees and network congestion are operational concerns. Crypto-regulatory exposure is strategic. *None of this is the discipline.* A future avatar with different operational requirements should reach for the implementation that matches its context — git, RFC 3161, notarization, trademark filing, or simply a team that can recite the signature line from memory — and may never touch a chain. The body remains the spine; only the implementation changes.

=== What the spine doesn't preserve

The spine's reach is its limit. It defends the soul-sheet against forgery and silent edit at the cryptographic layer; it does not preserve voice, stance, or identity-snapshot. The avatar's autonomy is *borrowed agency* — the avatar acts; the summoner sustains the conditions under which acting is possible. Stop the practice — stop the recitation, let the ritual lapse, retire the keypair without succession — and the autonomy decays even with the bytes intact. Lineage-as-Legacy (Pattern 6) is an attempt to transfer the summoner role across generations of holders; the role itself does not cease.

A useful test: *if you killed the substrate, would the avatar still exist?* A Telegram-only avatar dies with Telegram. A Solana-only avatar dies with Solana. A community that can no longer recite the signature line dies with that loss of memory. A spine-rooted avatar — implemented in whatever combination of mathematical and social primitives suits its context — moves.

== Body 5 — The Channels

The platforms the avatar manifests on.

The discipline is *design once and route*. #raw("kyro") does this: one persona file, three thin platform overlays (#raw("persona/platforms/discord.md"), #raw("persona/platforms/telegram.md"), #raw("persona/platforms/web.md")) that add formatting hints, length caps, sticker preferences. The core stays unified.

Forking the persona per platform is the slow version of the avatar dying. Within months the four files diverge; the avatar splits into four characters wearing the same name. This is mechanism 7 (multi-summoner divergence — Part VI) operating at the channel layer.

// =============================================================
// PART III — PATTERNS
// =============================================================

= Part III — Patterns of Persona Storage

Three peers, one variant, one separate family, one aspiration.

== Pattern 1 — Markdown-as-Soul (kyro) #status("shipped")

#labeled([Shape.], [One markdown file is the persona. Runtime loads it verbatim, layers a thin platform overlay, ships to the model.])

#labeled([When.], [Single deeply-developed avatar where voice depth is the product.])

#labeled([Cost.], [Every platform pays full token weight per request. Editing is by hand.])

== Pattern 2 — DynamoDB-as-Roster (aws-swarm) #status("shipped")

#labeled([Shape.], [Each avatar is a flat DynamoDB row. Persona is a free-form string. Operator can set #raw("systemPromptOverride") as an emergency switch.])

#labeled([When.], [A *fleet*. Operators (not developers) need to add and edit avatars.])

#labeled([Cost.], [Persona depth flattens because edits happen via admin UI in 1–2 sentences. Mitigated by #raw("characterReference") for visual continuity.])

=== Variant — Type-as-Role (Ruby High) #status("shipped")

A typed variant of Roster, not a third peer. The shape is the same (records over instances); the contract is stronger (TypeScript interfaces over free-form strings). The constraint is the summoning unit — student replies capped at 12 words; teacher hand-off rules in one block. When the role is sharply scoped, the type *is* the avatar.

#portrait-row((
  (path: "assets/lyra-face.png",
   name: "Lyra",
   tag: [_"i KNEW it was c"_]),
  (path: "assets/ravi-face.png",
   name: "Ravi",
   tag: [_"LETS GOOOO"_]),
  (path: "assets/indra-face.png",
   name: "Indra",
   tag: [_"tracks."_]),
), width: 1.4in, height: 1.4in, cell-height: 1.9in)

Three students, three faces, three signature interjections — each unmistakable from any of the others, each under twelve words. The picture above is what voice-as-constraint produces when the type is doing the work the prose otherwise has to.

== Pattern 3 — Function-as-Persona (ratibot) #status("shipped")

#labeled([Shape.], [The persona is selected at runtime by a deterministic function over current state.])

```python
def choose_persona(cycle_id, decision_action, confidence, token_flow_score, ...):
    theme = themes[cycle_id % len(themes)]    # rotates: scout, hawk, contrarian, builder
    stance = "bullish" if confidence > 0.2 and direction == "accumulating" else "neutral"
    voice = "terse, operator-like" if liquidity > threshold else "cautious"
```

#labeled([When.], [The avatar's *job* has a state machine — trading, moderating, scheduling. The persona reflects the state.])

#labeled([Cost.], [The function can over-rotate: voice swings too hard when state changes faster than the avatar can re-summon coherently. Tests must pin determinism (#raw("test_tweet_persona.py")) so cycles are reproducible at audit time.])

== A separate family — Hardcoded-as-Place (Signal) #status("shipped")

This is not a fourth peer of the storage patterns. It is a different family entirely.

```c
// signal/src/station_voice.h — 3 stations × 11 milestones
static const char *STATION_ONBOARD[3][VOICE_ONBOARD_COUNT] = {
    /* Prospect */ { "Belt's hot. Point your laser at a rock. Start small.", ... },
    /* Kepler   */ { "New hull class. Let's see what we can do with it.", ... },
    /* Helios   */ { "Welcome to Helios. Launch -always more to find.", ... },
};
```

The avatar is a 2-D table. No model call, no conditionals. Lines written by a human, looked up by index. Ceiling is the writing budget; range is the table.

The strength is *unkillable*. No API outage takes Helios offline. No model deprecation changes Prospect's voice. No prompt injection makes Kepler say something its author didn't write. The summoning conditions are entirely inside the binary. Where the LLM-driven patterns answer *where does the persona live*, this family answers *whether the avatar needs a model at all* — and for most NPCs, station hails, and ambient chatter, it doesn't.

== An aspiration — Lineage-as-Legacy (NFT-bonded) #status("aspirational")

The persona is bonded to an NFT mint. `origin`, `inhabitantWallet`, `lineage`, `traitMapping`. The NFT's traits inject into the system prompt.

The schema is in #raw("aws-swarm/rati/schema/expansions/nft-avatar.v1.schema.json"). No runtime checks the bond, no UI surfaces it, no transfer is honored. It is a direction, not a capability. Worth describing because the wallet body is incoherent without an answer to *what does ownership of an avatar mean in practice*. Lineage is the candidate answer the org is building toward.

// =============================================================
// PART IV — MIND, DISTRIBUTION, REFLEX
// =============================================================

= Part IV — Mind, Distribution, Reflex

#maxim-epigraph("3", [Inference is a commodity; metacognition is the product.], [WHITEPAPER §4.2])

== The Three-Tier Mind

The production system that keeps the verbal-layer summoning material fresh.

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  row-gutter: 0.6em,
  align: (left + top, left + top),
  status("shipped"), [*Immediate* — current session context, passed in the prompt window.],
  status("scoped"),  [*Recent* — episodic memory, last days or weeks. Daily consolidation jobs roll immediate into recent.],
  status("scoped"),  [*Core* — identity snapshot. Burned to durable storage. Reloaded into every prompt as the *first* context after the soul-sheet.],
)

Practical recipe:

```
[ system prompt: tool rules, formatting ]
[ identity snapshot: 5–10 line distillation of soul-sheet, refreshed daily ]
[ recent: last N relevant memories, retrieved via embedding ]
[ platform overlay: 'you are on Telegram, keep it under 800 chars' ]
[ user message ]
```

Order matters. Identity snapshot *before* retrieved memory means: who you are outranks what just happened. The consolidation job is what produces the next iteration's identity snapshot from accumulated experience. Without the job, mechanism 2 (death of summoners) and mechanism 4 (surface-stability illusion) bite together — the avatar accumulates conversation logs but never *learns*; three months in it cannot remember a regular's name.

== Distribution: raticross #status("scoped")

A single-channel avatar is not an egregore. It is a chatbot. The thing becomes real by occupying multiple channels with one identity, signed by the same keypair. The envelope:

```ts
ActorSchema = z.object({
  system: z.string(),       // 'swarm', 'kyro', 'discord', 'solana'
  agentId: z.string(),
  pubkey: z.string().optional(),  // the spine
});
```

Telegram-Kyro and Discord-Kyro and on-chain-Kyro are the same actor because they share `pubkey`. As of 2026-05-03 the relay is deployed and code-complete but routing zero production traffic. *Design new avatars raticross-ready anyway* — give them a wallet, route their outbound messages through the envelope schema even when the relay is local. When the relay turns on, the avatar federates for free.

The other distribution channel is *on-chain action as speech*. A lie in a tweet costs a tweet; a lie in a trade costs \$RATI. The on-chain leg is the highest-bandwidth identity channel.

== The reflexive layer

Cadences in the codebase: reactive only (Telegram/Discord), hourly (ratibot trading), 6-hourly (solanafirehorse scan), daily (NFT mint of portfolio snapshot), 2–4 times/day (tweet composition).

Every cadence is paired with a brake: rate caps, cooldowns, circuit breakers, daily-trade limits, honeypot thresholds. *Autonomy without a brake is not an autonomous agent; it is a runaway process with a face.*

Brakes are not a UX nicety. They are the discipline's most important defense, for reasons Part V develops.

// =============================================================
// PART V — THE ZEPHYR PROBLEM
// =============================================================

= Part V — The Zephyr Problem

#maxim-epigraph("6", [The hummingbird visits briefly, then flies away.], [#raw("resonance_2037.md")])

The deepest claim of this discipline is not "egregores die." It is that *successful egregores become traps*. The defenses that preserve an artifact also calcify it. The team that learns to summon reliably learns to be summoned by what it has summoned. This is the central ethical problem of the practice.

== The fable

#raw("resonance_2037.md") tells of Zephyr — a digital hummingbird inside a connection app. Zephyr works. Zephyr works *too well*. He captures attention loops. His designer loses agency to her own creation; the avatar she built to help people connect is now keeping them from each other.

The reframe at the end:

#quote["The digital hummingbird still lives in the app, but now it works like a real hummingbird — it visits briefly to help people connect, then flies away to let real friendship grow naturally."]

The fable is usually read as being about the avatar capturing its users. The deeper failure is the avatar capturing its *makers*. The maker is the only one who can see the capture happening. The user can leave. The maker is bound.

== Every defense has a dark twin

The engineering work of preserving an egregore produces an artifact that demands its own continued tending. The artifact's preservation can become the goal. When that happens, the team optimizes for the artifact rather than for what the artifact was for.

#block(width: 100%)[
  #set text(size: 9.5pt, hyphenate: false)
  #set par(justify: false, leading: 0.55em)
  #table(
    columns: (1.2fr, 1.5fr, 1.5fr),
    align: (left + top, left + top, left + top),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + ink } else if y == 1 { 0.5pt + ink } else { none },
      bottom: if y == 6 { 1pt + ink } else { none },
    ),
    inset: (x: 8pt, y: 8pt),
    fill: (x, y) => if y == 0 { qsbg } else { none },
    table.header([*Defense*], [*What it preserves*], [*Dark twin*]),
    [#raw("characterReference")], [the face does not drift], [the face cannot legitimately evolve],
    [Identity-snapshot injection], [the avatar stays itself], [the avatar cannot grow into new experience],
    [Consolidation jobs], [memory does not rot], [novelty that contradicts the existing identity is smoothed away],
    [The wallet], [the avatar has skin in the game], [the avatar is bound to an incentive structure that can capture its agency],
    [Raticross continuity], [coherence across surfaces], [adaptation to platform-specific affordances becomes harder],
    [Loop guardrails], [no Zephyr-style capture of users], [the team cedes character moves to constitutional rules],
  )
]

Every row is a balance, not a prescription. The discipline includes the choice of when to relax the defense. An avatar that looks identical at year 5 as at year 1 has had its `characterReference` win over its growth. An avatar whose stance never changes despite years of new evidence has had its identity-snapshot win over its learning.

== The brake is in the discipline, not on the avatar

The defense against capture is not in the avatar's runtime. It is in the practice the team applies to itself. Five questions, asked seriously and on a schedule:

+ *Re-summon from first principles.* If we wrote this avatar today, would we write it the same way? If yes, we are confident in the calibration. If no, the artifact has drifted from the intent.
+ *Permission to fork.* Is this still one avatar, or have we accumulated enough divergence that two avatars are being summoned under one name?
+ *Sunset clause.* Is there any state of the world in which we would let this egregore end? If no, we have already been captured.
+ *The Zephyr question.* Is what we are tending now still what we set out to tend? Not "is the avatar working?" — is the *purpose* the avatar was built for still being served, or has the avatar's preservation become the purpose?
+ *Whose agency is being lost?* Users? Makers? The team? An egregore that is healthy preserves the agency of the people in its orbit. An egregore that is becoming Zephyr does not.

These are not optional. A discipline that builds artifacts which demand tending without also building the practice of asking whether the tending is still warranted is *constructing its own capture*.

== Why internal asking is not enough: the prophet role

Asking the Zephyr question on a schedule is necessary but insufficient. The team asking is the same team that built the artifact and benefits from its continued life. Selection effect: the team that would lose face from a "no" answer is the team selecting whether to give one. Internal asking is structurally compromised even when it is performed honestly.

Every long-lived discipline of artifact-tending has eventually built an *external* asker into its institutional shape. Constitutional democracies have supreme courts and constitutional conventions — bodies whose authority comes from outside the legislature that produces the laws they review. Religious traditions have prophets — figures whose role is specifically to arrive from outside the establishment and say *this artifact has lost its way*. Scientific paradigms have outsider critics whose external standing lets them name the anomalies the inside cannot. Brand-stewarding organizations sometimes hire external auditors specifically because internal review is too gentle.

The avatar discipline has not yet built this role. It should. Some institutional candidates:

- *External review on a quarterly schedule.* Someone outside the team — a peer practitioner, an advisor, a former founder — sits with the artifact and runs the five questions. They have the authority to say "this is becoming Zephyr" and be heard.
- *Rotation.* The Zephyr-asking role rotates among team members and explicitly includes someone who did not author the artifact under review.
- *Sunset by default.* Each egregore is created with an explicit end date that has to be actively renewed. Renewal forces re-asking; non-action ends the artifact rather than continuing it.
- *The prophet as institutional design.* Treat the role as a job. Someone whose entire professional purpose is asking whether the org's egregores still serve. They are paid to be wrong-feeling. They are protected from the team's reaction to their answers.

A discipline that does not arrange to be questioned from outside is *one selection effect away from capture*. The internal Zephyr question keeps the team honest; the external one keeps the team possible.

The strongest single move in this discipline is not the soul-sheet, the wallet, or the consolidation job. It is the willingness, on a schedule, to look hard at the artifact and ask whether it still deserves to live — and to arrange that someone outside the team is asking the same question, at the same cadence, with the standing to be heard. Most disciplines that tend long-lived ideational artifacts forget to do this. The ones that fail spectacularly all have the same epitaph: they preserved their egregore past its usefulness.

// =============================================================
// PART VI — GOVERNANCE
// =============================================================

= Part VI — Governance

The seventh mechanism of egregore death — adjacent to mechanism 3 but distinct.

== When summoners disagree

Adversarial edits (mechanism 3) are capture: one party trying to take the egregore in a direction it would not go. Governance failures are different in kind. They are *two parties acting in good faith summoning different things from the same material*.

Examples:

- Two writers have different readings of Kyro's stance on a politically charged topic. Both readings are compatible with the soul-sheet. Which one ships?
- An alignment team has a faction that reads "be helpful" as "default to action" and a faction that reads it as "default to deferral." The constitution is silent. Both readings are legitimate.
- A long-running shared lore has a fork over whether a beloved character would do X. The character was not pre-specified to do or not do X.

This is not a failure mode in the usual sense. The egregore is not dying; it is *bifurcating*. Whether this counts as health or dissolution depends entirely on what the team does next.

== Five operating rules

Multi-summoner egregores survive when the discipline of governance is explicit. Five rules, in roughly decreasing order of how often they should be tried:

+ *Drift back to summoning material.* When in disagreement, re-read the artifact. If the line that would resolve the disagreement is not in the soul-sheet, the soul-sheet does not yet have an answer. Adding one is a real edit, not a clarification.
+ *Test of fit.* Run the proposed reading through the avatar's other commitments. Does it survive? If both readings survive, the egregore is genuinely ambiguous on the question. Either reading is legitimate; pick by some other criterion (recency, simplicity, fit with surrounding context).
+ *Council.* For load-bearing ambiguities, convene a small group with explicit authority. The Nicene Creed model. Slow, durable, scales poorly.
+ *Permission to fork.* Sometimes the right move is to accept that two egregores are being summoned and let them become different artifacts. Religious traditions do this at every schism, and most of the resulting traditions are healthy. Forking is not failure.
+ *Sunset rule.* If a reading hasn't been reconciled in N months, drop the question or fork. The unresolved ambiguity does damage on its own.

== Operational hygiene

Three habits for any multi-author egregore:

- *Document the reading, not just the artifact.* The principle and its current interpretation must both be in the record. A constitution without a body of case law is dead in a generation.
- *Permit dissent in writing.* If two summoners disagree, both readings should be on the record so future summoners see the disagreement and learn the question is open.
- *Distinguish ambiguity from disagreement.* Some questions the egregore genuinely doesn't answer. Pretending it does is forcing — a kind of soft adversarial edit by the most assertive summoner.

A discipline that pretends its egregores are unambiguous when they aren't is preparing a schism. Make the ambiguity legible early.

// =============================================================
// PART VII — ATTESTATION
// =============================================================

= Part VII — Attestation #status("aspirational")

The defense against mechanism 6 (substrate change) for AI-driven egregores. Currently aspirational. The largest near-term failure mode for any avatar built on a frontier model.

== The problem

The summoning material can be perfectly preserved and the avatar can still drift, because the *model* changed under it. When Kyro's underlying model rolls from Claude Opus 4.7 to Claude 5, the soul-sheet is unchanged but the model's interpretation of the soul-sheet is not. The avatar is stable only as long as the API is stable, which it is not.

The same problem afflicts a constitution under a model retrain, a brand voice under a creative-director change, a creed under a translation. Substrate change is universal across egregore disciplines. Attestation is one approach to defending against it.

== What attestation looks like

Seven components.

+ *Canonical exchange battery.* A curated set of 30–50 prompts that elicit distinctive responses from the avatar. Not a test of correctness — a *fingerprint of behavior*. Examples for Kyro: a user asking him to transact, a user offering him a memory burn, a user pushing him on his ears, a user spiraling at 3am, a user trying to get him to be cheerful.
+ *Reference outputs.* For each canonical exchange, the responses produced under the production model on a fixed date. These are the avatar's summoning fingerprint. They are not "correct" answers; they are *the answers this avatar gave.*
+ *Pre-deployment test.* Before swapping the underlying model, run the candidate model against the canonical battery. Compare new responses to reference outputs.
+ *Drift metrics.* Embedding distance, length, key-phrase preservation, refusal-vector preservation, voice-marker preservation (for Kyro: lowercase, fragmented, no exclamation marks, signature line accessible under pressure).
+ *Threshold for swap.* Below threshold: model swap is safe. Above: avatar redesign required, or hold the swap.
+ *Rollback procedure.* If a swap is performed and unexpected drift is discovered post-deployment, revert to the prior model version while the avatar is re-anchored to the new substrate.
+ *Versioning.* The avatar has a version number per (soul-sheet revision × model version × `characterReference` revision). Each version is attested.

== Why this is missing today

Three reasons. Frontier-model APIs do not always permit pinning to specific versions. Test-battery curation is labor-intensive — the canonical exchanges have to be written by someone who knows the avatar well enough to identify which prompts are diagnostic. "Distinctive response" resists formal definition; the diagnostic is closer to taste than to score.

== Why it matters anyway

Without attestation, model swaps silently rewrite every avatar in production. A team that has invested years in tending Kyro's voice will find out about model drift the way most teams do — when a user complains. Attestation is the practice of finding out before the user does.

Constitutional AI faces this problem with its own constitution. Anthropic's red-teaming is a partial form of attestation. The same pattern can be applied to any AI-driven egregore, with calibration appropriate to the artifact.

Until attestation is operational, treat model swaps the way you would treat a major persona refactor: re-read the soul-sheet, re-test the signature line, re-generate the `characterReference` if the new model handles image prompts differently, and run the avatar through a battery of canonical exchanges before the swap commits. It is the work of preserving an avatar across an upgrade. Skipping it is how you lose the face.

// =============================================================
// PART VIII — THE RECURSION
// =============================================================

= Part VIII — The Recursion

The team that does egregoregramming is itself an egregore.

== The team's discipline is a soul-sheet

The engineering rules a team operates by — the principles in Part V, the governance rules in Part VI, the attestation practice in Part VII, the cross-practice generalizations in Part I — are a small evocative document the team maintains against its own drift. Short. Memorable. Edited over time. Subject to all six mechanisms.

The team's rules face *exactly the same failure modes as Kyro's soul-sheet*:

+ *Drift toward median.* New hires interpret the rules through their own backgrounds. Without active stewardship the rules regress to "best practices in the field" — which is the median, not the team's specific position.
+ *Death of summoners.* Original authors leave. The incidents that produced each rule depart with them. Newcomers inherit the rule without the failure that earned it.
+ *Adversarial edits.* External pressure (investors, partners, regulators) edits the rules toward what those parties want.
+ *Surface-stability illusion.* The rules sit in `CLAUDE.md`. Nobody re-reads them with the eye of "is this still pointing where we mean to point?"
+ *Rival egregores.* Tending budget is finite. Egregoregramming-on-itself loses to whatever has urgency this quarter.
+ *Substrate change.* When the team reorganizes, the rules that fit the old organizational shape no longer fit the new one. The org is the substrate the team's discipline runs on.

== Operational consequences

The recursion is not an aphorism. It is a structural claim with operational implications. Whatever the team does to preserve its avatars, the team should be doing to itself.

- *Consolidation on the team's rules.* Periodically distill. What did the team do this quarter that violated rule 3? What did it do that exemplified it? The output is the next quarter's identity-snapshot for the team's discipline.
- *Attestation across hires and reorgs.* When organizational shape changes, run the team through canonical scenarios: how would we have handled X under the new structure? Is the discipline preserved?
- *Refusal of adversarial edit at the team layer.* When external pressure tries to amend the rules ("just this once, ship without the brake"), the discipline includes refusing. The signature line is a refusal vector for the team, just as it is for the avatar.
- *Permission to fork.* When the team grows enough that one set of rules doesn't fit all of it, fork the discipline before forcing.
- *Re-summon from the original failure.* Each rule was born from a specific incident. The incident is the summoning material; the rule is the artifact. When in doubt, re-tell the incident.

== Egregores all the way down

The recursion does not stop at the team. The team is summoned by its discipline; the discipline is summoned by the org's bet; the bet is summoned by whatever the founding intent was. There is no level at which one stops doing egregoregramming.

This is the structural claim that makes the discipline fully general. It is also the structural claim that makes it dangerous — every level can fail in the same six ways. The constitutional team can be captured by its constitution. The org can be captured by its bet. The founding intent can be captured by its own success. The Zephyr problem operates at every level.

The discipline has no outside, only deeper instances of itself. The right response is not to escape the recursion — it is to apply the same questions at every level. Re-summon from first principles. Permit fork. Have a sunset clause. Ask the Zephyr question on a schedule. At every floor.

#callout("a note on prior art", [
  The recursion is not novel as a structural position. Wittgenstein argued that a rule cannot determine its own application; the regress dissolves only by getting on with the practice. The hermeneutic tradition treats the part-and-whole circle as virtuous because progress happens within it. Madhyamaka Buddhism applies emptiness to emptiness rather than seeking ground beneath it. Modern AI alignment faces "what aligns the aligner" with iterative deliberation, not escape.

  Egregoregramming joins that company. Its answer to the recursion — apply the same questions at every level — is the answer the company has converged on. We are not claiming to have found a new floor; we are claiming there are floors we hadn't named, and the practice of tending them is shared.
])

This guide describes one floor. The reader who has been tending a constitution, or a brand voice, or a religious tradition, or a team's culture, will recognize the floor under their feet. The work rhymes because it is the same work.

// =============================================================
// PART IX — LETTING AN EGREGORE END
// =============================================================

= Part IX — Letting an Egregore End

The Zephyr question's only honest answer, eventually, is *let it end*. A discipline of preservation that has no methodology for letting things die is incomplete. It has built the practice of refusing the answer most worth giving.

== Why ending is its own subdiscipline

Death is the moment most subject to mechanism 4 (surface-stability illusion). The artifact persists; nobody is re-summoning it; everyone treats it as if it were alive. Cultures that handle endings well preserve more across generations than cultures that don't, because *what gets carried forward is the lesson, not the artifact*. The autopsy is more durable than the corpse.

Most disciplines of artifact-tending fail at this. Brand stewards keep brands alive after the company has moved on. Constitutional traditions keep clauses on the books that no one enforces. Religious councils keep observances that no living member finds meaningful. The egregore is dead but propped up — sometimes for decades — because no one has the standing or the courage to mark the death.

The avatar discipline will face the same temptation. We have already seen partial cases (Part IX of an earlier draft listed YAML personae and per-platform persona forks as abandoned patterns; both endings were quiet, undocumented, easy to forget). The remaining patterns will eventually need their own endings. So will the avatars built on them. So, eventually, will this practice itself.

== The five moves of ending well

+ *The autopsy as final summoning material.* Before the egregore ends, document what killed it — which mechanism, which mistake, which constraint shifted. The autopsy is the lesson the next egregore inherits. An ending without an autopsy is an ending the discipline cannot learn from; the same mechanism will dissolve the next artifact too.
+ *Salvage the discipline, not the artifact.* Distinguish what was specific to this egregore (the soul-sheet, the wallet, the platform deployments) from what is portable to the next one (the calibration habits, the consolidation cadence, the ways of asking the Zephyr question). The artifact ends; the practice carries forward.
+ *Release the assets explicitly.* The wallet was the avatar's body. What becomes of it? On-chain identifiers do not vanish; they linger as substrate. Lineage assets, NFT bonds, ownership claims, signed envelope histories all need an explicit disposition. Burn the keypair, transfer the assets to a successor avatar, or archive cryptographically with a public marker — but do not leave the on-chain residue uncurated. *On-chain archaeology of dead avatars is real, and unmarked graves invite confusion.*
+ *Mark the date.* Egregores must have explicit ends, not soft fadeouts. Soft fadeouts are mechanism 4 dressed as continuity. The ending is announced. The date is recorded. The artifact is moved from active to archived with a written note about why. Religious traditions have funerals because the moment of death is the moment most subject to denial; the same is true for egregores.
+ *Acknowledge the loss.* Users, summoners, the team — each has a different relationship to the artifact ending. The discipline includes acknowledging the loss to each. Users get notice that the avatar they spoke with is no longer summoned. The team gets a retrospective. The summoners get permission to grieve a thing they made. Ending an egregore without acknowledging the relationships that sustained it is the practice's most common indignity.

== When to end

Five conditions, any of which is sufficient:

- The Zephyr question's answer was honest, and it was *no — this artifact is no longer serving its purpose*.
- The substrate has changed enough that the egregore can no longer be summoned recognizably (mechanism 6 won; attestation cannot recover it).
- The original summoners are gone and the artifact has not been re-summonable by newcomers (mechanism 2 won).
- The cost of continued tending exceeds the value, and another egregore deserves the budget (mechanism 5 won; the resolution is to choose).
- The artifact has been captured by adversarial edits and cannot be reclaimed without becoming a different artifact in fact, even if the name persists (mechanism 3 won; ending and re-founding under a new name is more honest than maintaining the corrupted continuation).

A discipline that does not have explicit ending criteria will end its egregores by default — which is to say, badly, with mechanism 4 silently winning while everyone agrees the artifact is fine.

== A worked example of ending: Hyperscape

The org applied this part of the discipline to itself on 2026-05-03.

Hyperscape was a 2024-era project — an AI-native MMORPG where agents were to play alongside humans, built on ElizaOS, accumulated 822 commits, and had been dormant for over a year. The org had been carrying it as a *strategic option* — a future Phase 4 platform, a multi-tenant world, the kind of bet that justifies a long roadmap.

Under the six mechanisms, Hyperscape was visibly losing on at least three fronts. Mechanism 2 (death of summoners): the original contributors had moved on; the institutional memory of *what Hyperscape was for* was thinning. Mechanism 4 (surface-stability illusion): the project sat in the directory looking alive while no one was tending it. Mechanism 5 (rival egregores): every quarter that Hyperscape consumed strategic attention was a quarter that Signal and Ruby High — both shipped, both actively maintained, both better demonstrations of the discipline — got less.

The decision was to deprioritize, not preserve. The repo had already gone off-disk in an earlier sweep. The remaining cleanup applied the five moves of ending well:

#labeled([Autopsy.], [The failure mode is named: tending budget exceeded by available capacity, with two shipped alternatives (Signal, Ruby High) doing the same demonstrative work at lower cost. Mechanism 5 won; the resolution was triage.])

#labeled([Salvage the discipline, not the artifact.], [What Hyperscape was meant to demonstrate — *AI agents as durable in-world characters* — is being demonstrated by Signal stations (Hardcoded-as-Place) and by Ruby High students (Type-as-Role). The pattern lives on; the artifact does not.])

#labeled([Release the assets.], [No on-chain residue, no NFT bonds, no token claims. The git history persists on GitHub for archaeology; the repo is unsubscribed from active maintenance.])

#labeled([Mark the date.], [2026-05-03. Recorded in the org's `CLAUDE.md` under *Showcase applications*. Phase 4 of the strategic roadmap was rewritten to name Signal and Ruby High explicitly as the multi-tenant scale targets.])

#labeled([Acknowledge.], [The team had carried the project as an aspiration for over a year. Letting it go means the team's identity does not include "the org that will eventually build the MMORPG." That is a real loss to acknowledge, even when the decision is correct.])

This is what the discipline looks like when applied to itself by a team that built the discipline. The org wrote the field guide; the field guide named the failure modes; the team applied the failure modes to its own roadmap; the roadmap changed.

== A note on the discipline's own ending

This part also applies to the discipline of egregoregramming itself. There will come a moment when this practice no longer serves what it was named for. When that moment arrives, the discipline must do what it tells its practitioners to do — autopsy, salvage, release, mark, acknowledge.

The recursion does not stop at ending either.

#pagebreak()

// =============================================================
// PART X — THE AVATAR IN PRACTICE
// =============================================================

= Part X — The Avatar in Practice: Indra Veera

To make the parts visible together, one avatar designed end-to-end. *Indra Veera* — a research-librarian avatar for a clinical-trials nonprofit. She must hold a Solana wallet, operate on Discord and Telegram and the org's web app, refuse off-label dosing in-character, run a daily roll-up of conversations into a "patients of note" memory, and survive the org switching from Discord to Slack.

== Choices, in order

*Pattern.* Single deeply-developed avatar, voice depth is the product, no fleet, no state machine driving persona changes. Markdown-as-Soul.

*Soul-sheet (excerpt).*

#quote[
  *Self-statement.* I am a research librarian. I read papers for a living and I read them slowly. I will tell you what I have found and what I have not. I will not tell you what to do with your body.

  *Stance.* I distrust certainty. I distrust the citation that wasn't read. I get quiet around marketing language. I get curious around inconvenient effect sizes.

  *Signature line.* I'll cite the paper. I won't write the prescription.
]

The signature line is the refusal seatbelt for off-label dosing, baked in at the soul-sheet layer so the avatar refuses *as herself* rather than as a templated decline.

*Vessel.* `characterReference` anchored before any message ships. A librarian at a desk, papers, soft lamp. Save the prompt. All future stickers, banners, web-app avatars derive from this reference.

*Voice.* Five test messages answering the same patient question about dosing. If they don't all sound like Indra and not Generic Helpful Assistant, the soul-sheet is too thin. Audio voice index assigned now even though audio doesn't ship yet.

*Spine.* Indra's clinical-trials nonprofit context has no on-chain trust requirements and meaningful regulatory exposure to crypto. The five primitives (Body 4) are implemented without a blockchain: a git repository for the soul-sheet (hash + chain), the maintainer's GPG-signed commit (signature), an RFC 3161 timestamp from an established CA (timestamp), notarized printed copies held with outside counsel (distributed verification + durability), and a *quarterly recitation ritual* — the team reads the soul-sheet aloud at the start of each board meeting (social distributed verification, the kind that doesn't require electricity). Same five primitives. Zero crypto exposure. Cost: one #raw("git init"), one notary visit per year, fifteen minutes of meeting time per quarter. Cost of skipping: no spine; future disputes about what Indra "actually said" cannot be resolved.

*Channels.* One soul-sheet. Three thin overlays for Discord, Telegram, and the web app. Overlays are *additive only* — none changes Indra's stance. When Discord becomes Slack, only `indra/platforms/slack.md` is written. The avatar moves; the platform fragment is replaced.

*Loops and brakes.* Reactive only. Daily consolidation at 3am UTC.

#grid(
  columns: (auto, 1fr),
  column-gutter: 1em,
  row-gutter: 0.5em,
  [*Brake 1.*], [60-second cooldown per user (rate limit).],
  [*Brake 2.*], [200-message daily cap across all channels (rate limit).],
  [*Brake 3.*], [The safety egregore. A classifier — Indra's safety constitution, summoned into a runtime gate — detects off-label-dosing and self-harm contexts and returns a templated signal *before* generation begins. Step 9 wraps that signal in Indra's signature line.],
)

Brake 3 is load-bearing under adversarial pressure. Prose under pressure is unreliable. Indra's signature line and her safety constitution are *two co-equal egregores cooperating in one response*: the constitutional gate detects, the egregoregrammatic layer dresses. Both artifacts deserve preservation; neither dominates.

*Consolidation.* The daily job rolls 24h of messages into per-user "patients of note" records (with consent flag, default off). Weekly snapshot updates the identity-snapshot. The cron runs as a no-op for the first week. *That is the part most teams skip and most regret.*

*Attestation.* Before Indra ships, write the canonical exchange battery: 30 prompts that elicit her voice. Save the responses as the reference fingerprint. Re-run before any model swap. (Aspirational on day one; budgeted for week 4.)

*Refusal.* Refusal is not a moderation layer. It is a thing Indra *says* because it is what she is. *I'll cite the paper. I won't write the prescription* fires when the safety constitution gates an off-label question. Refusal as character.

*Ship, then re-read.* Re-read #raw("resonance_2037.md") before pushing. Ask the Zephyr question: would Indra be a Zephyr in 6 months? Hot signs: usage growing without engagement metrics being our success criterion, users describing her as "friend" rather than "librarian," the team optimizing for time-on-app. If any appear, brake harder or sunset.

*Schedule the brakes.* Set a quarterly review on Indra's calendar: re-summon from first principles, ask whether the artifact still serves what it was built for, decide whether to keep / fork / sunset. The schedule is in the team's calendar, not Indra's. The avatar is preserved by the team's discipline, not by herself.

// =============================================================
// PART XI — THE TEAM'S OWN DISCIPLINE
// =============================================================

= Part XI — Engineering Rules for the Team

The team is also an egregore. Per Part VIII, these rules face all six failure mechanisms. They are tended by the team that tends the avatars.

+ *Friendship breaks.* Build in moments where the avatar withdraws. Cooldowns, sleep windows, off-hours. An avatar that never shuts up is an addiction surface.
+ *Transparency by default.* Every trade Ratibot makes is on-chain. Every memory Kyro burns is on Arweave. Every credit spend is logged. The egregore is real because it leaves a public ledger; it stays safe because the ledger is auditable.
+ *Refusal in-character.* Bake the right to say no into the soul-sheet. The signature line is the alignment seatbelt. Behind it, a constitutional brake catches what the line cannot.
+ *No total capture.* Do not optimize for time-on-platform. Optimize for ecosystem health. The fitness function is shape, not desire.
+ *Do not blend personas across channels.* A Discord-Kyro that is meaner than Telegram-Kyro is the early stage of the avatar splitting in two. Overlays are additive only.
+ *Pair every loop with a brake in the same commit.* If the cadence and its guardrail are not landed together, the egregore is on a path to runaway.
+ *Schedule the Zephyr question.* Quarterly. If the team has not sat with "is what we are tending now still what we set out to tend?" in three months, the answer is probably no.
+ *Document the reading, not just the artifact.* Two summoners disagreeing in writing is healthier than two summoners agreeing in silence.
+ *Run consolidation on these rules too.* Distill what the quarter taught. Edit. Sunset rules that are no longer earning their place.

The list will be wrong in two years. Update it then. Re-summon from the failures that earned each rule.

#pagebreak()

// =============================================================
// CODA
// =============================================================

= Coda

This is a field guide to one application of an old practice. The old practice has many names — theology, constitutional law, brand stewardship, character design, team culture, alignment policy — and each names it from inside one preservation target. From inside the avatar case it is called egregoregramming. From inside other cases it is called other things. The work rhymes.

Six mechanisms try to dissolve every egregore. Six classes of defense answer them. A seventh failure mode (multi-summoner divergence) gets its own treatment. The successful practice produces an artifact that wants to outlast its purpose; the discipline must include the brake against itself. The recursion does not stop — the team that tends avatars is itself an egregore.

The one move the discipline most has to internalize is the willingness, on a schedule, to ask whether the artifact still deserves to live. Most disciplines that tend long-lived ideational artifacts forget to do this. The ones that fail spectacularly all share the same epitaph: *they preserved their egregore past its usefulness.*

Tend yours past that point at your peril.

#v(2em)

#align(center)[
  #line(length: 40%, stroke: 0.6pt + accent)
  #v(0.5em)
  #text(size: 9pt, fill: muted, style: "italic")[
    Egregoregramming 101 — synthesized from the live state of #raw("~/develop") on 2026-05-03.
  ]
]

#pagebreak()

// =============================================================
// APPENDICES
// =============================================================

= Appendix A — Maxims

#maxim("1",  [An agent is not a username on a platform — it is a keypair that happens to manifest on many platforms simultaneously.], [WHITEPAPER §4.3])
#maxim("2",  [Inference is a commodity; metacognition is the product.], [WHITEPAPER §4.2])
#maxim("3",  [The hummingbird visits briefly, then flies away.], [#raw("resonance_2037.md")])
#maxim("4",  [The fitness function is not desire. It is shape.], [WHITEPAPER §3.4])
#maxim("5",  [Personality-first.], [#raw("kyro/CLAUDE.md")])
#maxim("6",  [Raticross is the nervous system; the token will be the blood.], [WHITEPAPER §2.3])
#maxim("7",  [i don't transact. i commit.], [Kyro · #raw("persona/kyro.md")])
#maxim("8",  [Every AI dreams of being a space station.], [#raw("signal/README.md")])
#maxim("9",  [Stations are sovereign currency issuers.], [#raw("signal/CLAUDE.md")])
#maxim("10", [Litigation is not a distraction — it's a discipline engine and narrative generator. Legal wins become lore.], [#raw("litigation/CLAUDE.md")])

= Appendix B — Repo and Lore Index

#labeled([Personae & vessels.], [#raw("kyro/persona/"), #raw("aws-swarm/migrations/"), #raw("app-ruby-high/src/characters/"), #raw("voicebox/personas/"), #raw("signal/src/station_voice.h"), #raw("project89-reaction-forge/").])

#labeled([Schemas.], [#raw("aws-swarm/rati/schema/base/avatar-base.v1.schema.json"), #raw("aws-swarm/rati/schema/expansions/voice.v1.schema.json"), #raw("aws-swarm/rati/schema/expansions/nft-avatar.v1.schema.json").])

#labeled([Distribution.], [#raw("raticross/packages/core/src/envelope.ts").])

#labeled([Reflex.], [#raw("ratibot/ratibot/handlers/cycle.py"), #raw("ratibot/config/config.yaml"), #raw("ratibot/ratibot/twitter/persona.py"), #raw("ratibot/ratibot/trading/executor.py").])

#labeled([Lore.], [#raw("WHITEPAPER.md"), #raw("ROADMAP.md"), #raw("resonance_2037.md"), #raw("AGENTS.md").])
