![CD Workflow](https://github.com/blackboard-innersource/gh-action-version-cat/workflows/CD%20Workflow/badge.svg?event=push)

# GitHub Action: Version :smile_cat:

This action just reads a file from your repository to get the next release version.
It will also verify that the git tag does not already exist. If the tags does exist,
it will fail the step.

BUT WHY!?! To facilitate a very simple continuous delivery workflow. Every pull request
should modify the file to set the expected release after merge. If you forget, this
action will remind you to modify the file. This is a very simple and non-magical
way to manage auto-tagging that is reviewable as part of the pull request.

This workflow may not be the best for a very busy repository that often has many
pull requests open at a time due to merge conflicts.

What's with the weird name? This started out as simple `bash` that was mostly
just `VERSION=v$(cat VERSION)` and naming things is hard.  The more you know :stars:

## Usage

For all possible inputs and outputs see the [Action YAML](action.yml) file.

### Usage: basic

Add a `VERSION` file in your repository. Add the following contents to the `VERSION` file
(or whatever version you want to use):

```
1.0.0
```

If there are trailing newlines, that is OK.  Then you can invoke this action
in your workflow like this:

```yaml
steps:
  - name: Version
    id: version
    uses: blackboard-innersource/gh-action-version-cat@v1
```

Not very exciting. Combine it with [create-release action](https://github.com/actions/create-release),
then you have continuous delivery:

```yaml
steps:
  - name: Version
    id: version
    uses: blackboard-innersource/gh-action-version-cat@v1

  - name: Create Release ${{ steps.version.outputs.version }}
    if: github.event_name == 'push'
    uses: actions/create-release@v1
    env:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    with:
      tag_name: ${{ steps.version.outputs.version }}
      release_name: ${{ steps.version.outputs.version }}
```

The above would create a tag and GitHub release named `v1.0.0`.

### Usage: workflow

Here is a full working example.

* For pull requests, all the steps will run except for the `Create Release` step.
  The `Version` step will validate the `VERSION` file and fail the build if the
  git tag already exists.
* For updates to master, all steps will run and, if successful, release a new version.

```yaml
name: CD Workflow

on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  cd:
    name: Validate and Release
    runs-on: ubuntu-18.04

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Test
        run: |
          # Your tests!

      - name: Version
        id: version
        uses: blackboard-innersource/gh-action-version-cat@v1

      - name: Create Release ${{ steps.version.outputs.version }}
        if: github.event_name == 'push'
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.version.outputs.version }}
          release_name: ${{ steps.version.outputs.version }}
``` 

## Developing

Install the dependencies:
```bash
$ npm install
```

Build the typescript:
```bash
$ npm run build
```

Run the tests:  
```bash
$ npm test
```

Update the distribution (required for releasing and testing workflow):
```bash
$ npm run build && npm run pack
$ git commit -a dist/index.js -m "Update dist"
```

## License

Please see the [LICENSE](LICENSE) file.
