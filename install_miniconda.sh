#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python2.7" ]
then
    pyver="2.7"
    os="Linux"
elif [ "$CONFIG" == "linux_python3.6" ]
then
    pyver="3.6"
    os="Linux"
elif [ "$CONFIG" == "osx_python2.7" ]
then
    pyver="2.7"
    os="MacOSX"
elif [ "$CONFIG" == "osx_python3.6" ]
then
    pyver="3.6"
    os="MacOSX"
fi

wget https://repo.continuum.io/miniconda/Miniconda${pyver:0:1}-4.5.11-${os}-x86_64.sh
bash Miniconda${pyver:0:1}-4.5.11-${os}-x86_64.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"

cat conda-package-tools/condarc > $HOME/.condarc

conda install -yq python=${pyver} conda-build anaconda-client conda-verify