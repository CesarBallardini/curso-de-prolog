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
        docs docs-serve pdf lint format check clean clean-pdf

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

part-1: ## Check that chapters 1 to 11 use nothing from part II
	$(UV) tools/check-part-1.py

transcripts: ## Run every transcript of the book against swipl and compare the answers
	$(UV) tools/check-transcripts.py $(e)

math: ## Parse every formula of the book with KaTeX and report the ones it rejects
	$(UV) tools/check-math.py $(e)

time: ## Recompute every chapter time estimate and report the ones that drifted
	$(UV) tools/check-time.py $(e)

sync: ## Copy into the text the code blocks that declare they come from ejemplos/
	$(UV) tools/sync-examples.py --write

sql: ## Run the SQL/Prolog pairs of chapter 34 and compare the results
	$(UV) references/ejercicios/sql-prolog/verificar.py

# Each recipe line is its own shell, so the guard and the command have to be one
# line: an `exit 0` on the line above would only leave that shell, and pytest
# would run anyway against a directory that is not there.
appendix: ## Run the tests of the appendix A examples (Janus)
	@if [ -d ejemplos/apendice-a ]; then \
	  SWI_HOME_DIR="$(SWI_HOME_DIR)" $(UV) --group apendice-a pytest ejemplos/apendice-a; \
	else \
	  echo "There is no ejemplos/apendice-a yet: nothing to test."; \
	fi

## --- The book --------------------------------------------------------------

# The PDFs first: the site links to every one of them from docs/pdf.md, and
# the strict build fails on a link to a file that is not there.
docs: $(PDFS) ## Build the site into site/ (a warning is an error)
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
check: part-1 test swish transcripts math time ## Everything that has to be green before a commit
	$(UV) tools/sync-examples.py
	$(MAKE) docs

## --- Cleaning --------------------------------------------------------------

clean: ## Remove the built site and the Python leftovers
	rm -rf site __pycache__ tools/__pycache__ .ruff_cache .pytest_cache

clean-pdf: ## Remove the generated PDFs (`make pdf` rebuilds them)
	rm -f $(PDFS)
