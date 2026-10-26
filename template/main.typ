// Entry point: renders one Markdown file (given via --input) with the N-Pulse style.

// ================================================================
// 0. IMPORTS
// ================================================================
#import "@preview/cmarker:0.1.6"
#import "npulse.typ": npulse

// ================================================================
// 1. Constants
// ================================================================
// Paths come from the build scripts, relative to the repo root.
#let src = sys.inputs.at("src")
#let src-dir = src.split("/").slice(0, -1).join("/")
#let file-name = src.split("/").last().replace(".md", "")
#let meta-pair = regex("^\*\*(.+?):\*\*\s*(.*)$")

// ================================================================
// 2. Functions
// ================================================================
// ──────────────────────────────────────────────────────
// 2.1 Subsection: Helper Functions (Typst needs them defined first)
// ──────────────────────────────────────────────────────

/// Splits a leading `> **Key:** value` block off the Markdown.
/// Returns (pairs, rest). A leading quote that isn't all key/value is kept.
#let split-meta(md) = {
  let lines = md.split("\n")
  let pairs = ()
  let i = 0
  while i < lines.len() and lines.at(i).starts-with(">") {
    for part in lines.at(i).trim(">", at: start).split(" · ") {
      let m = part.trim().match(meta-pair)
      if m == none { return ((), md) }
      pairs.push((m.captures.at(0), m.captures.at(1).replace("`", "").trim()))
    }
    i += 1
  }
  // Drop blank lines and the `---` rule that usually closes the block.
  while i < lines.len() and lines.at(i).trim() in ("", "---") { i += 1 }
  (pairs, lines.slice(i).join("\n"))
}

/// Heading lines outside code fences, as (level, text) pairs.
#let headings(md) = {
  let in-code = false
  let found = ()
  for line in md.split("\n") {
    if line.starts-with("```") { in-code = not in-code }
    let m = line.match(regex("^(#+)\s+(.*)$"))
    if not in-code and m != none {
      found.push((m.captures.at(0).len(), m.captures.at(1)))
    }
  }
  found
}

// ================================================================
// 3. Document
// ================================================================
#let (meta, body) = split-meta(read("/" + src))
#let found = headings(body)
#let top-level = calc.min(..found.map(h => h.at(0)), 9)
#let meta-title = meta.find(((k, _)) => k == "Project")

#show: npulse.with(
  // Title fallback order: build command, "Project" metadata, file name.
  title: if sys.inputs.at("title", default: "") != "" { sys.inputs.title } else if meta-title != none { meta-title.at(1) } else { file-name },
  subteam: sys.inputs.at("subteam", default: ""),
  meta: meta.filter(((k, _)) => k != "Project"),
  // Files that write "1. Introduction" themselves shouldn't get a second number.
  numbered: not found.any(h => h.at(1).match(regex("^\d")) != none),
)

#cmarker.render(
  body,
  // Shift levels so the file's biggest heading becomes a top-level section.
  h1-level: 2 - top-level,
  // Image paths in Markdown are relative to the .md file, not this template.
  scope: (image: (path, alt: none) => image("/" + src-dir + "/" + path, alt: alt)),
)
