#import "@preview/touying:0.6.2": *
#import themes.metropolis: *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.4.1": *
#import "@preview/rustycure:0.2.0": qr-code
#import cosmos.clouds: *
#import "@preview/nerd-icons:0.2.0": change-nerd-font, nf-icon
#import "@preview/fletcher:0.5.8" as fletcher: node, edge
#import fletcher.shapes: brace

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
  config-common(
    frozen-counters: (theorem-counter,),
    show-notes-on-second-screen: right,
  ),
  config-info(
    title: [♻️ Reliable infrastructure deployments],
    subtitle: [From imperative to declarative & reproducible — A project lifecycle],
    author: [Luka BOULAGNON _(Platform, Infrastructure & Cloud)_],
    institution: [#strong[ReTech 2026]],
    logo: [#image("assets/computer.png", height: 1.4em)],
  ),
)

#title-slide(extra: block(width: 100%)[
  #set text(size: 16pt)
  #set align(right)
  #set par(spacing: 1em, leading: 0em)
  #v(1em)
  _Also find the presentation on #link("https://bluka.github.io/reliable-infra")[*`bluka.github.io/reliable-infra`*]_ #h(14pt)
  #v(-1em)
  #qr-code(
    "github.com/bLuka/reliable-infra",
    height: 44%,
    light-color: white.transparentize(100%),
  )
  #v(-3em)
])

= Outline <touying:hidden>

#show outline.entry: it => {
  return box(width: 100%, height: 40pt)[#text(size: 29pt, weight: 600)[#nf-icon("nf-oct-triangle_right")` ` #it.body()]]
}
#components.adaptive-columns(outline(title: none, indent: 2em, depth: 1))

#speaker-note[
  Je vais essayer de parler des nouvelles pratiques dans la gestion des déploiements.

  *Disclaimer :*

  - Cette présentation n'est pas exhaustive
  - Je vais faire des approximations pour simplifier
  - Il y a certainement des personnes dans cette salle qui s'y connaissent mieux que moi

  C'est un sujet que je trouve assez sexy, je pourrais déjà faire une conférence d'une heure et demie mais je vais vous épargner ça. On va faire court, si vous avez des question n'hésitez pas à m'interrompre, et si vous voulez en parler c'est quand vous voulez, où vous voulez.
]

= History

#speaker-note[
  Parlons un peu d'histoire de l'informatique
]

== History

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _Help me!_

  _My prod is down!_

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Alexander, sysadmin_

    #set text(size: 18pt)
    _(Or maybe)_
  ])

  #speaker-note[
    « Merde ! Ma prod est cassée ! »

    Qu'est-ce que je fais ?

    - On *évalue* le *périmètre de la panne*, ce qui casse
    - On *détermine* les *conditions* dans lesquelles ça *arrive*
    - On *évalue* les *risques* possibles
    - On *détermine* le *coût* pour *corriger* : temps de debug, nouveau déploiement…

    Enfin, on *décide* de *l'action à prendre* et *quand.*

    *Différents scénarios:*
    Que se passe-t-il si elle est cassée…
  ]
]

#slide(composer: (1.2fr, 1fr))[

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

][
  #meanwhile

- Immediately after deployment

#pause

- 4 days after the last deployment

#pause

- After rolling back an older version

#pause

- _But it works on my machine_ #super[TM]

#pause

- _But it *doesn't* work *only* on my machine_ #super[#strike[TM]]

  #speaker-note[
    + Au déploiement:
      - facile, on tente de rollback hein ? Oui, mais si on avait changé de DB en même temps ?
    + 4j :
      - Est-ce que c'est vraiment lié au dernier déploiement ?
      - Une panne lente ?
      - Un changement _stateful_ ? 
    + Au rollback :
      - Un truc mal rollback ?
      - Un état persistant ?
    + It works on my machine:
      - Quoi ? C'est pas ISO prod ??
    + It *doesn't* work *only* on my machine:
      - Quoi ? C'est vraiment pas ISO prod ??
  ]
]

