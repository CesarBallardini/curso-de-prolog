#!/usr/bin/env python
"""Download, or check, the third-party libraries the site serves itself (docs/vendor/).

    uv run --frozen tools/vendor.py            download what tools/vendor.toml pins, where missing or changed
    uv run --frozen tools/vendor.py --check    compare docs/vendor/ with tools/vendor.lock.json; no network

The libraries (KaTeX, mermaid) are committed, so the site build, the PDF build and CI never fetch them.
This tool is for changing a version, or restoring the files: it downloads each package's tarball from
the npm registry into an empty temporary directory, refuses it when its sha512 differs from the
manifest's `integrity`, extracts it without following links or leaving the directory, copies only the
files the manifest lists into docs/vendor/<name>-<version>/, removes other versions of the library, and
records the sha256 of every copied file in tools/vendor.lock.json.

`--check` fails when a file differs from the lock, a listed library is missing, docs/vendor/ holds a
directory the manifest does not name, or mkdocs.yml does not load a library from its current directory.
"""

import argparse
import base64
import hashlib
import json
import shutil
import sys
import tarfile
import tempfile
import tomllib
import urllib.request
from pathlib import Path
from typing import NamedTuple, TypedDict, cast

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'tools' / 'vendor.toml'
LOCK = ROOT / 'tools' / 'vendor.lock.json'
VENDOR = ROOT / 'docs' / 'vendor'
MKDOCS = ROOT / 'mkdocs.yml'
# npm tarballs hold the package under this directory.
PACKAGE = 'package'
TIMEOUT_SECONDS = 120


class LibraryDto(TypedDict):
    """One library of tools/vendor.toml."""

    version: str
    tarball: str
    integrity: str
    license: str
    files: dict[str, str]  # package path or glob -> directory under the library's directory


type Lock = dict[str, dict[str, str]]
"""tools/vendor.lock.json: library directory name -> {relative file path: sha256}."""


class Library(NamedTuple):
    name: str
    spec: LibraryDto

    @property
    def directory_name(self) -> str:
        return f'{self.name}-{self.spec["version"]}'

    @property
    def directory(self) -> Path:
        return VENDOR / self.directory_name


def library_directory(name: str) -> Path:
    """Where a library of the manifest is vendored, for the tools that read it (katex_pdf.py, md2pdf.py)."""
    return next(library.directory for library in libraries() if library.name == name)


def libraries() -> list[Library]:
    manifest = cast('dict[str, LibraryDto]', tomllib.loads(MANIFEST.read_text(encoding='utf-8')))
    return [Library(name, spec) for name, spec in manifest.items()]


def load_lock() -> Lock:
    return cast('Lock', json.loads(LOCK.read_text(encoding='utf-8'))) if LOCK.is_file() else {}


def save_lock(lock: Lock) -> None:
    LOCK.write_text(json.dumps(dict(sorted(lock.items())), indent=1) + '\n', encoding='utf-8', newline='\n')


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def file_hashes(directory: Path) -> dict[str, str]:
    """{path relative to the directory: sha256} of every file under it."""
    return {
        path.relative_to(directory).as_posix(): sha256(path) for path in sorted(directory.rglob('*')) if path.is_file()
    }


def npm_integrity(data: bytes) -> str:
    """The integrity string npm publishes: sha512, base64."""
    return 'sha512-' + base64.b64encode(hashlib.sha512(data).digest()).decode()


def download(url: str) -> bytes:
    if not url.startswith('https://registry.npmjs.org/'):
        sys.exit(f'{url}: only tarballs of the npm registry are accepted')
    with urllib.request.urlopen(url, timeout=TIMEOUT_SECONDS) as response:  # noqa: S310 -- an https URL, checked above
        return cast('bytes', response.read())


def install(library: Library, workspace: Path) -> None:
    """Download, verify, extract and copy one library; its old versions are removed."""
    data = download(library.spec['tarball'])
    if npm_integrity(data) != library.spec['integrity']:
        sys.exit(f'{library.name}: the tarball does not match the integrity in {MANIFEST.name}')
    archive = workspace / f'{library.directory_name}.tgz'
    archive.write_bytes(data)
    extracted = workspace / library.directory_name
    with tarfile.open(archive) as tar:
        # The 'data' filter refuses absolute paths, links outside the directory and special files.
        tar.extractall(extracted, filter='data')
    package = extracted / PACKAGE
    staged = workspace / 'staged'
    for pattern, target in library.spec['files'].items():
        matches = sorted(package.glob(pattern))
        if not matches:
            sys.exit(f'{library.name}: {pattern} is not in the package')
        for source in matches:
            destination = staged / target / source.name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, destination)
    for old in VENDOR.glob(f'{library.name}-*'):
        shutil.rmtree(old)
    shutil.copytree(staged, library.directory)
    shutil.rmtree(staged)


def vendor() -> int:
    lock = load_lock()
    with tempfile.TemporaryDirectory() as temporary:
        for library in libraries():
            current = library.directory.is_dir() and lock.get(library.directory_name) == file_hashes(library.directory)
            if current:
                print(f'{library.directory_name}: up to date')
                continue
            install(library, Path(temporary))
            for name in [n for n in lock if n.startswith(f'{library.name}-')]:
                del lock[name]
            lock[library.directory_name] = file_hashes(library.directory)
            print(f'{library.directory_name}: {len(lock[library.directory_name])} files in docs/vendor/')
    save_lock(lock)
    return 0


def problems() -> list[str]:
    """What --check reports; empty when docs/vendor/ is what the manifest and the lock describe."""
    found: list[str] = []
    lock = load_lock()
    expected = {library.directory_name for library in libraries()}
    mkdocs = MKDOCS.read_text(encoding='utf-8')
    for library in libraries():
        name = library.directory_name
        if not library.directory.is_dir():
            found.append(f'{name}: missing from docs/vendor/ (make vendor)')
            continue
        if name not in lock:
            found.append(f'{name}: not in {LOCK.name} (make vendor)')
        elif file_hashes(library.directory) != lock[name]:
            found.append(f'{name}: its files differ from {LOCK.name}')
        if f'vendor/{name}/' not in mkdocs:
            found.append(f'{name}: mkdocs.yml does not load it from vendor/{name}/')
    for directory in VENDOR.iterdir() if VENDOR.is_dir() else []:
        if directory.is_dir() and directory.name not in expected:
            found.append(f'{directory.name}: in docs/vendor/ but not in {MANIFEST.name}')
    return found


def check() -> int:
    found = problems()
    for problem in found:
        print(problem, file=sys.stderr)
    print(f'docs/vendor/: {len(libraries())} libraries, {len(found)} problems')
    return 1 if found else 0


def main() -> None:
    parser = argparse.ArgumentParser(description=(__doc__ or '').splitlines()[0])
    parser.add_argument('--check', action='store_true', help='compare docs/vendor/ with the lock; no network')
    args = parser.parse_args()
    sys.exit(check() if args.check else vendor())


if __name__ == '__main__':
    main()
