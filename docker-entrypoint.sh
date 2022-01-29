#!/usr/bin/env bash
set -Eeo pipefail
echo "-- Starting module..."
python inference.py $MERCURE_IN_DIR $MERCURE_OUT_DIR
echo "-- Done."
