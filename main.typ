#import "@preview/touying:0.6.2": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.4.1": *
#import "@preview/rustycure:0.2.0": qr-code
#import cosmos.clouds: *
#import "@preview/nerd-icons:0.2.0": change-nerd-font, nf-icon
#import "@preview/fletcher:0.5.8" as fletcher: node, edge
#import fletcher.shapes: house, hexagon

#set text(font: "Open Sans", size: 22pt, top-edge: 0.6em, bottom-edge: 2em)
#change-nerd-font("meslolgl nerd font")

#set list(marker: ([•], [--]), tight: true)
#set par(spacing: 1.05em, leading: 1em)
#set heading(numbering: numbly("{1}.", default: "1.1"))
#show heading.where(level: 2): set heading(numbering: none)
#show heading.where(level: 3): set heading(numbering: none)
#show heading.where(level: 4): set heading(numbering: none)

#let hline = {
  let color = black.transparentize(20%)
  set text(color)
  set line(stroke: color)
  h(0.2em)
  grid(
    columns: (9em, 1fr, 9em),
    align: horizon,
    column-gutter: 5pt,
    [],
    line(length: 100%, stroke: 2pt),
    [],
  )
  h(0.2em)
}

#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: show-theorion
#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer-right: none,
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: [♻️ Reliable infrastructure deployments],
    subtitle: [From imperative to declarative & reproducible — A project's lifecycle],
    author: [Luka BOULAGNON _(Platform, Infrastructure & Cloud)_],
    institution: [#strong[ReTech 2026]],
    logo: [#nf-icon("nf-fa-code")`  `],
  ),
)

#title-slide(extra: [
  #grid(
    columns: (1fr, 8em),
    align: horizon,
    column-gutter: 5pt,
    [],
    [
      #set align(right)
      #qr-code(
        "github.com/bLuka/reliable-infra",
        light-color: white.transparentize(100%),
      )
    ],
  )
])

== Different deployments paradigms <touying:hidden>

#show outline.entry: it => {
  return box(width: 100%, height: 40pt)[#text(size: 29pt, weight: 600)[#nf-icon("nf-oct-triangle_right")` ` #it.body()]]
}
#components.adaptive-columns(outline(title: none, indent: 2em, depth: 1))

= History & challenges

== History

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _Help me!_

  _My prod is down!_
]

#slide(composer: (1.2fr, 1fr))[


- Immediately after deployment

#pause

- 4 days after the last deployment

#pause

- After rolling back an older version

#pause

- _But it works on my machine_ #super[TM]

#pause

- _But it *doesn't* work *only* on my machine_ #super[#strike[TM]]

][
  #meanwhile
  #only("1")[
    #figure(image("assets/muppets_gulp.gif", width: 100%))
  ]
  #only("2")[
    #figure(image("assets/muppets_shocked.gif", width: 100%))
  ]
  #only("3")[
    #figure(image("assets/muppets_burn.gif", width: 100%))
  ]
  #only("4")[
    #figure(image("assets/muppets_triggered.gif", width: 100%))
  ]
  #only("5")[
    #figure(image("assets/muppets_sad.gif", width: 100%))
  ]
]

== From the ENIAC
 
#only("1")[
  #figure(image("assets/eniac.jpg", width: 70%))
]
#only("2")[
  #figure(image("assets/eniac_panel.jpg", width: 70%))
]

== Dedicated Datacenter / Colocation

#slide(align: center)[
  #only("1")[
    #figure(image("assets/datacenter_rack.jpg", width: 70%))
  ]
]

#slide(align: center, self => [
  #set text(weight: 600)
  #let (uncover, only, alternatives) = utils.methods(self)
  #fletcher-diagram(
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,

    node((-1, 0), [User], fill: none, stroke: none),

    only("1", edge("-->")),
    only("1", node((0, 0), [Marketplace], radius: 3.4em)),
    pause,

    only("2-", edge((-1, 0), (0, 0), [❌], "-->")),
    node((0, 0), [\ #strike[Marketplace]\ (Down)], fill: gradient.radial(red.lighten(60%), red.darken(15%), center: (30%, 20%), radius: 80%), radius: 3.4em, name: <SRVA>),

    pause,
    edge((0, 0), (1, -0.66), "<|-|>"),
    node((1, -0.66), [Server B], radius: 3.4em, name: <SRVB>),
    edge("<|-|>"),
    node((1, 0.66), [Server C], radius: 3.4em, name: <SRVC>),
    edge((0, 0), "<|-|>"),
    edge((1, 0.66), "ll", (-1, 0), [✅], "<--", label-pos: 0.392),

    only("4", node((-0.11, -0.91), [_Cluster_], fill: none, name: <Cluster>)),
    only("4", node(enclose: (<Cluster>, <SRVA>, <SRVB>, <SRVC>), stroke: (paint: black, thickness: 1pt, dash: "loosely-dashed"), fill: black.transparentize(95%), snap: false)),
    pause,
  )
])