== From the ENIAC
 
#slide[
  #only("1")[
    #figure(image("assets/eniac.jpg", width: 70%))
  ]
  #only("2")[
    #figure(image("assets/eniac_panel.jpg", width: 70%))
  ]

  #speaker-note[
    Electronic Numerical Integrator And Computer - 1er ordi Turing complete

    *C'est quoi l'infra ?*

    Infrastructure :
    - _structure_ -> *relation* entre les *éléments* d'un système
    - _infra_ -> « _*sous*_ », ce qui supporte
    _infrastructure_ -> tout ce qui *supporte* un *système* (ex: -> fondations d'un bâtiment)

    Ici : infrastructure = bâtiment, l'ENIAC littéralement une pièce

    *NEXT*

    *Ma prod est en panne ?*

    On se déplace *physiquement*, on vérifie les *branchements*, on *documente* les *nouveaux branchements*, on *vérifie* les *entrées-sorties* (périphériques) sur *cartes perforées*, on vérifie la *configuration*…
  ]
]

== Rack Colocation

#slide(align: center)[
  #figure(image("assets/datacenter_rack.jpg", width: 70%))

  #speaker-note[
    *On premise*: on est responsable de notre serveur, de notre baie, de notre emplacement rack

    En collocation, on n'est plus responsable du bâtiment on loue un emplacement rack,

    Selon la panne, l'accès en terminal suffit ; si c'est matériel on a toujours besoin d'un accès physique pour vérifier.
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
    pause,

    node((-0.11, -0.91), [_Cluster_], fill: none, name: <Cluster>),
    node(enclose: (<Cluster>, <SRVA>, <SRVB>, <SRVC>), stroke: (paint: black, thickness: 1pt, dash: "loosely-dashed"), fill: black.transparentize(95%), snap: false),
  )

  #speaker-note[
    *Cas d'usage* :

    On veut une marketplace : on la déploie sur serveur dédié

    *NEXT*

    Elle tombe en panne : il faut prendre ses petites jambes, aller regarder ce qu'il se passe : en attendant le service est indispo.

    Solution ?

    *NEXT*

    On l'*installe* sur *plusieurs serveurs*

    Ça tombe en panne : on enquête, mais en attendant l'utilisateur peut toujours accéder à un autre serveur

    *NEXT*

    Notre marketplace tourne sur un Cluster de serveurs
  ]
])

