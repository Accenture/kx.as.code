# Concepts

As there are several keywords used throughout this guide, this page will describe high level the concepts behind them.

## Actions

`Actions` describe the backend process that is executed against a `component`. Valid actions are `install`, `uninstall` and `executeTask`.
These actions can be initiated via the KX-Portal. They can also be triggered [manually](../Deployment/Manual-Provisioning.md), by posting an action message on the pending RabbitMQ queue.

## Action Queues

`action queues` are queues in RabbitMQ that drive the queuing system behind the automated installations. When something is requested to be installed via the portal, a message is published to the `pending_queue` and processed one by one. If the `failed_queue`, `wip_queue` and `retry_queues` are empty, an item is taken from the `pending_queue` and added to the `wip_queue`.
If there is anything in the `failure_queue`, then further processing is halted until the item is either deleted from the `failed_queue` or moved to the `retry_queue`.
The `retry_queue` has priority and will be processed before taking the next item from the `pending_queue`.

When KX.AS.CODE first starts up, it will install core components as defined in `actionsQueue.json`.
There are currently three variations of this.

- [Normal](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/actionQueues.json)
- [Lite](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/actionQueues.json_lite)
- [Minimal](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/actionQueues.json_minimal)

Placing one of these in the profile directory (ensuring to renaming it actionQueues.json if using the lite or minimal JSON files), will ensure that less core components are installed. This can be selected via the Jenkins based launcher described in the [Quick Start Guide](http://localhost:8000/Quick-Start-Guide/).

## Components

`Components` represent the applications that are available for installation. Each component has its own folder in the category folder.

For examples, see the components in the CICD component category directory, on [GitHub.com](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/cicd).

## Component Category

A component category is a grouping of similar solutions. Examples are `monitoring`, which includes Prometheus, the Elastic Stack and Tick Stack, and `cicd` which includes components such as Jenkins and Gitlab etc.  
See the available categories on [GitHub.com](https://github.com/Accenture/kx.as.code/tree/main/auto-setup).

## Metadata

Each component has a `metadata.json` defined. This described exactly what needs to be installed for a `component` and how.

It also describes the type of installation to process. Current supported methods are `Helm`, `ArgoCD` and `Script`.
The `metadata.json` also describes any actions that need to be completed before the main installation process is triggered (eg. create secret) and steps needed after the main installation process is completed (eg. create users).

Health checks needed to determine if the service is reachable are also defined in `metadata.json`. This is particularly important for the post installation steps, as they usually need the API to be available, before executing steps such as "create user".

See the [guide](../Development/Solution-Metadata.md) on `metadata.json` for more information.

## Templates

Templates are a group of components that are typically installed together. The components do not need to belong to the same component category.
Example groups can be found at the following [location](https://github.com/Accenture/kx.as.code/tree/main/templates) on GitHub.

You can add further templates, simply by adding another json file into this directory, and listing the components to be installed as part of this grouping.
The components must exist in the auto-setup folder.

Template groups are not just limited to things like the Elastic Stack or Tick Stack. They can also be used to integrate solutions together. For example, installing Sysdig Falco and RocketChat together as part of a template group would allow first RocketChat to be installed with a post installation step to generate a webhook to post events to a newly created Security channel. The returned webhook URL could then be used during the installation of Sysdig Falco, to setup a notification target.

The important thing to note is that the components would need to be scripted in a way that they are aware of each other's existence - and behave accordingly if the condition is met - and not fail, if the condition is not met.

There are more details on the template groups [here](../Deployment/Provisioning-Templates.md), including details on how to install them manually after KX.AS.CODE has started. It is not yet possible to add templates to the queue in the KX-Portal, but this is a feature on our priority list.

## Profiles

Profiles represent deployment targets. For example, VirtualBox, Parallels, VMWare, OpenStack and AWS to name the ones currently fully functional.
Profiles define the intialization behaviour when KX.AS.CODE comes up for the first time. This includes `storage`, `networking`, `server specifications` as so on.
The definition of this behaviour is described in a file called `profile-config.json`. Each profile can be customized individually and has its own JSON file.

You can read more about profiles [here](../Deployment/Deployment-Profiles.md).

## Tasks

`Tasks` are designed to enable the execution of administrative repetitive tasks after a component has been installed. For example, for a web server, such a task could be `clear cache`, or for the Docker registry `purge deleted images`.
See the [documentation](./Task-Executions.md) for more information.
