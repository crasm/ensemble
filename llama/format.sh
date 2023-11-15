#!/bin/sh
cd "$(realpath "$(dirname "$0")")"
find . -name '*.dart' -not -name '*.ffigen.*' -print0 | xargs -0 -- dart format
