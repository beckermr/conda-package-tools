#!/bin/bash
set -e

mkdir -p conda-package-tools
cp *.yaml conda-package-tools/.
cp *.sh conda-package-tools/.
cp condarc conda-package-tools/.
