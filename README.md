This is a pandoc filter designed to be used with [Pandoc Typst PDF (`ptp`)](https://github.com/cskeeters/ptp) that enables markdown text `+tbl:people` to be replaced by "Table N" with a cross reference to the table's caption.  i.e.

```markdown
---
title: Table Cross Reference Test
author: Chad Skeeters
filters:
  - pandoc-table-figure/0.1.0/figure.lua
---

| First | Last     |
|-------|----------|
| John  | Doe      |

Table:  People I know {#tbl:people}

See the people I know in +tbl:people.
```

# Usage

```sh
ptp test.md
```

## Manual

If you are not using `ptp`, you can run the filter with:

```sh
pandoc -L pandoc-table-figure/0.1.0/table-figure.lua doc.md -o doc.typ
typst compile doc.typ
```

# Installation

```
mkdir -p ~/.pandoc/filters/pandoc-table-fitler
cd ~/.pandoc/filters/pandoc-table-fitler
git clone https://github.com/cskeeters/pandoc-table-figure 0.1.0
cd 0.1.0
git switch --detach v0.1.0
```
