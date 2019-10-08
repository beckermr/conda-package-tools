# conda-package-tools

tools for building conda packages

Note that some of the CI configuration elements are lifted from conda-forge under [BSD](CONDA_FORGE_LICENSE).


# Usage

1. Make a repo w/ azure CI enabled.
2. Make a pipeline for your recipe.
3. For the YAML configuration, it should look like

   ```yaml
   resources:
     repositories:
       - repository: templates
         type: github
         name: beckermr/conda-package-tools
         ref: refs/tags/v<XYZ>
         endpoint: azure-read-only

    variables:
      buildtag: v<XYZ>

    jobs:
      - template: linux_python3.7_azure_template.yml@templates
        parameters:
          buildtag: $(buildtag)
      - template: osx_python3.7_azure_template.yml@templates
        parameters:
          buildtag: $(buildtag)
   ```

   where `XYZ` is has been replaced with the version number (2 or greater).
4. Add your anaconda token for uploads as a variable on the pipeline named
   `anaconda.token`.
5. Run your pipeline!
