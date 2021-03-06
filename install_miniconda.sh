#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python3.8" ]
then
    pyver="3.8"
    os="Linux"
elif [ "$CONFIG" == "osx_python3.8" ]
then
    pyver="3.8"
    os="MacOSX"
fi

curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-${os}-x86_64.sh > miniforge3.sh
chmod u+x miniforge3.sh
bash miniforge3.sh -b -p ${HOME}/miniforge3
source $HOME/miniforge3/etc/profile.d/conda.sh 
conda activate base

cat conda-package-tools/condarc > $HOME/.condarc

conda install -yq python=${pyver} conda-build anaconda-client conda-verify conda-forge-pinning shyaml mamba boa

conda list

conda info

echo "condarc:"
cat $HOME/.condarc
