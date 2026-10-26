// N-Pulse document style: page layout, header/footer, title block, accents.

// ================================================================
// 1. Constants
// ================================================================
#let config = toml("/config.toml")
#let accent = rgb(config.team.accent)

// ================================================================
// 2. Functions
// ================================================================

// ──────────────────────────────────────────────────────
// 2.1 Subsection: Helper Functions (Typst needs them defined first)
// ──────────────────────────────────────────────────────
#let _title-block(title, subteam) = {
  block(width: 100%, inset: (bottom: 12pt), stroke: (bottom: 2pt + accent), {
    text(size: 10pt, fill: accent, weight: "bold", upper(subteam))
    v(0.2em)
    text(size: 22pt, weight: "bold", title)
    v(0.1em)
    text(size: 9pt, fill: luma(110), datetime.today().display("[day] [month repr:long] [year]"))
  })
  v(1em)
}

/// Applies the N-Pulse style to `body`.
/// `title` and `subteam` fill the title block and {placeholders} in config.
#let npulse(title: "", subteam: "", body) = {
  let doc = config.document
  set document(title: title, author: config.team.name)
  set text(font: doc.font, size: eval(doc.font-size), lang: doc.lang)
  set par(justify: true)
  set heading(numbering: "1.1")
  show link: set text(fill: accent)
  show heading: set text(fill: accent)
  show heading.where(level: 1): it => block(above: 1.6em, below: 1em, {
    it
    v(-0.6em)
    line(length: 100%, stroke: 0.6pt + accent)
  })
  show raw.where(block: true): block.with(
    fill: accent.lighten(92%), inset: 8pt, radius: 3pt, width: 100%,
  )
  show quote.where(block: true): block.with(
    stroke: (left: 2pt + accent), inset: (left: 10pt, y: 4pt),
  )
  set table(stroke: 0.5pt + accent.lighten(40%))
  show table.cell.where(y: 0): set text(weight: "bold")

  let fill(s) = s.replace("{title}", title).replace("{subteam}", subteam)
  set page(
    paper: doc.paper,
    margin: (x: 2.2cm, top: 2.8cm, bottom: 2.5cm),
    header: {
      set text(size: 9pt, fill: accent)
      grid(
        columns: (1fr, 1fr),
        fill(config.header.left), align(right, fill(config.header.right)),
      )
      v(-0.4em)
      line(length: 100%, stroke: 0.4pt + accent)
    },
    footer: context {
      set text(size: 9pt, fill: luma(90))
      grid(
        columns: (1fr, 1fr, 1fr),
        fill(config.footer.left),
        align(center, fill(config.footer.center)),
        align(right, counter(page).display("1 / 1", both: true)),
      )
    },
  )

  _title-block(title, subteam)
  body
}
