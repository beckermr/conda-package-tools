#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python2.7" ]
then
    pyver="27"
    os="linux"
elif [ "$CONFIG" == "linux_python3.6" ]
then
    pyver="36"
    os="linux"
elif [ "$CONFIG" == "osx_python2.7" ]
then
    pyver="27"
    os="osx"
elif [ "$CONFIG" == "osx_python3.6" ]
then
    pyver="36"
    os="osx"
fi

export PATH="$HOME/miniconda/bin:$PATH"

cat conda-package-tools/condarc > $HOME/.condarc

conda build -m conda-package-tools/${CONFIG}.yaml recipe


if [ "$BUILD_SOURCEBRANCHNAME" == "master" ]
then
    if [ "$BUILD_REPOSITORY_NAME" == "beckermr/conda-package-tools" ]
    then
        # remove the old package
        anaconda -t ${ANACONDA_TOKEN} remove -f beckermr/test_package/0.1.0/${os}-64/test_package-0.1.0-py${pyver}_0.tar.bz2
    fi
    anaconda -t ${ANACONDA_TOKEN} upload $HOME/miniconda/conda-bld/*/*.tar.bz2
fi
