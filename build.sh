#!/bin/bash
set -e

if [ "$CONFIG" == "linux_python3.7" ]; then
    pyver="37"
    os="linux"
elif [ "$CONFIG" == "osx_python3.7" ]; then
    pyver="37"
    os="osx"

    # deal with OSX SDK
    # follows the conda-forge one with less options
    export MACOSX_DEPLOYMENT_TARGET=$(cat $HOME/miniforge3/conda_build_config.yaml | shyaml get-value MACOSX_DEPLOYMENT_TARGET.0 10.9)
    export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-10.9}
    export CONDA_BUILD_SYSROOT="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
    echo "Downloading ${MACOSX_DEPLOYMENT_TARGET} sdk"
    curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz
    tar -xf MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz -C "$(dirname "$CONDA_BUILD_SYSROOT")"
    # set minimum sdk version to our target
    plutil -replace MinimumSDKVersion -string ${MACOSX_DEPLOYMENT_TARGET} $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
    plutil -replace DTSDKName -string macosx${MACOSX_DEPLOYMENT_TARGET}internal $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist

    if [ -d "${CONDA_BUILD_SYSROOT}" ]
    then
        echo "Found CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
    else
        echo "Missing CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
        exit 1
    fi

    echo "" >> ./conda-package-tools/${CONFIG}.yaml
    echo "CONDA_BUILD_SYSROOT:" >> ./conda-package-tools/${CONFIG}.yaml
    echo "- ${CONDA_BUILD_SYSROOT}" >> ./conda-package-tools/${CONFIG}.yaml
    echo "" >> ./conda-package-tools/${CONFIG}.yaml
fi

source $HOME/miniforge3/etc/profile.d/conda.sh 
conda activate base

cat conda-package-tools/condarc > $HOME/.condarc

conda build \
    -m $HOME/miniforge3/conda_build_config.yaml \
    -m conda-package-tools/${CONFIG}.yaml \
    recipe

if [[ `compgen -G ${HOME}/miniforge3/conda-bld/*/*.tar.bz2` ]]; then
    echo " "
    echo "package sizes:"
    du -h ${HOME}/miniforge3/conda-bld/*/*.tar.bz2
    echo " "

    if [[ ${ANACONDA_TOKEN} ]]; then
        # https://stackoverflow.com/questions/24318927/bash-regex-to-match-semantic-version-number
        SEMVER_REGEX="^(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?$"

        if [ "$BUILD_REPOSITORY_NAME" == "beckermr/conda-package-tools" ]; then
            {
                # remove the old package
                anaconda --token ${ANACONDA_TOKEN} remove -f beckermr/test_package/0.1.0/${os}-64/test_package-0.1.0-py${pyver}_0.tar.bz2
            } || {
                echo "WARNING: could not remove old build for testing!"
            }
            echo "Uploading the package..."
            anaconda --token ${ANACONDA_TOKEN} upload $HOME/miniforge3/conda-bld/*/*.tar.bz2
            exit 0
        else
            if [[ "$BUILD_SOURCEBRANCHNAME" == "master" ]] || [[ ${BUILD_SOURCEBRANCHNAME#v} =~ $SEMVER_REGEX ]]; then
                echo "Uploading the package..."
                anaconda --token ${ANACONDA_TOKEN} upload --skip-existing $HOME/miniforge3/conda-bld/*/*.tar.bz2
                exit 0
            fi
        fi
    fi
    echo "Could not upload the package due to missing anaconda token or non-matching branch name!"
fi