== From physical servers to virtual machines

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  #place(top+right, figure(image("assets/bongocat.gif", width: 21%)))
  _Help me!_
  
  _I've had enough of installing the same servers again and again…_

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Alexander_
  ])

  #speaker-note[
    Et il a raison !

    C'est pratique le cluster, mais pour éviter les pannes et pas mettre tous les œufs dans le même panier il faut déployer dans  de régions en même temps (coupure courant, internet…)

    On prend soin de nos gambettes, on veut pas courir partout pour installer ni pour réparer

    On loue l'infra, on s'occupe du logiciel :
    *Infra-as-a-service* (le hardware est fournit, tu gères l'OS)
  ]
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

  #speaker-note[
    La même chose, sauf que les serveurs ne sont pas _dédiés_ à ma marketplace, à la place ils hébergent plusieurs *machines virtuelles*
    
    Parmi ces VM -> ma marketplace

    Utilisateur accède directement ma marketplace via la VM -> même chose qu'avant *SAUF QUE*

    Si VM 1 en panne, pas besoin d'accéder au datacenter, on peut la recréer, la réinitialiser ou la redéployer ailleurs sans avoir besoin d'aller sur place

    On appelle aussi ça un *VPS*

    ------

    Pourquoi je parle pas de SSH sur srv physique ? Parce qu'on parle d'infra (db, charges de travail,config réseau), pas JUSTE du système

    -- Oui mais et moi mon serveur dédié jamais eu besoin d'aller sur place -> le hardware a jamais lâché et eu besoin ticket ?
    -- Oui mais ça arrive jamais -> Si ça lâche une fois en 10 ans, il suffit d'avoir 10 serveurs pour qu'il y en ait 1 qui lâche par an, 100 serveurs et quasiment une panne tous les mois

    On peut citer VMware, VirtualBox, Xen, Proxmox…
  ]
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

  #speaker-note[
    Et si serveur physique en carafe ?

    Eh bien pas de downtime puisqu'on a toujours le quorum

    Sur la gestion de projet, concrètement ça veut dire qu'on gère des machines entières, qu'il faut maintenir, sécuriser, tester… et ça tourne pas sur un laptop de dev

    Ça veut dire déployer un OS entier…

    *MAIS* on peut trouver encore mieux
  ]
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

  #speaker-note[
    On reprend nos VM

    Il y a une notion de sobriété : au début on a du matériel dédié pour faire tourner mes serveurs de marketplace, alors je fais tourner mes serveurs _virtuels_ sur des machines physiques

    Mais ça veut dire faire tourner des systèmes d'exploitation plusieurs fois, devoir se balader avec un disque dur virtuel de centaines de GiO à upload pour déployer, etc.
    
    Comme si, pour aller au boulot tous les jours, on prenait toutes & tous notre bagnole, qu'on s'est dit que c'était pas pratique quand sa voiture tombe en panne alors on a un abonnement à une flotte de voitures en libre service : si elle tombe en panne, c'est le prestataire qui la répare, je me concentre uniquement sur ce qu'elle transporte.

    Sauf qu'il y aurait encore plus économique en mutualisant encore plus de ressources : au lieu de payer des voitures en libre-service, je peux me contenter de payer un abonnement de bus et de faire mes déplacements en bus.

    Au lieu d'héberger des applications dans des systèmes d'exploitation ou dans des machines virtuelles, on peut mettre nos applications dans des conteneurs plus légers et plus faciles à transporter
  ]
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

  #speaker-note[
    Container-as-a-service : on fournit le hardware et l'OS, tu gères le conteneur

    Du point de vue de l'appli, qu'elle soit sur un serveur dédié, sur une machine virtuelle, dans un conteneur… Rien ne change.

    Les 3 seules différences :

    - les ressources allouées et les ressources consommées
    - le niveau d'isolation (sécu)
    - le cycle de vie (quand ça démarre, ça met à jour…) et qui s'occupe de quoi
  ]
]

#slide[

  #place(top+right, figure(image("assets/bongocat_clap.gif", width: 8%)))
  A container is a server that is *lighter* and requires *fewer dedicated resources* than a virtual machine:

  #par[]

  - It is very fast to build and start up (in seconds)

  - It is easier to use (_It runs on my machine!_ #super[TM])

  - It _can_ be declarative

  #speaker-note[
    À partir 2012 avec le nouveau standard O.C.I apporté par Docker, on a commencé à voir deux paradigmes arriver avec les conteneurs : le Hub Docker (un dépôt avec plein d'images de conteneurs desquelles on peut dériver) et la syntaxe Dockerfile (un fichier qui décrit l'état désiré de l'image finale).
    
    J'y reviens après au sujet du déclaratif
  ]
]

== _Serverless_

