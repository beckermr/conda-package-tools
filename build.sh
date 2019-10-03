#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python3.7" ]
then
    pyver="37"
    os="linux"
elif [ "$CONFIG" == "osx_python3.7" ]
then
    pyver="37"
    os="osx"
fi

export PATH="$HOME/miniconda/bin:$PATH"

cat conda-package-tools/condarc > $HOME/.condarc

conda build -m conda-package-tools/${CONFIG}.yaml recipe


echo "Uploading the package..."

if [ "$BUILD_SOURCEBRANCHNAME" == "master" ]
then
    if [ "$BUILD_REPOSITORY_NAME" == "beckermr/conda-package-tools" ]
    then
        {
            # remove the old package
            anaconda -t ${ANACONDA_TOKEN} remove -f beckermr/test_package/0.1.0/${os}-64/test_package-0.1.0-py${pyver}_0.tar.bz2
        } || {
            echo "WARNING: could not remove old build for testing on master!"
        }
    fi
    anaconda -t ${ANACONDA_TOKEN} upload $HOME/miniconda/conda-bld/*/*.tar.bz2
fi
