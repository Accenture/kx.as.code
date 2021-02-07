!["kx.as.code_logo"](kxascode_logo_black_small.png "kx.as.code_logo")

# Contribute

## Welcome
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

- [Git-SCM][]

- [Vagrant][] 2.2.13

- [VirtualBox][] 6.1.16

- [Packer][] 1.6.4  (optional - only needed for building base VM itself)

  

## Submitting Changes

- All code changes must be submitted to the master branch via a pull request. The code will be reviewed and approved if all code conventions are met and the code successfully tested.

- As well as code changes, a change will only be approved if documentation in the form of a README.md is provided in the respective code directory.

- It is recommended to install [pre-commit](https://pre-commit.com) framework and initialize it for the project before committing your changes in order to follow best linting practices.

  

## Coding Conventions

- Test all code

- Indent all code

- Comment all code

- Do not simply copy & paste code without understanding what it does

  

## Code Branching

This is a single branch project only.
For every change that you make, you must create a new branch. The branch name must follow the  naming convention below.
Once tested, you must create a pull request to have the code reviewed and merged into the main master branch.

**New feature / Enhancement / Update**

- feature/ + _[ jira story id where available ] - change description_

**Bug Fix**

- bugfix/ + _[ jira bug id where available ] - change description_

**Emergency Hotfix**

- hotfix/ + _[ jira bug id where available ] - change description_

  

## Reporting Bugs



## Templates

- Link to Bug Reporting Template

  

## Fixing Bugs
Bugs can be reported



## Requesting an Enhancement
Open an enhancement requst by sneding an email to the contact at the bottom of this page.



## Style Guide / Coding Conventions

Git Commit Messages:

_{Emoji - see below} - [jira task id] - {description}_

- :bulb: New feature / enhancement &rarr; &colon;bulb&colon;

- :rocket: Performance fix &rarr; &colon;rocket&colon;

- :pill: Temporary workaround &rarr; &colon;pill&colon;

- :zap: Bug fix &rarr; &colon;zap&colon;

- :lock: Security change/fix &rarr; &colon;lock&colon;

- :page_facing_up: Documentation change/fix &rarr; &colon;page_facing_up&colon;

  

## Code of Conduct

- Respect other people's ideas and perspectives

- Be direct, but professional when providing feedback

- Appreciate and support each other

  

## Product Owner

- Product Owner: [Patrick Delamere](mailto:patrick.g.delamere@accenture.com)

  


## Question?
:email: kx.as.code@accenture.com