#slide(align: left, self => [
  #place(top + right, dy: -10pt, dx: 10pt, figure(image("assets/bongocat_mouse.gif", width: 10%)))
  #v(65pt)

  We can rent a database (_DBaaS_) or a sandbox to run code (_FaaS_) without managing the OS or hardware: we move to *serverless*

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

  #speaker-note[
    C'est simplifié (dépend des produits) mais le type définit quel est le niveau qu'on commence à administrer : « on-prem, j'administre le réseau », « SaaS, j'*administre* l'appli mais c'est eux qui sont admins des données dessus » etc.

    - On Prem : j'achète et conduis ma voiture
    - IaaS - infra : je loue et conduis une voiture
    - CaaS - Container : j'ai un abonnement illimité de transport pour me déplacer
    - PaaS - Platform : je commande un taxi uniquement quand j'en ai besoin, je paie à l'usage
    - SaaS - Software : je délègue (je fais livrer)

    Si ça pète on-premise, je me déplace, si l'OS pète j'investigue en console, si le conteneur pète je debug le code, si la plateforme pète je vérivie la config de l'app, si le SaaS pète j'appelle le support

    En vrai :
    - il y a quand même un serveur, « serverless » est un terme marketing
    - le serveur est faillible, il y a des pannes, c'est juste un tiers qui s'en occupe
    - c'est quand même coûteux de déléguer
    - il y a des contraintes d'archi & avec le serverless ou SaaS on n'est pas toujours libre des cycles de release
    - le serveur est toujours déployé avant, il est juste pas dédié qu'à notre marketplace
  ]
])

= Infrastructure

== Imperative

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  As a sysadmin,

  _What do I want with my system?_

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Alexander_
  ])
  #place(top+right, [#v(6.7em)#figure(image("assets/bongowhat.gif", width: 13%))])
]
#slide[

#set list(marker: ([•], [--]))
#pause
  - Easy to setup #pause
  - Available and reliable#pause, even when…
    - I update dependencies #pause
    - hardware breaks #pause
    - I replace disks, upgrade RAM 💸, change CPU…

    #speaker-note[

    ]
]
#slide[
  In programming, the *imperative paradigm* is writing a sequence of instructions: *it's a cookbook*

  #pause

  #v(1em)

  To deploy an on-premise infrastructure, there is a whole series of processes to follow in order to acquire, install, start or maintain servers.
]

== Declarative

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  No… As a sysadmin,

  _What do I *really* want with my system?_
  #place(bottom+right, [
    #set text(size: 22pt)
    _— Alexander, again_
  ])
  #place(top+right, [#v(6.6em)#figure(image("assets/calicobongocat.gif", width: 17%))])
]
#slide[

  #set list(marker: ([•], [--]))
  #set text(fill: black.transparentize(70%))
  - Easy to setup
  - Available and reliable #pause
  #set text(fill: black)
  - Document properly:
    - _What_ is on it?
    - _How_ it's done
    - _Why_ in that way? #pause
  - Easily _changed_ and maintained #pause
  - Easily reviewed
]
#slide[
*Declarative programming* contrasts with the imperative paradigm.

#v(1em)

It means to describe a *final state* rather than the steps to reach it.
]

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 39pt)
  _It's like telling the chef:_ "I want a Mont d'Or".

  #h(0em)

  *_You don't give them the recipe,_*

  _It's up to them to buy the ingredients and to know and execute the recipe._
  #v(24pt)
  #place(top+left, [#v(7em)#figure(image("assets/montdor.png", width: 14%))])

  #place(bottom+right, [
    #set text(size: 22pt)
    #only("1")[
      _— Alexander, sysadmin_ 
    ]
    #only("2")[
      _— Luka_

      #set text(size: 18pt)
      _(Cheese dealer)_
    ]
  ])

  #speaker-note[
    Ça, c'est Alex qui l'a dit

    *NEXT*

    Non, en fait c'est moi :D
  ]
]

#slide[
  #pause
  #place(top+right, text(size: 70pt)[#v(35pt)📜])
  Many common languages are *declarative*: HTML, Markdown, SQL…

  #hline

  #set par(first-line-indent: 0em, hanging-indent: 0em)
  Yet, not all declarative languages can compute data: an HTML page cannot perform division calculations.

  #speaker-note[
    On parle d'infra, on parle de déclaratif, mais en fait on connais toutes et tous des langages déclaratifs

    Pour autant, tous les langages déclaratifs ne sont pas des langages de programmation.
  ]
]

