# Contribute

This guide provides some basic rules for contributing to this asset. This project is intended to run as an in house OpenSource project, which means that anyone can contribute.
Remember, the ultimate goal of this project is

- Share knowledge
- Learn whilst sharing knowledge
- Innovate

As well as learning and sharing knowledge, there are several more use cases for this KX workstation. Here just a few more:

- Use it for demoing new technologies/tools to clients
- Keep your physical workstation clean whilst experimenting in the VM
- React faster to a client request for a new tool

## Feature Requests

- Search for previous suggestions to make sure your idea is not a duplicate
- Ensure your feature request description is easy to understand

## Development Approach

-  `IMPORTANT NOTE:` All the KX.AS.CODE developments must be accompanied by a `README.md` and `inline comments`
-  Pull requests will only be merged into the main branch if all documentation as to usage of a new feature is included
-  `Use the README_TEMPLATE.md` in the root of the KX.AS.CODE repository as the basis of your README.md

## Testing

- All code must be tested and validated inside the VM before submission
- It is not sufficient to validate on local workstation only

## Environment Details

Other version should work as well, but the versions below are what the base VM build was tested with.

- Git-SCM - 2.37.1
- Vagrant - 2.2.19
- VirtualBox - 6.1.36
- Packer - 1.8.3  (optional - only needed for building base VM itself)

## Submitting Changes

- All code changes must be submitted to the `develop` branch via a pull request. The code will be reviewed and approved if all code conventions are met and the code successfully tested.
- It is recommended to install [pre-commit](https://pre-commit.com){:target="\_blank"} framework and initialize it for the project before committing your changes in order to follow best linting practices.

## Coding Conventions

- Test all code
- Indent all code
- Comment all code
- Do not simply copy & paste code from other sources without understanding what it does

## Code Branching

For every change that you make, you must create a new branch. The branch name must follow the naming convention below.
Once tested, you must create a pull request to have the code reviewed and merged into the main master branch.

**New feature / Enhancement / Update**

- feature/ + _[ #xxx github issue id ] - change description_

**Bug Fix**

- bugfix/ + _[ #xxx github issue id ] - change description_

## Reporting Bugs

## Requesting an Enhancement
Open an enhancement request by sending an email to the contact at the bottom of this page, creating an issue on GitHub.com, or posting a question to the KX.AS.CODE Feature Request channel on Discord.


## Style Guide / Coding Conventions

Git Commit Messages:

The Git commit message should reference an issue on GitHub.com.

## Code of Conduct

- Respect other people's ideas and perspectives
- Be direct, but professional when providing feedback
- Appreciate and support each other

## Product Owner

- Product Owner: [Patrick Delamere](mailto:patrick.g.delamere@accenture.com)

## Question?
:email: kx.as.code@accenture.com

You can also contact us on [Discord](https://discord.gg/FXeavNQnC5)