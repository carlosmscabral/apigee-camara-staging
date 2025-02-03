# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few guidelines you need to follow.

## Quickstart

1. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo)
   the repository and make your contribution. Please don't make changes to
   multiple projects in the same pull request - Consult
   [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests. Also please check if GitHub Action is enabled in your forked repo. Go to the Settings tab in the GitHub repo, under Actions and General, make sure the permissions are set to allow all actions and reusable workflows
2. In your forked repo, create a new branch and make your changes:
   1. To run the mega-linter locally, you will need to install latest versions of [Docker](https://docs.docker.com/get-docker) and [Node.js](https://nodejs.org/en) on your local machine
   2. Install mega-linter-runner by running `npm install mega-linter-runner -g` (Note: You might need to run this with sudo permissions)
   3. From the main directory, run the megalinter locally by executing `mega-linter-runner -p . --remove-container`. This should run all the checks locally.
   4. Additionally, you can also run:
      1. `./tools/pipeline-linter/check-readme.sh` to check if the sample is added to main [README](./README.md#samples) table
      2. `./tools/pipeline-linter/check-apigeelint.sh` to check if the samples pass all the Apigeelint rules
   5. Once all the changes are made and the checks have passed, commit them to your branch
3. Submit a PR from your branch to the main branch in **your forked repo** itself. This should trigger the GitHub Action in your forked repo. As there are other checks besides megalinter, with this process you can check they all are met before merging to the main Google repo.
4. Make sure they all pass. Once they are all passed, you can submit a pull request from your fork repo's main branch to the Google's apigee-samples repo
5. This again should trigger the GitHub Action in the Google repo. Ensure the pull request checks listed below all pass
6. Submit your PR, and we will perform a code review
7. Once all issues are resolved, your change will be merged!

## <a name="pull-request-checks"></a>Pull Request Checks

- Submitter has signed a [Contributor License Agreement](#cla) (see below)
- [Apache 2.0 License](https://opensource.google/docs/releasing/preparing/#license-file) is present (you can [automate](https://github.com/google/addlicense)
  this)
- Sample is listed in the main [README](./README.md#samples)
- [Mega Linter](https://megalinter.github.io) checks pass
- [apigeelint](https://github.com/apigee/apigeelint) checks pass
- Commit messages follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
  standard

## <a name="cla"></a>Contributor License Agreement

Contributions to this project must be accompanied by a Contributor License
Agreement. You (or your employer) retain the copyright to your contribution;
this simply gives us permission to use and redistribute your contributions as
part of the project. Head over to <https://cla.developers.google.com/> to see
your current agreements on file or to sign a new one.

You generally only need to submit a CLA once, so if you've already submitted one
(even if it was for a different project), you probably don't need to do it
again.

## Community Guidelines

This project follows
[Google's Open Source Community Guidelines](https://opensource.google.com/conduct/).