#slide[
  Declarative and *Turing-complete* languages are numerous and more specialized:

  #h(0.3em)

  #pause

- *Haskell* or *OCaml* for functional programming

#pause

- *Prolog* or *Mercury* for logic programming

#pause

- *Terraform* (_HCL_) for infrastructure management

- *Typst* as a programming markup language ❤️ (LaTeΧ)
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

  #speaker-note[
    - On déclare : je veux construire un conteneur à partir de tel format (Dockerfile)
    - Je donne l'ordre : je veux que mon conteneur tourne
    - Docker dit : je réalise toutes ces étapes
  ]
]

#focus-slide(align: top, config: config-page(fill: white, margin: 0em))[
  #box(figure(image("assets/rickroll.gif", width: 100%)), clip: true, inset: (bottom: -59%))
]

#slide[
  ```bash
  cd $(mktemp -d)
  git clone "https://github.com/modem7/docker-rickroll"
  cd docker-rickroll/
  ```
  #set text(weight: 900)
  ```bash
  docker build -t my_image .
  ```
  #pause
  ```bash
  docker build -t my_image .
  ```
  #pause
  ```bash
  docker build -t my_image .
  ```
  #set text(weight: 500)
  ```bash
  docker run -p 8080:8080 my_image
  ```

  #h(0em)

  The *`docker build`* command has no extra effect if called again; it is *idempotent*.

  An action is *idempotent* when it has the same effect, whether called once or repeated.

  #speaker-note[
    - Si on relance plusieurs fois `docker build`, ça existe déjà et ça fait rien de plus : on parle d'IDEMPOTENCE (ex: cliquer sur un bouton pour valider le panier)

    Il faut comprendre que derrière toute étape déclarative se cachent des opérations impératives. C'est une question de responsabilités.

  ]
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

  #speaker-note[
    Exemple avec NPM:
      - `npm install [pkg]` -> impératif
      - le `package.json` déclare la dépendance
      - `npm install` installe à partir de la déclaration

      OUI MAIS et les màjs automatiques ?
  ]
]

== Declarative and Reproducible

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _No!_

  _You really don't get it!_

  #h(0em)

  _I know I can get more,_

  _so give me more._

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Alexander… again_ 
  ])

  #place(top+right, [#v(-0.1em)#figure(image("assets/bongorage.gif", width: 16%))#h(7em)])
]
#slide[

  #set list(marker: ([•], [--]))
  #set text(fill: black.transparentize(70%))
  - Easy to setup
  - Available and reliable
  - Document properly
  - Easy to _change_ and maintain
  - Easy to review #pause
  #set text(fill: black)
  - Easy to reproduce #pause
  - Prevent undeclared changes #pause
  - Allow changes from non-sysadmins
]
#slide[
  Sometimes, we want our declarative code to be strictly *reproducible*:

  === The same code has _*exactly*_ the same results.

  #speaker-note[Les mêmes causes produisent les mêmes effets]
]
#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  Same causes, same effects.

  #speaker-note[Les mêmes causes produisent les mêmes effets]
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

#slide(title: "Other container managers")[
  There are other declarative tools for deploying and orchestrating containers:
  #pause

  - *`docker compose`* is the declarative alternative to `docker run`  
  #pause  
  - *`kubernetes`* for orchestrating containers across clusters
  #pause  
  - etc.

  #speaker-note[
    Docker compose…

    Kubernetes permet d'orchestrer des conteneurs (et d'autres ressources) sur un cluster
  ]
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

  #speaker-note[
    pour revenir à notre infra
  ]
]

