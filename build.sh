# !/bin/bash

# Check if aptos is installed, if not exit
if ! command -v aptos &> /dev/null
then
    echo "aptos not found. skip building modules."
    exit
fi

# Build modules and save metadata and bytecode version
aptos move compile --save-metadata --bytecode-version 6 --package-dir aptos/modules/axelar

# Clean up unnecessary build files and directories
rm -rf aptos/modules/axelar/build/AxelarFramework/source_maps \
       aptos/modules/axelar/build/AxelarFramework/sources \
       aptos/modules/axelar/build/AxelarFramework/bytecode_modules/dependencies
