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

// ================================================================
// 2. Document
// ================================================================
#show: npulse.with(
  title: sys.inputs.at("title", default: file-name),
  subteam: sys.inputs.at("subteam", default: ""),
)

#cmarker.render(
  read("/" + src),
  // Image paths in Markdown are relative to the .md file, not this template.
  scope: (image: (path, alt: none) => image("/" + src-dir + "/" + path, alt: alt)),
)