// N'est PAS reproductible _stricto sensus_
#slide[
  *Terraform* allows you to declare and deploy infrastructure from code using the _ad hoc_ *HCL* language:

  #pause
  #v(12pt)

  #text(24pt)[*`-- main.tf`*]
  
  #only("2")[
    ```hcl

    resource "aws_instance" "my_server" {
      ami           = "my-ami-id"
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



#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _I'm done with this presentation._

  #h(0em)

  _I'm a developer,_

  _How does that even affect me?_
  #place(top+right, [#v(2.65em)#block(
    clip: true,
    radius: 14pt,
    figure(image("assets/hackerbongocat.gif", width: 14%))
  )])

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Roger_
  ])

  #speaker-note[
    Monsieur Roger, dev, pas hyper intéressé par l'ops, peut quand même profiter du déclaratif
  ]
]

= Toolchains

== We all know declarative

#slide[
  We already know about mainstream declarative languages like *HTML* & *CSS*

  #v(1em)

  Some of them might suit a narrower audience.
]

== Declarative Toolchain

#slide(align: top)[
  #only("6-")[
    #place(top+right, figure(image("assets/nixos.svg", width: 14%)))
  ]
  #v(1.5em)
  === Per project

  Multiple projects should be able to use independent software and versions without conflicting with each other:

  #pause

  - Building from source#pause
  - Using language-specific package managers (`npm`, `pip`, …)#pause
  - In fact, *_Mise_* a ‘front-end’ to install any package manager's package…#pause
  - …and does support a `mise.toml` file to enable them _declaratively_#pause
  - Docker through conteneurs
  - `devenv`, `direnv` or plain `.envrc`#pause
  - `nix`, a declarative _and reproductible_ package manager

  #speaker-note[
    Je voulais parler d'outillage propre au développement : par projet, ça permet de garder un système propre et d'avoir des logiciels, versions de logiciels, … indépendants à chaque répertoire

    - Compiler depuis les sources : le binaire est construit à partir de fichiers qui déclarent du code
    - Les gestionnaires de packet propres aux langages (`./node_modules`)
    - Mise, qui permet d'utiliser de faire ce qu'on vient de dire mais pour tous les package managers sans les installer
    - Docker, en conteneurs
    - devenv, direnv, .envrc, qui permettent de définir un contexte en entrant dans un répertoire
    - Nix, qui est à la fois un langage de programmation (turing-complete), déclaratif, et fortement reproductible (toutes les entrées sont signées)

    En fait, Nix est même le plus grand package manager au monde, parmi les dépôts Github les plus actifs, et avec les batteries de tests les plus solides. Nix permet aussi de charger des logiciels de n'importe quel système en entrant dans un répertoire
  ]
]

#slide(align: top)[
  #only("4-")[
    #place(top+right, figure(image("assets/nixos.svg", width: 14%)))
  ]
  #v(1.5em)
  === Per user

  Multiple non-admin *users* should be able to use independent software and versions without conflicting with each other:

  #pause

  - Global (user) npm installs#pause
  - Global (user) Docker installs#pause
  - …Nix again
]
#slide(align: top)[
  #place(top+right, figure(image("assets/nixos.svg", width: 14%)))
  #v(1.5em)
  === Per Operating System?

  Have you heard about Nix already?#pause

  NixOS is a fully-declarative and reproductible operating system.

  *The whole system fits in a Git repository*, just reapply anytime to deploy it.
]

#focus-slide(align: center)[
  #set text(font: "libertinus serif", size: 48pt)
  _I'm not even a tech person…_

  #h(0em)

  _Why should I care about all of this?_
  #place(top+right, [#v(3em)#figure(image("assets/bongopat.gif", width: 14%))])

  #place(bottom+right, [
    #set text(size: 22pt)
    _— Nick O._ 
  ])
]

= Projects

== Project lifecycle

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

    edge((-0.3, -1), (4.4, 1.5), stroke: (paint: white.transparentize(100%), thickness: 4pt)),
    edge((-0.3, 1.5), (4.4, -1), stroke: (paint: white.transparentize(100%), thickness: 4pt)),
  )

  #set align(left)

  #meanwhile
  #columns(5, gutter: 8pt)[
    #colbreak()
    #colbreak()
  ]

  #speaker-note[
    - on veut éviter sillo *dev* / sysadmin
    - on veut que les devs contrôlent mieux l'env final
    - dev plus iso prod possible = good

    1. originellement, dev -> cahier des charges -> ops => source d'erreur
    2. ensuite, environnements devs locaux + en + proches
    3. idéal : les devs gèrent les environnements et leurs specs eux-mêmes au plus proche du code

    Que se passe-t-il quand on se rend compte que les spec machine ne suivent pas ? On refait potentiellement toute la boucle
    (c'est un cycle en v simplifié le schéma)

    Est-ce qu'on pourrait pas simplifier les intermédiaires ?
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
  #set align(left)
  #set par(spacing: 0em, leading: 0.6em)
  #fletcher-diagram(
    node-stroke: .05em,
    node-inset: 10.6pt,
    node-fill: gradient.radial(blue.lighten(80%), blue, center: (30%, 20%), radius: 80%),
    spacing: 2.7em,

    // FRAME 1

    node((0, 0), [Business], radius: 2.8em, name: <biz>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<biz>, <lead>, "-|>", align(center)[Ask for\ features], bend: 53deg, stroke: black.transparentize(10%)),

    node((1, 0), [Leads], radius: 2.8em, name: <lead>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<lead>, <dev>, "-|>", align(center)[Discuss\ architecture], bend: 53deg, stroke: black.transparentize(10%)),

    node((2, 0), [Devs], radius: 2.8em, name: <dev>, fill: gradient.radial(blue.lighten(99.9%), blue.lighten(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    pause,

    node((2.7, 1), [Ops], radius: 2.8em, name: <ops>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), blue.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    pause,
    node((3.5, 0), [Datacenter], radius: 2.8em, name: <dc>, fill: gradient.radial(blue.lighten(80%).transparentize(80%), green.transparentize(80%), center: (30%, 20%), radius: 80%), stroke: black.transparentize(80%)),
    edge(<ops>, <dc>, "-|>", label-pos: 10%, align(left)[#highlight[Prepare and maintain\ infra]], bend: -30deg, stroke: black.transparentize(10%)),
    pause,

    edge(<dev>, <dc>, "-|>", align(center)[#highlight[Deploy resources]], bend: 45deg, stroke: black.transparentize(10%)),
    pause,
    edge(<dc>, <dev>, "<..>", align(center)[#highlight[System tests]], bend: -12deg, stroke: black.transparentize(10%)),
    pause,
    edge(<lead>, <dc>, "<..>", align(center)[], bend: -34deg, stroke: black.transparentize(10%)),
    edge(<dev>, <dc>, "<..>", align(center)[#highlight[Infra reviews]], bend: -34deg, stroke: black.transparentize(10%)),
    pause,
    node(enclose: (<biz>, <dc>), shape: brace.with(dir: right, length: 100% + 2em, size: 1.5em, sep: -0.4em)),
    edge(<dev>, <biz>, "-", rotate(-90deg)[#align(center)[#highlight[End-to-end tests\ Feature environments]]], label-pos: -18.9em, label-sep: -1.6em, stroke: black.transparentize(100%), ),
    pause,
  )

  #pause

  #place(bottom+left)[
  #set text(font: "libertinus serif", size: 48pt)
    _✨ DevOps ✨_
    #v(0.6em)
  ]
]

== Risk Management

#slide[
  === Business Continuity & Business Recovery Plans…

  === Infrastructure Deployments Management…
]

== Software reliability

#slide[
  === DORA Metrics:
  #box(figure(image("assets/dora.png", width: 100%)), clip: true)
]

#focus-slide(align: top, config: config-page(fill: white, margin: 0em))[
  #figure(image("assets/thats all folks.svg", width: 101%))
  #place(bottom+right, figure(image("assets/bongolove.png", width: 10%)))
]

#show: appendix
