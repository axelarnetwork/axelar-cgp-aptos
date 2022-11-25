# !/bin/bash

aptos move compile --save-metadata --package-dir aptos/modules/axelar
aptos move compile --save-metadata --package-dir aptos/modules/test
