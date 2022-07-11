# Welcome!

Welcome to the KX.AS.CODE learning workstation. This virtual workstation was created with two primary goals in mind.

*   `PLAY`, `LEARN`, `EXPERIMENT`, `INNOVATE`, `SHARE`, succeed :muscle: :trophy:
*   Share knowledge as code!

!!! tip "KX.AS.CODE was built with the belief that playing and experimentation is the best way to learn new tricks and ultimately innovate." 

As well as learning and sharing knowledge, there are several more use cases for this KX workstation. Here just a few more:

*   Use it for demoing new technologies/tools/processes
*   Keep your physical workstation clean whilst experimenting
*   Have fun playing around with new technologies
*   Use it as an accompaniment to trainings and certifications
*   Experimenting and innovating
*   Test tool integrations

!!! danger "Want to get started quickly? Read our [Quick Start Guide](User-Guide/Quick-Start-Guide/)."

## What is the KX.AS.CODE Workstation?
It can be considered a fully automated cloud like Kubernetes environment with a lot of things you would expect to see when managing a Kubernetes cluster in the cloud, including an ingress controller, storage cluster, DNS services, a certificate authority... and the best bit, you just have to fill out a couple of config files and vagrant up/terraform apply, and you are on your way!

!!! info "To find out more about what KX.AS.CODE is, and how it came about, read our [Questions and Answers](Overview/Questions_and_Answers/)."

!!! info "For a more detailed look at the components that make up KX.AS.CODE, check out the [Architecture](Overview/Architecture/)."

## Contributing
We are happy to receive contributions, ideas and dare I say it, bug fixes or suggestions on how to do things better! We never stop learning! :nerd_face:

For more details on how you can contribute to the project, checkout the [CONTRIBUTE.md](Development/Contribution-Guidelines/) file

## KX.AS.CODE

### Login screen
Depending on whether the defaults were changed or not, you can either log in with your own user, or the default `kx.hero`. 

Additional users will also be available if applied before launching KX.AS.CODE. See the [User Management Guide](Deployment/User-Management/).

![](images/kx.as.code_login_screen.png)

### KX.AS.CODE desktop

This is the home of KX.AS.CODE from where you can launch the deployed applications, read manuals, test API calls, administer the VM, and so on.

![](images/kx.as.code_desktop.png)

### Administration tools

The tools for administering some elements of KX.AS.CODE. More details will be published on the administration page (wip).

![](images/kx.as.code_admin_tools.png)

### Installed applications

The applications folder show the icons of the applications that have been installed so far and are available to launch. Use `GoPoass` to get the password for accessing the application. 

![](images/kx.as.code_applications.png)

### Kubernetes IDE

OpenLens, known as the Kubernetes IDE, displays information about the running workloads in Kubernetes and their status. It is useful for debugging if there is an issue with any of the workloads.

![](images/kx.as.code_openlens.png)

### GoPass password manager

All administration passwords for accessing all admin tools and applications are stored here. The passwords for the users are also available here.

![](images/kx.as.code_gopass.png)

### Installed application

Here an example Gitlab application that was installed via the KX.AS.CODE automated install scripts.

![](images/kx.as.code_gitlab.png)

### User manuals

User manuals are useful if you are new to an application and want to read up on how it works.

![](images/kx.as.code_application_user_manuals.png)

### API documentation

Since we are in the world of DevOps here, API documentation is important for automating any workflows. API documentation is automatically linked for all applications installed via KX.AS.CODE.

![](images/kx.as.code_api_docs.png)

### Swagger API documentation

If an application has a Swagger endpoint, this is also accessible via the API docs folder.

![](images/kx.as.code_harbor_swagger.png)

### Postman API documentation

If an application has a Postman endpoint or public link, this is also accessible via the API docs folder.

![](images/kx.as.code_mattermost_postman.png)

### Source code in VSCode

Since KX.AS.CODE is all about sharing knowledge as code, a pre-configured VSCode is installed that includes all the KX.AS.CODE source code.

![](images/kx.as.code_vscode.png)

### KX.AS.CODE Portal

The KX.AS.CODE portal makes adding and removing applications easier, and provides status on current installed items.

!!! warning "The portal is still in BETA, so may not always behave as expected."

![](images/kx.as.code_portal.png)

### KX.AS.CODE Application Management

Applications and be removed and added from the KX.AS.CODE Portal's application screen.

!!! warning "The portal is still in BETA, so may not always behave as expected."

![](images/kx.as.code_portal_applications.png)

### KX.AS.CODE Application Groups

Applications can be installed in integrated groups. This is still a work in progress. Currently, this page provides a view of the available groups, but not yet an option to install them.
See the [manual installations](User-Guide/Manual-Provisioning/#installation-groups) page, on how to install the groups manually without the portal.

!!! warning "The portal is still in BETA, so may not always behave as expected."

![](images/kx.as.code_portal_application_groups.png)



Wish you all the best and enjoy the DevOps workstation! :smile:

Yours, Patrick Delamere (Accenture Song), creator of KX.AS.CODE

