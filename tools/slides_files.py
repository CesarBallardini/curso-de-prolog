"""MkDocs hook: publish the slide decks with the site.

The decks live outside docs/, in diapositivas/: the Markdown source of each one,
the LibreOffice Impress file built from it (`make slides`) and its PDF export
(`make slides-pdf`). The .odp and .pdf are versioned, so the site can carry them
without building anything: this adds them to the files MkDocs copies, under
`diapositivas/`, where Apéndice B (docs/pdf.md) links them. Because they enter
the file collection, the strict build checks those links like any other. The
narrated videos (.mp4) are not versioned and are left out.
"""

from pathlib import Path

from mkdocs.structure.files import File

SLIDES = 'diapositivas'


def on_files(files, config):
    """MkDocs hands the collection of site files here, before building pages."""
    root = Path(config['config_file_path']).parent
    for deck in sorted((root / SLIDES).glob('capitulo-*.*')):
        if deck.suffix in {'.odp', '.pdf'}:
            files.append(
                File(
                    f'{SLIDES}/{deck.name}',
                    src_dir=str(root),
                    dest_dir=config['site_dir'],
                    use_directory_urls=config['use_directory_urls'],
                )
            )
    return files
