#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python3.7" ]; then
    pyver="37"
    os="linux"
elif [ "$CONFIG" == "osx_python3.7" ]; then
    pyver="37"
    os="osx"
fi

export PATH="$HOME/miniconda/bin:$PATH"

cat conda-package-tools/condarc > $HOME/.condarc

conda build \
    -m $HOME/miniconda/conda_build_config.yaml \
    -m conda-package-tools/${CONFIG}.yaml \
    recipe


if [[ ${ANACONDA_TOKEN} ]]; then
    # https://stackoverflow.com/questions/24318927/bash-regex-to-match-semantic-version-number
    SEMVER_REGEX="^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

    if [ "$BUILD_REPOSITORY_NAME" == "beckermr/conda-package-tools" ]; then
        {
            # remove the old package
            anaconda -t ${ANACONDA_TOKEN} remove -f beckermr/test_package/0.1.0/${os}-64/test_package-0.1.0-py${pyver}_0.tar.bz2
        } || {
            echo "WARNING: could not remove old build for testing!"
        }
        echo "Uploading the package..."
        anaconda -t ${ANACONDA_TOKEN} upload $HOME/miniconda/conda-bld/*/*.tar.bz2
        exit 0
    else
        if [[ "$BUILD_SOURCEBRANCHNAME" == "master" ]] || [[ ${BUILD_SOURCEBRANCHNAME#v} =~ $SEMVER_REGEX ]]; then
            echo "Uploading the package..."
            anaconda -t ${ANACONDA_TOKEN} upload $HOME/miniconda/conda-bld/*/*.tar.bz2
            exit 0
        fi
    fi
fi

echo "Could not upload the package due to missing anaconda token or wrong branch name!"