== From physical servers to virtual machines

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  #place(top+right, figure(image("assets/bongocat.gif", width: 21%)))
  _Help me!_
  
  _I've had enough of installing the same servers again and again…_
]

#slide(align: center, self => [

  #set text(weight: 600)
  #let (uncover, only, alternatives) = utils.methods(self)
  #fletcher-diagram(
    cell-size: 100pt,
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,

    // FRAME 1

    only("1", node((0, 0), [Server A], radius: 3.4em, name: <SRVA>)),
    only("1", node((1, -0.66), [Server B], radius: 3.4em, name: <SRVB>)),
    only("1", node((1, 0.66), [Server C], radius: 3.4em, name: <SRVC>)),

    only("1-2", edge((0, 0), (1, -0.66), "<|-|>")),
    only("1-2", edge((1, -0.66), (1, 0.66), "<|-|>")),
    only("1-2", edge((0, 0), (1, 0.66), "<|-|>")),

    pause,

    // FRAME 2

    only("2",  node((0, 0), [], radius: 3.4em, name: <SRVA>)),
    only("3-", node((0, 0), [], radius: 3.4em, name: <SRVA>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),

      only("2", node((0 - 0.13, 0 - 0.13), [A], radius: 0.8em, name: <SRVA_A>)),
      only("2", node((0 - 0.13, 0 + 0.13), [C], radius: 0.8em, name: <SRVA_C>)),
      only("2", node((0 + 0.13, 0 - 0.13), [B], radius: 0.8em, name: <SRVA_B>)),
      only("2", node((0 + 0.13, 0 + 0.13), [D], radius: 0.8em, name: <SRVA_D>)),

      only("3-4", node((0 - 0.13, 0 - 0.13), [M], radius: 0.8em, name: <SRVA_A>)),
      only("3-", node((0 - 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((0 + 0.13, 0 - 0.13), [],  radius: 0.8em, name: <SRVA_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((0 + 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),

    only("2",  node((1, -0.66), [], radius: 3.4em, name: <SRVB>)),
    only("3-", node((1, -0.66), [], radius: 3.4em, name: <SRVB>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),

      only("2", node((1 - 0.13, -0.66 - 0.13), [A], radius: 0.8em, name: <SRVB_A>)),
      only("2", node((1 - 0.13, -0.66 + 0.13), [C], radius: 0.8em, name: <SRVB_C>)),
      only("2", node((1 + 0.13, -0.66 - 0.13), [B], radius: 0.8em, name: <SRVB_B>)),
      only("2", node((1 + 0.13, -0.66 + 0.13), [D], radius: 0.8em, name: <SRVB_D>)),

      only("3-", node((1 - 0.13, -0.66 - 0.13), [M], radius: 0.8em, name: <SRVB_A>)),
      only("3-", node((1 - 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((1 + 0.13, -0.66 - 0.13), [],  radius: 0.8em, name: <SRVB_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((1 + 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),


    only("2",  node((1, 0.66), radius: 3.4em, name: <SRVC>)),
    only("3-", node((1, 0.66), radius: 3.4em, name: <SRVC>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),

      only("2", node((1 - 0.13, 0.66 - 0.13), [A], radius: 0.8em, name: <SRVC_A>)),
      only("2", node((1 - 0.13, 0.66 + 0.13), [C], radius: 0.8em, name: <SRVC_C>)),
      only("2", node((1 + 0.13, 0.66 - 0.13), [B], radius: 0.8em, name: <SRVC_B>)),
      only("2", node((1 + 0.13, 0.66 + 0.13), [D], radius: 0.8em, name: <SRVC_D>)),

      only("3-", node((1 - 0.13, 0.66 - 0.13), [M], radius: 0.8em, name: <SRVC_A>)),
      only("3-", node((1 - 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((1 + 0.13, 0.66 - 0.13), [],  radius: 0.8em, name: <SRVC_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("3-", node((1 + 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),


    pause,

    // FRAME 3

    only("3-", edge(<SRVA>, <SRVB>, "<|..|>", stroke: black.transparentize(80%))),
    only("3-", edge(<SRVA>, <SRVC>, "<|..|>", stroke: black.transparentize(80%))),
    only("3-", edge(<SRVB>, <SRVC>, "<|..|>", stroke: black.transparentize(80%))),

    only("3-4", edge(<SRVA_A>, <SRVB_A>, "<|-|>", bend: 30deg)),
    only("3-4", edge(<SRVA_A>, <SRVC_A>, "<|-|>", bend: -30deg)),
    only("3-", edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg)),

    pause,

    // FRAME 4

    only("4", node((-1, -0.135), [User], fill: none, stroke: none)),

    only("4", edge((-1, -0.135), <SRVA_A>, "-->")),

    pause,

    // FRAME 5
    
    only("5-", node((0 - 0.13, 0 - 0.13), [], fill: gradient.radial(red.lighten(60%).transparentize(50%), red.darken(15%).transparentize(50%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(60%), radius: 0.8em, name: <SRVA_A>)),
    only("5-", edge(<SRVA_A>, <SRVB_A>, "<|..|>", bend: 30deg, stroke: red.darken(50%).transparentize(50%))),
    only("5-", edge(<SRVA_A>, <SRVC_A>, "<|..|>", bend: -30deg, stroke: red.darken(50%).transparentize(50%))),


    pause,

    // FRAME 6

    only("6-", node((2, 0), radius: 3.4em, name: <SRVD>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%))),
      only("6-", node((2 - 0.13, 0 - 0.13), [M], radius: 0.8em, name: <SRVD_A>, fill: gradient.radial(green.lighten(80%), green, center: (30%, 20%), radius: 80%))),

    only("6-", edge(<SRVB>, <SRVD>, "<|..|>", stroke: black.transparentize(80%))),
    only("6-", edge(<SRVC>, <SRVD>, "<|..|>", stroke: black.transparentize(80%))),

    only("6-", edge(<SRVD_A>, <SRVD_A>, "<..", bend: 159deg, loop-angle: 30deg, label: text(size: 18pt)[_New_\ _VM…_], label-pos: 0.56)), only("6-", edge(<SRVD_A>, <SRVB_A>, "<|-|>", bend: -30deg)),
    only("6-", edge(<SRVD_A>, <SRVC_A>, "<|-|>", bend: 30deg)),
    only("6-", edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg)),
  )
])

#slide(align: center)[
  #set text(weight: 600)
  #fletcher-diagram(
    cell-size: 100pt,
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,

    // FRAME 1

    node((0, 0), [], radius: 3.4em, name: <SRVA>, fill: gradient.radial(red.lighten(60%).transparentize(50%), red.darken(15%).transparentize(50%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(60%)),

      node((0 - 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 - 0.13), [],  radius: 0.8em, name: <SRVA_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    node((1, -0.66), [], radius: 3.4em, name: <SRVB>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, -0.66 - 0.13), [M], radius: 0.8em, name: <SRVB_A>),
      node((1 - 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 - 0.13), [],  radius: 0.8em, name: <SRVB_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),


    node((1, 0.66), radius: 3.4em, name: <SRVC>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, 0.66 - 0.13), [M], radius: 0.8em, name: <SRVC_A>),
      node((1 - 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 - 0.13), [],  radius: 0.8em, name: <SRVC_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    edge(<SRVA>, <SRVB>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVA>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVB>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),

    node((0 - 0.13, 0 - 0.13), [],  radius: 0.8em, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%), name: <SRVA_A>),
    edge(<SRVA_A>, <SRVB_A>, "<|..|>", bend: 30deg, stroke: red.darken(10%)),
    edge(<SRVA_A>, <SRVC_A>, "<|..|>", bend: -30deg, stroke: red.darken(10%)),


    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),

    pause,

    node((2, 0), radius: 3.4em, name: <SRVD>, fill: gradient.radial(green.lighten(80%).transparentize(10%), green.transparentize(10%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(40%)),
      node((2 - 0.13, 0 - 0.13), [M], radius: 0.8em, name: <SRVD_A>, fill: gradient.radial(green.lighten(80%), green, center: (30%, 20%), radius: 80%)),
      node((2 - 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVD_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((2 + 0.13, 0 - 0.13), [],  radius: 0.8em, name: <SRVD_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((2 + 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVD_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    edge(<SRVB>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVC>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVD>, <SRVD>, "<..", bend: 120deg, loop-angle: 30deg, label: text(size: 18pt)[_New_\ _server…_], label-pos: 0.56),
    edge(<SRVD_A>, <SRVB_A>, "<|-|>", bend: -30deg, layer: 1),
    edge(<SRVD_A>, <SRVC_A>, "<|-|>", bend: 30deg, layer: 1),
    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg, layer: 1),
  )

]


== Origins of containers

#slide(align: center)[
  #set text(weight: 600)
  #fletcher-diagram(
    cell-size: 100pt,
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,

    // FRAME 1

    node((0, 0), [], radius: 3.4em, name: <SRVA>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((0 - 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 - 0.13), [],  radius: 0.8em, name: <SRVA_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    node((1, -0.66), [], radius: 3.4em, name: <SRVB>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, -0.66 - 0.13), [M], radius: 0.8em, name: <SRVB_A>),
      node((1 - 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 - 0.13), [],  radius: 0.8em, name: <SRVB_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),


    node((1, 0.66), radius: 3.4em, name: <SRVC>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, 0.66 - 0.13), [M], radius: 0.8em, name: <SRVC_A>),
      node((1 - 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 - 0.13), [],  radius: 0.8em, name: <SRVC_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    edge(<SRVA>, <SRVB>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVA>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVB>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),

    node((0 - 0.13, 0 - 0.13), [], fill: gradient.radial(red.lighten(60%).transparentize(50%), red.darken(15%).transparentize(50%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(60%), radius: 0.8em, name: <SRVA_A>),
    edge(<SRVA_A>, <SRVB_A>, "<|..|>", bend: 30deg, stroke: red.darken(50%).transparentize(50%)),
    edge(<SRVA_A>, <SRVC_A>, "<|..|>", bend: -30deg, stroke: red.darken(50%).transparentize(50%)),

    node((2, 0), radius: 3.4em, name: <SRVD>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((2 - 0.13, 0 - 0.13), [M], radius: 0.8em, name: <SRVD_A>, fill: gradient.radial(green.lighten(80%), green, center: (30%, 20%), radius: 80%)),

    edge(<SRVB>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVC>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVD_A>, <SRVB_A>, "<|-|>", bend: -30deg),
    edge(<SRVD_A>, <SRVC_A>, "<|-|>", bend: 30deg),
    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),
  )
]

#slide(align: center)[
  #set text(weight: 600)
  #fletcher-diagram(
    cell-size: 100pt,
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 4em,

    // FRAME 1

    node((0, 0), [], radius: 3.4em, name: <SRVA>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((0 - 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 - 0.13), [],  radius: 0.8em, name: <SRVA_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((0 + 0.13, 0 + 0.13), [],  radius: 0.8em, name: <SRVA_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    node((1, -0.66), [], radius: 3.4em, name: <SRVB>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, -0.66 - 0.13), [M], radius: 0.8em, name: <SRVB_A>, stroke: (paint: white, thickness: 4pt, dash: "dashed")),
      node((1 - 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 - 0.13), [],  radius: 0.8em, name: <SRVB_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, -0.66 + 0.13), [],  radius: 0.8em, name: <SRVB_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),


    node((1, 0.66), radius: 3.4em, name: <SRVC>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

      node((1 - 0.13, 0.66 - 0.13), [M], radius: 0.8em, name: <SRVC_A>, stroke: (paint: white, thickness: 4pt, dash: "dashed")),
      node((1 - 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_C>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 - 0.13), [],  radius: 0.8em, name: <SRVC_B>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((1 + 0.13, 0.66 + 0.13), [],  radius: 0.8em, name: <SRVC_D>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    edge(<SRVA>, <SRVB>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVA>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVB>, <SRVC>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),

    node((0 - 0.13, 0 - 0.13), [], fill: gradient.radial(red.lighten(60%).transparentize(50%), red.darken(15%).transparentize(50%), center: (30%, 20%), radius: 80%), stroke: (paint: white, thickness: 4pt, dash: "dashed"), radius: 0.8em, name: <SRVA_A>),
    edge(<SRVA_A>, <SRVB_A>, "<|..|>", bend: 30deg, stroke: red.darken(50%).transparentize(50%)),
    edge(<SRVA_A>, <SRVC_A>, "<|..|>", bend: -30deg, stroke: red.darken(50%).transparentize(50%)),

    node((2, 0), radius: 3.4em, name: <SRVD>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
      node((2 - 0.13, 0 - 0.13), [M], radius: 0.8em, name: <SRVD_A>, fill: gradient.radial(green.lighten(80%), green, center: (30%, 20%), radius: 80%), stroke: (paint: white, thickness: 4pt, dash: "dashed")),

    edge(<SRVB>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),
    edge(<SRVC>, <SRVD>, "<|..|>", stroke: black.transparentize(80%)),

    edge(<SRVD_A>, <SRVB_A>, "<|-|>", bend: -30deg),
    edge(<SRVD_A>, <SRVC_A>, "<|-|>", bend: 30deg),
    edge(<SRVB_A>, <SRVC_A>, "<|-|>", bend: 30deg),
  )
]

#slide[

  #place(top+right, figure(image("assets/bongocat_clap.gif", width: 8%)))
  A container is a server that is *lighter* and requires *fewer dedicated resources* than a virtual machine:

  #par[]

  - It is very fast to build and start up (in seconds)

  - It is easier to use (_It runs on my machine!_ #super[TM])

  - It _can_ be declarative
]

== _Serverless_

#slide(align: left, self => [
  #place(top + right, dy: -10pt, dx: 10pt, figure(image("assets/bongocat_mouse.gif", width: 10%)))
  #v(65pt)

  We can rent a database (_DBaaS_) or a sandbox to run code (_FaaS_) without managing the OS or hardware: we move to *serverless*.

  #v(10pt)


  #set text(weight: 600)
  #let cell_height = -30pt
  #let cell_width = 152pt
  #let stack(i, colored) = {
    let color_managed   = orange.lighten(50%)
    let color_unmanaged = blue.lighten(70%)
    return (
      node((rel: (i * cell_width, 1 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 1 { color_managed } else { color_unmanaged }), [Application]),
      node((rel: (i * cell_width, 2 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 2 { color_managed } else { color_unmanaged }), [Data]),
      node((rel: (i * cell_width, 3 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 3 { color_managed } else { color_unmanaged }), [Execution]),
      node((rel: (i * cell_width, 4 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 4 { color_managed } else { color_unmanaged }), [OS]),
      node((rel: (i * cell_width, 5 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 5 { color_managed } else { color_unmanaged }), [Server]),
      node((rel: (i * cell_width, 6 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 6 { color_managed } else { color_unmanaged }), [Disks]),
      node((rel: (i * cell_width, 7 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 7 { color_managed } else { color_unmanaged }), [Network]),
    )
  }

  #fletcher-diagram(
    node-stroke: 1pt,
    node-inset: 10.6pt,
    cell-size: (60pt),

    node((0, 0), text(weight: 900)[On Premise], name: <OnPremise>, fill: none, stroke: none),
    stack(0, 10),

    pause,

    node((rel: (1 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[IaaS], name: <IaaS>, fill: none, stroke: none),
    stack(1, 4),

    pause,

    node((rel: (2 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[CaaS], name: <CaaS>, fill: none, stroke: none),
    stack(2, 3),

    pause,

    node((rel: (3 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[PaaS], name: <Serverless>, fill: none, stroke: none),
    stack(3, 2),

    pause,

    node((rel: (4 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[SaaS], name: <SaaS>, fill: none, stroke: none),
    stack(4, 1),
  )

])

#slide[
]

= State of the art

== Imperative

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  As a sysadmin,

  _What do I want with my system?_
]
#slide[

#set list(marker: ([•], [--]))
#pause
  - Easy to configure #pause
  - Available and reliable#pause, even when…
    - I update dependencies #pause
    - hardware breaks #pause
    - I replace disks, upgrade RAM 💸, change CPU…
]
#slide[
  In programming, the *imperative paradigm* consists of writing a program as a sequence of instructions: *it's a cookbook*.

  To deploy an on-premise infrastructure, there is a whole series of processes to follow in order to acquire, install, start, or maintain servers.
]

== Declarative

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  No… As a sysadmin,

  _What do I *really* want with my system?_
]
#slide[

  #set list(marker: ([•], [--]))
  #set text(fill: black.transparentize(70%))
  - Easy to configure
  - Available and reliable #pause
  #set text(fill: black)
  - Document properly:
    - _What_ is on it?
    - _Why_ in that way?
    - _How_ it's done #pause
  - Easily _change_ and maintain #pause
  - Easy to review #pause
]
#slide[
*Declarative programming* contrasts with the imperative paradigm and consists of describing a *final state* rather than the steps to reach it.
]

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 39pt)
  _It's like telling the chef:_ "I want a Mont d'Or".

  #h(0em)

  *_You don't give them the recipe,_*

  _It's up to them to buy the ingredients and to know and execute the recipe._
]

#slide[
Many common languages are *declarative*: HTML, Markdown, SQL…

#hline

#set par(first-line-indent: 0em, hanging-indent: 0em)
Yet, not all declarative languages can compute data: an HTML page cannot perform division calculations.
]

#slide[
Declarative and *Turing-complete* languages are numerous and more specialized:

#h(0.3em)

#pause

- *Haskell* or *OCaml* for functional programming

#pause

- *Prolog* or *Mercury* for logic programming

#pause

- *Typst* as a markup language (with love ❤️ )
]

== Declarative Dependency Managers

#slide[
  ```bash
  cd $(mktemp -d)
  git clone "https://github.com/modem7/docker-rickroll"
  cd docker-rickroll/
  ```
  #pause
  #set text(weight: 900)
  ```bash
  docker build -t my_image .
  ```
  #set text(weight: 500)
  ```bash
  docker run -p 8080:8080 my_image
  ```

  #pause
  #h(0em)

  The *`docker build`* command has no effect if called again twice; it is *idempotent*.

  An action is *idempotent* when it has the same effect, whether called once or repeated.
]

#slide[
  For example, *npm* is a package manager that _can_ be declarative:

  #pause
  #h(0em)

  ```bash
  cd $(mktemp -d)
  ```
  #set text(weight: 900)
  #only("2")[
    ```bash
    npm install menari
    ```
  ]
  #only("3")[#strike[
    ```bash
    npm install menari
    ```
  ]]
  #only("4")[
    ```bash
    $EDITOR package.json
    npm install
    ```
  ]
  #set text(weight: 500)
  ```bash
  node ./node_modules/menari
  ```
]

== Declarative and Reproducible

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _No! You really don't get it!_

  #h(0em)

  _As a sysadmin,_

  _What am I *dreaming* of with my system?_
]
#slide[

  #set list(marker: ([•], [--]))
  #set text(fill: black.transparentize(70%))
  - Easy to configure
  - Available and reliable
  - Document properly
  - Easy to _change_ and maintain
  - Easy to review #pause
  #set text(fill: black)
  - Easy to reproduce #pause
  - Prevent undeclared changes #pause
  - Allow changes from non-sysadmins #pause
]
#slide[
  Sometimes, we want our declarative code to be strictly *reproducible*: the same code has exactly the same results.

  #h(0em)

  A web page referencing *external resources* is not reproducible, as it is not strictly identical if those external resources change.

  *Without external resources*, an HTML page is strictly *identical* and *reproducible*:
]
#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  Same causes, same effects.
]

#slide[
  To ensure reproducible reinstalls, *npm* records the exact versions of packages in the *`./package-lock.json`* file:

  #h(0em)
  #set text(weight: 500)
  ```bash
  $EDITOR package-lock.json
  ```
  #only("2")[
    #set text(weight: 900)
    ```bash
    npm install
    ```
  ]
  #only("3")[#strike[
    ```bash
    npm install
    ```
  ]]
  #only("4-")[
    ```bash
    npm ci
    ```
  ]

  #pause
  #v(24pt)

  #only("5")[
    #set text(weight: 400)
    This _lockfile_ scheme is everywhere: `yarn` or `pnpm` in *JavaScript*, `pip` with *Python*, `cargo` in *Rust*, `composer` in *PHP*, etc.
  ]
]

#slide(title: "Autres outils de gestion de conteneurs")[
  There are other declarative tools for deploying and orchestrating containers:
  #pause

  - `docker compose` is the declarative alternative to `docker run`  
  #pause  
  - `docker swarm` for orchestrating containers across clusters  
  #pause  
  - Kubernetes enables management of containers and monitoring of cloud resources (storage requests, public IP addresses, etc.)  
  #pause  
  - etc.
]

== Infrastructure Deployment

#slide[
  #let cell_height = -30pt
  #let cell_width = 152pt
  #let stack(i, colored) = {
    let color_managed   = orange.lighten(50%)
    let color_unmanaged = blue.lighten(70%)
    return (
      node((rel: (i * cell_width, 1 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 1 { color_managed } else { color_unmanaged }), [Application]),
      node((rel: (i * cell_width, 2 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 2 { color_managed } else { color_unmanaged }), [Data]),
      node((rel: (i * cell_width, 3 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 3 { color_managed } else { color_unmanaged }), [Execution]),
      node((rel: (i * cell_width, 4 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 4 { color_managed } else { color_unmanaged }), [OS]),
      node((rel: (i * cell_width, 5 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 5 { color_managed } else { color_unmanaged }), [Server]),
      node((rel: (i * cell_width, 6 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 6 { color_managed } else { color_unmanaged }), [Disks]),
      node((rel: (i * cell_width, 7 * cell_height), to: (0, 0)), width: cell_width - 10pt, fill: (if colored < 7 { color_managed } else { color_unmanaged }), [Network])
    )
  }

  #set text(weight: 600)
  #fletcher-diagram(
    node-stroke: 1pt,
    node-inset: 10.6pt,
    cell-size: (60pt),

    node((0, 0), text(weight: 900)[On Premise], name: <OnPremise>, fill: none, stroke: none),
    stack(0, 10),

    node((rel: (1 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[IaaS], name: <IaaS>, fill: none, stroke: none),
    stack(1, 4),

    node((rel: (2 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[CaaS], name: <CaaS>, fill: none, stroke: none),
    stack(2, 3),

    node((rel: (3 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[Serverless], name: <Serverless>, fill: none, stroke: none),
    stack(3, 2),

    node((rel: (4 * cell_width, 0pt), to: (0, 0)), text(weight: 900)[SaaS], name: <SaaS>, fill: none, stroke: none),
    stack(4, 1),
  )
]

// N'est PAS reproductible _stricto sensus_
#slide[
  *Terraform* allows you to declare and deploy infrastructure from code (literally _Infrastructure as Code_) using *HCL* language:

  #pause
  #v(12pt)

  #text(24pt)[*`-- main.tf`*]
  
  #only("2")[
    ```hcl

    resource "aws_instance" "my_server" {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t2.micro"
    }
    ```

    #h(1em)

    Then run: `terraform apply`
  ]
  #only("3")[
    ```hcl

    // empty



    ```

    #h(1em)

    Then run: `terraform apply`
  ]
]

== Tools — Local Environment

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  I'm done with this presentation.

  #h(0em)

  I'm a developper,

  How does that even affect me?
]

#slide(align: top)[
  #v(1.5em)
  === My local tools…

  ==== #h(2em) …Per project
]

#slide(align: top)[
  #v(1.5em)
  === My local tools…

  ==== #h(2em) …Per user
  Nix
]
#slide(align: top)[
  #v(1.5em)
  === My local tools…

  ==== #h(2em) …Per operating system
  Nix
]

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  I'm not even a tech person…

  #h(0em)

  What's the point of being here?
]

= In practice

== Collaborative work — Infrastructure as Code

#slide[
  #set align(center)
  #fletcher-diagram(
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 3em,

    // FRAME 1

    node((0, 0), [Business], radius: 2.8em, name: <biz>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    pause,
    edge(<biz>, <lead>, "-|>", align(center)[Ask for\ features], bend: 53deg, stroke: black.transparentize(10%)),
    pause,

    node((1, 0), [Leads], radius: 2.8em, name: <lead>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<biz>, <lead>, "<..>", align(center)[1.], bend: 23deg, stroke: black.transparentize(10%)),
    pause,
    edge(<lead>, <dev>, "-|>", align(center)[Define\ architecture], bend: 53deg, stroke: black.transparentize(10%)),
    pause,

    node((2, 0), [Devs], radius: 2.8em, name: <dev>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<lead>, <dev>, "<..>", align(center)[2.], bend: 23deg, stroke: black.transparentize(10%)),
    pause,
    edge(<dev>, <ops>, "-|>", align(center)[Provide\ specifications], bend: 53deg, stroke: black.transparentize(10%)),
    pause,

    node((3, 0), [Ops], radius: 2.8em, name: <ops>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<dev>, <ops>, "<..>", align(center)[3.], bend: 23deg, stroke: black.transparentize(10%)),
    pause,
    edge(<ops>, <dc>, "-|>", align(center)[Install machines,\ tools, DB, deploy], bend: 53deg, stroke: black.transparentize(10%)),
    pause,

    node((4, 0), [Datacenter], radius: 2.8em, name: <dc>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), green.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<ops>, <dc>, "<..>", align(center)[4.], bend: 23deg, stroke: black.transparentize(10%)),
    pause,
    edge(<dc>, <dev>, "<..>", align(center)[5. System\ tests], bend: 41deg, label-pos: 71%, label-sep: -21pt, stroke: black.transparentize(50%)),
    pause,


    edge(<dc>, <biz>, "<..>", align(center)[6. Acceptance tests], bend: 40deg, label-pos: 77%, label-sep: -26pt, stroke: black.transparentize(50%)),
  )

  #set align(left)

  #meanwhile
  #columns(5, gutter: 8pt)[
    #colbreak()
    #colbreak()
  ]
]

== Workflows

#slide[
  #set align(center)
  #fletcher-diagram(
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 3em,

    // FRAME 1

    node((0, 0), [Business], radius: 2.8em, name: <biz>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<biz>, <lead>, "-|>", align(center)[Ask for\ features], bend: 53deg, stroke: black.transparentize(10%)),

    node((1, 0), [Leads], radius: 2.8em, name: <lead>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<biz>, <lead>, "<..>", align(center)[1.], bend: 23deg, stroke: black.transparentize(10%)),
    edge(<lead>, <dev>, "-|>", align(center)[Define\ architecture], bend: 53deg, stroke: black.transparentize(10%)),

    node((2, 0), [Devs], radius: 2.8em, name: <dev>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<lead>, <dev>, "<..>", align(center)[2.], bend: 23deg, stroke: black.transparentize(10%)),
    edge(<dev>, <ops>, "-|>", align(center)[Provide\ specifications], bend: 53deg, stroke: black.transparentize(10%)),

    node((3, 0), [Ops], radius: 2.8em, name: <ops>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<dev>, <ops>, "<..>", align(center)[3.], bend: 23deg, stroke: black.transparentize(10%)),
    edge(<ops>, <dc>, "-|>", align(center)[Install machines,\ tools, DB, deploy], bend: 53deg, stroke: black.transparentize(10%)),

    node((4, 0), [Datacenter], radius: 2.8em, name: <dc>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), green.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<ops>, <dc>, "<..>", align(center)[4.], bend: 23deg, stroke: black.transparentize(10%)),
    edge(<dc>, <dev>, "<..>", align(center)[5. System\ tests], bend: 41deg, label-pos: 71%, label-sep: -21pt, stroke: black.transparentize(50%)),


    edge(<dc>, <biz>, "<..>", align(center)[6. Acceptance tests], bend: 40deg, label-pos: 77%, label-sep: -26pt, stroke: black.transparentize(50%)),

    edge((-0.3, -1), (4.4, 1.5), stroke: (paint: red, thickness: 4pt)),
    edge((-0.3, 1.5), (4.4, -1), stroke: (paint: red, thickness: 4pt)),
  )
]

#slide[
  #set align(center)
  #fletcher-diagram(
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 3em,

    // FRAME 1

    node((0, 0), [Business], radius: 2.8em, name: <biz>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<biz>, <lead>, "-|>", align(center)[Ask for\ features], bend: 53deg, stroke: black.transparentize(10%)),

    node((1, 0), [Leads], radius: 2.8em, name: <lead>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<lead>, <dev>, "-|>", align(center)[Discuss\ architecture], bend: 53deg, stroke: black.transparentize(10%)),

    node((2, 0), [Devs], radius: 2.8em, name: <dev>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    node((2.7, 1), [Ops], radius: 2.8em, name: <ops>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<ops>, <dc>, "-|>", label-pos: 10%, align(left)[#highlight[Prepare and maintain\ infra]], bend: -30deg, stroke: black.transparentize(10%)),

    node((3.5, 0), [Datacenter], radius: 2.8em, name: <dc>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), green.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),

    edge(<dev>, <dc>, "-|>", align(center)[#highlight[Deploy resources]], bend: 45deg, stroke: black.transparentize(10%)),
    edge(<dc>, <dev>, "<..>", align(center)[#highlight[System tests]], bend: -12deg, stroke: black.transparentize(10%)),
    edge(<lead>, <dc>, "<..>", align(center)[], bend: -34deg, stroke: black.transparentize(10%)),
    edge(<dev>, <dc>, "<..>", align(center)[#highlight[Infra reviews]], bend: -34deg, stroke: black.transparentize(10%)),
  )

  #pause

  #place(bottom+left)[
  #set text(font: "libertinus serif", size: 48pt)
    #h(0.5em) _DevOps_
    #v(0.6em)
  ]
]

== Deployments lifecycles

#slide[
]

== Gestion des risques

=== Plans de continuité & reprise d'activité

=== Gestion des « déploiements » d'infrastructure

== Indicateur de réussite ?

#slide[
]

#show: appendix
