#!/usr/bin/env bash
#
# Every Prolog file in the book declares its encoding on its first useful line.
#
# The local SWI-Prolog on Windows reads sources in the system encoding, not in
# UTF-8: without the directive, an accented atom or an n-tilde in a comment is a
# syntax error that stops the whole file from loading. SWISH does not care, so
# the error only shows up once a student downloads the example.

set -euo pipefail

missing=0
for file in "$@"; do
  if ! grep -q '^:- *encoding(utf8)\.' "$file"; then
    echo "$file: needs  :- encoding(utf8).  as its first line" >&2
    missing=1
  fi
done
exit $missing
