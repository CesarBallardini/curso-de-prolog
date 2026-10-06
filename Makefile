# Makefile of the Prolog course.
#
# Meant to be run from Git Bash (MINGW64). `make` on its own lists what can be
# done.
#
# All the Python tooling lives in .venv, declared in pyproject.toml, and runs
# through `uv run --frozen`: the version that runs is exactly the one in
# uv.lock, the same one CI runs. On top of that it needs SWI-Prolog 9 (`swipl`)
# on the PATH, which is what loads and tests the examples. Version 10 changed
# clause indexing, and with it the choice points the transcripts of part I
# show, so `make transcripts` fails against it.

.DEFAULT_GOAL := help

UV := uv run --frozen

# A chapter is a directory under docs/ with its index.md and its soluciones.md.
# Each one gives a PDF named after the directory, and .gitignore keeps both out
# of the repository.
CAPITULOS := $(sort $(wildcard docs/capitulo-*) $(wildcard docs/apendice-*))
PDFS_CAP  := $(foreach d,$(CAPITULOS),$(d)/$(notdir $(d)).pdf)
# Only for the chapters that actually have a solutions page.
PDFS_SOL  := $(foreach d,$(wildcard docs/*/soluciones.md),$(dir $(d))$(notdir $(patsubst %/,%,$(dir $(d))))-soluciones.pdf)
PDFS      := $(PDFS_CAP) $(PDFS_SOL)

# Janus embeds the machine's SWI-Prolog and on Windows needs to be told where it
# is. When it does not come from the environment, ask swipl itself.
SWI_HOME_DIR ?= $(shell swipl --dump-runtime-variables 2>/dev/null | sed -n 's/^PLBASE="\(.*\)";/\1/p')

.PHONY: help install browser test swish part-1 transcripts math time sync sql appendix windows \
        docs docs-serve mermaid pdf pldoc clean-pldoc slides slides-pdf slides-check video lint format check clean clean-pdf

help: ## List the available targets
	@echo "Curso de Prolog"
	@echo ""
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  make %-12s %s\n", $$1, $$2}'
	@echo ""

## --- Environment -----------------------------------------------------------

install: ## Build .venv from uv.lock and install the git hooks
	uv sync --frozen
	$(UV) pre-commit install

browser: ## Fetch the headless Chromium the PDFs need
	$(UV) playwright install chromium

## --- Examples --------------------------------------------------------------

test: ## Run the plunit tests of every example (just one: make test e=familia)
	$(UV) tools/run-examples.py $(e)

swish: ## Check against library(sandbox) that every example can run in SWISH
	$(UV) tools/check-swish.py $(e)

part-1: ## Check that chapters 1 to 12 use nothing from part II
	$(UV) tools/check-part-1.py

part-2: ## Check that part II uses no predicate before the chapter that presents it
	$(UV) tools/check-part-2.py $(e)

shown: ## Check that every predicate a transcript consults is shown on its page
	$(UV) tools/check-shown.py $(e)

links: ## Check that every chapter, section and pattern mention in the prose is a link
	$(UV) tools/check-links.py $(e)

patterns: ## Check that docs/patrones.md equals the Patrón boxes (make patterns w=1 rewrites it)
	$(UV) tools/sync-patterns.py $(if $(w),--write,)

transcripts: ## Run every transcript of the book against swipl and compare the answers
	$(UV) tools/check-transcripts.py $(e)

math: ## Parse every formula of the book with KaTeX and report the ones it rejects
	$(UV) tools/check-math.py $(e)

time: ## Recompute every chapter time estimate and report the ones that drifted
	$(UV) tools/check-time.py $(e)

sync: ## Copy into the text the code blocks that declare they come from ejemplos/
	$(UV) tools/sync-examples.py --write

sql: ## Run the SQL/Prolog pairs of chapter 42 and compare the results
	$(UV) references/ejercicios/sql-prolog/verificar.py

# Each recipe line is its own shell, so the guard and the command have to be one
# line: an `exit 0` on the line above would only leave that shell, and pytest
# would run anyway against a directory that is not there.
appendix: ## Run the pytest suites of chapters 29 (Janus), 30, 31 (the Python clients) and 36 (web pages, Playwright)
	@if [ -d ejemplos/capitulo-29 ]; then \
	  SWI_HOME_DIR="$(SWI_HOME_DIR)" $(UV) --group apendice-a pytest ejemplos/capitulo-29; \
	else \
	  echo "There is no ejemplos/capitulo-29 yet: nothing to test."; \
	fi
	@# Chapter 30 runs in its own pytest process: its tests start Prolog servers
	@# as programs, and share nothing with the Prolog that Janus embeds in 29.
	@if [ -d ejemplos/capitulo-30 ]; then \
	  SWI_HOME_DIR="$(SWI_HOME_DIR)" $(UV) --group apendice-a pytest ejemplos/capitulo-30; \
	fi
	@if [ -d ejemplos/capitulo-31 ]; then \
	  SWI_HOME_DIR="$(SWI_HOME_DIR)" $(UV) --group apendice-a pytest ejemplos/capitulo-31; \
	fi
	@# Chapter 36 opens its web pages in headless Chromium, through Playwright.
	@if [ -d ejemplos/capitulo-36 ]; then \
	  SWI_HOME_DIR="$(SWI_HOME_DIR)" $(UV) --group apendice-a pytest ejemplos/capitulo-36; \
	fi

# swipl-win has no output a shell can read, and CI has no XPCE: this target is
# local only, and `make check` does not call it.
windows: ## Run the XPCE window tests under swipl-win (local only; CI has no XPCE)
	$(UV) tools/run-windows.py $(e)

## --- The book --------------------------------------------------------------

# PlDoc sites: the HTML documentation that PlDoc generates from the %! headers of
# some chapters' examples, which the chapter links to (section 14.7 shows what
# PlDoc produces). Generated from the example files, like the PDFs, and not
# versioned. A chapter opts in with one line: its number in PLDOC_CAPITULOS and
# its files in PLDOC_SRC_<number>; the pages go to docs/<chapter>/pldoc/.
PLDOC_CAPITULOS := 14
PLDOC_SRC_14    := estilo.pl encabezados.pl inscripciones.pl

pldoc_dir = $(firstword $(wildcard docs/capitulo-$(1)-*))/pldoc
PLDOC_DIRS := $(foreach n,$(PLDOC_CAPITULOS),$(call pldoc_dir,$(n)))
PLDOC      := $(addsuffix /index.html,$(PLDOC_DIRS))

# The PlDoc pages first: chapter 14 links to them, and the strict build fails on
# a link to a file that is not there. The PDFs are `make pdf`'s job: the
# tools/pdf_links.py hook leaves the links of docs/pdf.md to the ones that
# exist, so run `make pdf` before this for a site that carries them.
docs: $(PLDOC) ## Build the site into site/ (a warning is an error; no PDFs, see make pdf)
	$(UV) mkdocs build --strict

# Needs the network: Material fetches mermaid from its CDN, as a reader's browser does.
mermaid: docs ## Build the site and draw every mermaid diagram in Chromium (one chapter: make mermaid e=capitulo-05)
	$(UV) tools/check-mermaid.py $(e)

docs-serve: ## Serve the site locally with live reload
	$(UV) mkdocs serve --dev-addr $(DIRECCION)

DIRECCION ?= 0.0.0.0:8000

# e= keeps the PDFs of the chapters named, full two-digit names: CI builds only
# those of the chapters a pull request touches.
pdf: $(if $(e),$(filter $(patsubst %,docs/%-%,$(e)),$(PDFS)),$(PDFS)) ## Build the PDF of every chapter (only the ones that changed; some: make pdf e="capitulo-05 capitulo-07")

# The PDF machinery, which every page rebuild depends on.
PDF_DEPS := tools/md2pdf.py tools/pdf-style.css tools/katex_pdf.py tools/swish_links.py tools/examples.py

# A chapter's PDF also carries the pages the nav lists after «Soluciones»;
# tools/md2pdf.py takes them from mkdocs.yml, and so does this list, so a new
# page is picked up with no further edit. The images of the folder go inside
# the PDF too.
PAGINAS_NAV := $(shell sed -n 's|.*[ "]\(capitulo-[^ "]*/[^ /"]*\.md\)"\{0,1\}[[:space:]]*$$|docs/\1|p' mkdocs.yml)
pdf_paginas  = $(filter-out $(1)/index.md $(1)/soluciones.md,$(filter $(1)/%,$(PAGINAS_NAV)))
pdf_imagenes = $(wildcard $(addprefix $(1)/*.,svg png jpg jpeg gif))

define REGLA_PDF
$(1)/$(notdir $(1)).pdf: $(1)/index.md $(call pdf_paginas,$(1)) $(call pdf_imagenes,$(1)) $$(PDF_DEPS)
	$$(UV) tools/md2pdf.py $$< -o $$@

$(1)/$(notdir $(1))-soluciones.pdf: $(1)/soluciones.md $(call pdf_imagenes,$(1)) $$(PDF_DEPS)
	$$(UV) tools/md2pdf.py $$< -o $$@
endef
$(foreach d,$(CAPITULOS),$(eval $(call REGLA_PDF,$(d))))

define REGLA_PLDOC
$(call pldoc_dir,$(1))/index.html: $(addprefix ejemplos/capitulo-$(1)/,$(PLDOC_SRC_$(1))) tools/pldoc-html.pl
	rm -rf $(call pldoc_dir,$(1))/*
	cd ejemplos/capitulo-$(1) && swipl ../../tools/pldoc-html.pl $(CURDIR)/$(call pldoc_dir,$(1)) $(PLDOC_SRC_$(1))
endef
$(foreach n,$(PLDOC_CAPITULOS),$(eval $(call REGLA_PLDOC,$(n))))

pldoc: clean-pldoc ## Recreate every PlDoc site from the examples (docs/*/pldoc/)
	$(MAKE) $(PLDOC)

# The contents and not the directory: on Windows a directory that mkdocs serve
# is watching cannot be removed ("Device or resource busy").
clean-pldoc: ## Remove the generated PlDoc sites
	rm -rf $(addsuffix /*,$(PLDOC_DIRS))

## --- Slides --------------------------------------------------------------

# One deck per diapositivas/capitulo-NN.md, written in Pandoc Markdown. Pandoc
# writes PowerPoint but not Impress, so the .pptx is an intermediate step in a
# scratch directory and LibreOffice turns it into the .odp that is committed.
# The styles come from diapositivas/plantilla.pptx, which tools/slides-template.py
# builds from pandoc's default reference document. CI has no LibreOffice, so
# `make check` does not build the slides; it does check their code blocks and
# transcripts, like the text's.
SLIDES_MD  := $(wildcard diapositivas/capitulo-*.md)
SLIDES_ODP := $(SLIDES_MD:.md=.odp)
SLIDES_IMG := $(wildcard diapositivas/imagenes/*/*)

# LibreOffice is rarely on the PATH on Windows; its usual place is the default.
ifeq ($(OS),Windows_NT)
SOFFICE ?= $(or $(shell command -v soffice 2>/dev/null),/c/Program Files/LibreOffice/program/soffice.exe)
else
SOFFICE ?= soffice
endif

slides: $(SLIDES_ODP) ## Build the slides of every chapter (diapositivas/capitulo-NN.odp; needs pandoc and LibreOffice)

diapositivas/plantilla.pptx: tools/slides-template.py
	$(UV) tools/slides-template.py

# Pandoc: a slide per `##`, whatever the file's first heading is, and an image
# alone in a paragraph stays an image (its text is the description the slide
# carries) instead of becoming a figure with a caption under it. Pandoc writes a
# block it does not highlight (```text) with literal line feeds, which
# LibreOffice would turn into one paragraph per line; tools/slides-breaks.py
# makes them line breaks, as in highlighted code.
#
# LibreOffice runs with a profile of its own in the scratch directory: with the
# user's profile, a LibreOffice window already open swallows the conversion and
# the command ends without writing anything. A profile that is being created
# can also end the first run without output, so the conversion gets a second
# try. cygpath gives the file:/// URL the Windows build needs; elsewhere the
# plain path is already right.
diapositivas/%.odp: diapositivas/%.md diapositivas/plantilla.pptx tools/slides-breaks.py $(SLIDES_IMG)
	@tmp=$$(mktemp -d) && \
	url=$$(cygpath -m "$$tmp" 2>/dev/null || echo "$$tmp") && \
	pandoc $< --from=markdown-implicit_figures --slide-level=2 --resource-path=diapositivas \
	  --reference-doc=diapositivas/plantilla.pptx -o "$$tmp/$*.pptx" && \
	$(UV) tools/slides-breaks.py "$$tmp/$*.pptx" && \
	rm -f $@ && \
	for try in 1 2; do \
	  "$(SOFFICE)" -env:UserInstallation=file:///$${url#/}/perfil --headless \
	    --convert-to odp --outdir diapositivas "$$tmp/$*.pptx"; \
	  test -f $@ && break; \
	done; \
	rm -rf "$${tmp:?}"; \
	test -f $@ || { echo "LibreOffice did not write $@"; exit 1; }

# A PDF of each deck, exported from its .odp, so it follows every change of the
# deck (and, through the .odp, of its source). Same private profile and second
# try as the .odp.
SLIDES_PDF := $(SLIDES_MD:.md=.pdf)

slides-pdf: $(SLIDES_PDF) ## Export every deck to PDF (diapositivas/capitulo-NN.pdf), rebuilding the .odp first if needed

slides-check: ## Check that each deck's .odp and .pdf match its source, and the decks' transcripts
	$(UV) tools/check-slides.py $(e)
	$(UV) tools/check-transcripts.py --slides $(e)

diapositivas/%.pdf: diapositivas/%.odp
	@tmp=$$(mktemp -d) && \
	url=$$(cygpath -m "$$tmp" 2>/dev/null || echo "$$tmp") && \
	rm -f $@ && \
	for try in 1 2; do \
	  "$(SOFFICE)" -env:UserInstallation=file:///$${url#/}/perfil --headless \
	    --convert-to pdf --outdir diapositivas $<; \
	  test -f $@ && break; \
	done; \
	rm -rf "$${tmp:?}"; \
	test -f $@ || { echo "LibreOffice did not write $@"; exit 1; }

## --- Video -----------------------------------------------------------------

# A narrated video per deck: every slide on screen while a Piper voice reads its
# notes; tools/video.py documents the pipeline and the timing. It needs
# LibreOffice, ffmpeg and, the first time, the download of the voice model, so
# neither CI nor `make check` builds it, and the .mp4 is not versioned.
# tools/video.py is a PEP 723 script with its own dependencies: plain `uv run`,
# because --frozen asks for a lockfile the script does not have.
VIDEOS := $(if $(c),diapositivas/capitulo-$(c).mp4,$(SLIDES_MD:.md=.mp4))

video: $(VIDEOS) ## Build the narrated video of every deck (one chapter: make video c=01)

diapositivas/%.mp4: diapositivas/%.odp tools/video.py
	SOFFICE="$(SOFFICE)" uv run tools/video.py $< -o $@

## --- Verification ----------------------------------------------------------

lint: ## Check formatting and lint rules without touching any file
	$(UV) ruff check .
	$(UV) ruff format --check .

format: ## Fix formatting and whatever ruff can fix on its own
	$(UV) ruff format .
	$(UV) ruff check --fix .

# The order runs cheapest to dearest, and in the order that explains a failure
# best: first the part I rule (static), then the examples, then the sandbox,
# then the text matching the examples, and the site last.
check: part-1 part-2 shown links patterns test swish transcripts math time ## Everything that has to be green before a commit
	$(UV) tools/sync-examples.py
	$(MAKE) docs

## --- Cleaning --------------------------------------------------------------

clean: ## Remove the built site and the Python leftovers
	rm -rf site __pycache__ tools/__pycache__ .ruff_cache .pytest_cache

clean-pdf: ## Remove the generated PDFs (`make pdf` rebuilds them)
	rm -f $(PDFS)
