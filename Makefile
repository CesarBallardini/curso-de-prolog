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

.PHONY: help install browser test swish part-1 transcripts math time sync sql appendix \
        docs docs-serve pdf pldoc clean-pldoc lint format check clean clean-pdf

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

sql: ## Run the SQL/Prolog pairs of chapter 35 and compare the results
	$(UV) references/ejercicios/sql-prolog/verificar.py

# Each recipe line is its own shell, so the guard and the command have to be one
# line: an `exit 0` on the line above would only leave that shell, and pytest
# would run anyway against a directory that is not there.
appendix: ## Run the pytest suites of chapters 29 (Janus), 30 and 31 (the Python clients)
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

docs-serve: ## Serve the site locally with live reload
	$(UV) mkdocs serve --dev-addr $(DIRECCION)

DIRECCION ?= 0.0.0.0:8000

pdf: $(PDFS) ## Build the PDF of every chapter (only the ones that changed)

# The PDF machinery, which every page rebuild depends on.
PDF_DEPS := tools/md2pdf.py tools/pdf-style.css tools/katex_pdf.py tools/swish_links.py tools/examples.py

define REGLA_PDF
$(1)/$(notdir $(1)).pdf: $(1)/index.md $$(PDF_DEPS)
	$$(UV) tools/md2pdf.py $$< -o $$@

$(1)/$(notdir $(1))-soluciones.pdf: $(1)/soluciones.md $$(PDF_DEPS)
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
