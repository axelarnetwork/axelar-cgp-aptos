# !/bin/bash

if command -v aptos &>/dev/null; then
  aptos move compile --save-metadata --package-dir aptos/modules/axelar
  aptos move compile --save-metadata --package-dir aptos/modules/test
else
  echo "aptos not found. skip building modules."
  exit
fi
