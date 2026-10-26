# N-Pulse Markdown → PDF

Turns the subteams' Markdown documentation into PDFs with the EPFL N-Pulse look (accent `#46A999`, team header, page-numbered footer). It uses [Typst](https://typst.app), a single small program, so there's no LaTeX, Python or Node to install. Works on macOS, Windows and Linux.

## 1. Setup (once per computer)

### 1.1 Install Typst

**macOS**, with [Homebrew](https://brew.sh):

```bash
brew install typst
```

**Windows**, in PowerShell:

```powershell
winget install --id Typst.Typst
```

Close and reopen the terminal afterwards, then check it worked:

```bash
typst --version
```

You need version 0.13 or newer. If `winget` is unavailable, download the `.zip` from the [Typst releases page](https://github.com/typst/typst/releases), extract `typst.exe` and add its folder to your `PATH`.

### 1.2 Get this repository

```bash
git clone <repo-url>
cd md-converter
```

### 1.3 Windows only: allow the build script

PowerShell blocks local scripts by default. Run this once:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

The first build needs internet: Typst downloads the Markdown package (`cmarker`) once and caches it.

## 2. Converting a file

1. Put your `.md` file in `docs/` (images next to it, or in a subfolder).
2. Run the script for your system.

**macOS / Linux:**

```bash
./build.sh docs/SDR.md "Decoding Team" "Design Solution Definition: EMG Decoding Pipeline"
```

**Windows (PowerShell):**

```powershell
.\build.ps1 docs/SDR.md "Decoding Team" "Design Solution Definition: EMG Decoding Pipeline"
```

Arguments: the Markdown file, then the **subteam** name, then the **title**. Subteam and title are optional (title defaults to the file name). The PDF lands in `output/` with the same name as the `.md` file.

## 3. Writing rules

- The title is added automatically from the command, so **don't start the file with your own title**.
- Use `#` for sections and `##` for sub-sections. They're numbered automatically (1, 1.1, …). If your headings already carry their own numbers (`## 1. Introduction`), automatic numbering is switched off. If the biggest heading in the file is `##`, it's treated as a top-level section.
- Supported: bold, italics, links, lists, tables, quotes, code blocks with syntax highlighting, images.
- Image paths are relative to the `.md` file, e.g. `![Board](img/board.png)`.
- See [docs/example.md](docs/example.md) for a sample.

### Metadata block

If the file starts with a quote made of `**Key:** value` lines, it's shown as a card under the title instead of as a quote. To put several pairs on one line, separate them with ` · `. A `Project` entry becomes the title when the build command doesn't give one, and a `---` right after the block is dropped.

```markdown
> **Project:** EMG Decoder V2
> **Version:** `0.1.0` · **Status:** `Draft`

---
```

## 4. Customizing

Everything team-wide lives in [config.toml](config.toml), and no Typst knowledge is needed:

| Setting | What it does |
|---|---|
| `team.accent` | Accent color (headings, lines, links) |
| `header.left` / `header.right` | Text at the top of every page |
| `footer.left` / `footer.center` | Text at the bottom (page number is always on the right) |
| `document.font`, `font-size`, `paper`, `lang` | Body text and page format |

In header/footer text, `{subteam}` and `{title}` are replaced with the values from the build command. Use `""` to leave a slot empty.

If a font in `config.toml` isn't installed on a machine, Typst falls back to a built-in font and prints a warning. The PDF still builds.

## 5. How it works

```
config.toml            team-wide settings (colors, header, footer)
template/main.typ      entry point: reads the .md and applies the style
template/npulse.typ    the style itself (page, header, footer, title block)
build.sh / build.ps1   wrappers that call `typst compile` with the right inputs
docs/                  Markdown sources
output/                generated PDFs (git-ignored)
```

The scripts run `typst compile --root .` with the Markdown path, subteam and title passed as `--input` values. `main.typ` renders the Markdown with the [cmarker](https://typst.app/universe/package/cmarker) package. Paths are given relative to the repo root because Typst can only read files inside `--root`, which is why your `.md` files must live inside this folder.
