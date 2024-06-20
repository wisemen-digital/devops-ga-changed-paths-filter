# Changed Paths Filter

Checks for any changed files using the provide filter file (see [docs](https://github.com/dorny/paths-filter)), or using the given override. Once collected, it will generate a matrix for use with Github Actions strategies.

The output will look something like this (JSON encoded):

```json
[
  {
    "environment": "Default",
    "path": "some/matched/path"
  },
  {
    "environment": "MyEnvironment",
    "path":"another/matched/path"
  }
]
```

## Input

```yaml
inputs:
  filter-file:
    description: Path to the filter file
    required: true
  changes-override:
    description: Override the changes filter and provide your own set of paths (comma separated)
    required: false
  default-environment:
    description: Default environment (fallback value if no env. is provided for a path)
    required: false
    default: Default
```

## Output

```yaml
outputs:
  matrix:
    description: List of combinations of paths & environments
```

## Usage

```yaml
name: Pull Request
on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  generate-matrix:
    outputs:
      deployments: ${{ steps.changed-paths-filter.outputs.matrix }}
    steps:
      - uses: wisemen-digital/devops-ga-changed-paths-filter@main
        id: changed-paths-filter
        with:
          filter-file: .github/my-filters-file.yaml

  do-stuff:
    needs: [generate-matrix]
    strategy:
      matrix:
        deployment: ${{ fromJson(needs.generate-matrix.outputs.deployments) }}
    if: ${{ needs.generate-matrix.outputs.deployments != '[]' }}
    steps:
      - run: …
```
