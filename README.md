# Welcome!

Welcome to the KX.AS.CODE workstation. This virtual workstation was initially created with two primary goals in mind, but has since become so much more!

*   Play, learn, experiment, innovate! :muscle: :trophy:
*   Share knowledge a code!

## What is the KX.AS.CODE Workstation?

KX.AS.CODE can be considered as a `local cloud like` Kubernetes environment with a lot of things you would expect to see when managing a Kubernetes cluster in the cloud, including an ingress controller, storage cluster, DNS, a certificate authority... and the best bit, you just have to fill out a couple of config files and `vagrant up`/`terraform apply`, and you are on your way!

## What else?

Currently, KX.AS.CODE fulfills the following use cases:

1. DevOps training environment
2. Fullstack development/DevOps environment
3. A HomeLab DevOps environment - see below our Raspberry Pi project!

## Where can I deploy KX.AS.CODE?
KX.AS.CODE can be deployed locally or in the cloud, be it a private or public cloud. The most tested solutions are currently OpenStack and VirtualBox. Here a full list of solutions we have run KX.AS.CODE on.

1. VMWare Workstation/Fusion (MacOSX, Linux and Windows)
2. VirtualBox (MacOSX, Linux and Windows)
3. Parallels (MacOSX)
4. AWS
5. OpenStack
6. VMWare VSphere (needs updating)

For the full guide on KX.AS.CODE, read full [documentation](https://accenture.github.io/kx.as.code/).

## What are we currently working on?

<div style="background-color:rgb(220, 20, 60, 0.4); padding: 20px">
<span style="vertical-align: middle; display: inline-block;">
<img src="https://github.com/Accenture/kx.as.code/raw/main/docs/assets/images/raspberrypi_logo.png" width="35px"></span>
<span style="margin-left: 20px; font-size: large"><b>Raspberry Pi enablement! :heart: </b> 
</span>
</div>

<span>Whilst the solution already works on Parallels, VirtualBox, VMWare, OpenStack and AWS, it's time to prepare for ARM64 compatibility. Currently, KX.AS.CODE is limited to running on AMD64 CPU architectures. 

The Raspberry Pi project will add ARM64 to the mix. Once done, the next step will be to test and optimize for Mac M1/M2 CPUs as well.

This is also the first time we run KX.AS.CODE on bare-metal, which is an additional bonus. :smile:

Here some screenshots from our current project.

![](docs/assets/images/Raspberry_PI_Setup_1.jpg)

![](docs/assets/images/Raspberry_PI_Setup_3.jpg)

![](docs/assets/images/Raspberry_PI_Setup_4.jpg)

## Screenshots

Here some impressions of KX.AS.CODE. Read our [documentation](https://accenture.github.io/kx.as.code/) on GitHub Pages for a more comprehensive view on KX.AS.CODE.

### Jenkins based launcher for building and launching KX.AS.CODE

Configure your KX.AS.CODE instance using the Jenkins based launcher. On this screen you can select between K3s and K8s amongst others.

![](docs/assets/images/jenkins_minimal_setup.png)

### Optionally select application groups to install

You can also configure application groups that will be installed on first launch of KX.AS.CODE. More groups and individual applications can be added later.

![](docs/assets/images/jenkins_installation_groups.png)

### Review configuration and launch KX.AS.CODE

Once done configuring KX.AS.CODE in the launcher, you can review the settings and launch the KX.AS.CODE environment.

![](docs/assets/images/jenkins_minimal_setup5.png)

### KX.AS.CODE login screen

Depending on whether the defaults were changed or not, you can either log in with your own user, or the default `kx.hero`.

![](docs/assets/images/kx.as.code_login_screen.png)

### KX.AS.CODE Desktop

This is the home of KX.AS.CODE from where you can launch the deployed applications, read manuals, test API calls, administer the VM, and so on.

![](docs/assets/images/kx.as.code_desktop.png)

### KX.AS.CODE installed applications, as selected in the KX.AS.CODE Launcher

The applications folder show the icons of the applications that have been installed so far and are available to launch. Use `GoPoass` to get the password for accessing the application.

![](docs/assets/images/kx.as.code_applications.png)

### Gitlab Installed to KX.AS.CODE

Here an example Gitlab application that was installed via the KX.AS.CODE automated install scripts.

![](docs/assets/images/kx.as.code_gitlab.png)

### Administration Tools

The tools for administering some elements of KX.AS.CODE. More details will be published on the administration page (wip).

![](docs/assets/images/kx.as.code_admin_tools.png)

### Application API Manuals

Since we are in the world of DevOps here, API documentation is important for automating any workflows. API documentation is automatically linked for all applications installed via KX.AS.CODE.

![](docs/assets/images/kx.as.code_api_docs.png)

### Harbor Swagger API

If an application has a Swagger endpoint, this is also accessible via the API docs folder.

![](docs/assets/images/kx.as.code_harbor_swagger.png)

### Postman API documentation

If an application has a Postman endpoint or public link, this is also accessible via the API docs folder.

![](docs/assets/images/kx.as.code_mattermost_postman.png)

### Application Manuals

Administration and user manuals are useful if you are new to an application and want to read up on how it works.

![](docs/assets/images/kx.as.code_application_user_manuals.png)

### Source code in VSCode

Since the original concept of KX.AS.CODE was all about sharing knowledge as code (it has since become so much more), a pre-configured VSCode is installed that includes all the KX.AS.CODE source code.

![](assets/images/kx.as.code_vscode.png)

### Credential Management with GoPass

All administration passwords for accessing all admin tools and applications are stored here. The passwords for the users are also available here.

![](docs/assets/images/kx.as.code_gopass.png)

### Kubernetes Management with OpenLens

OpenLens, known as the Kubernetes IDE, displays information about the running workloads in Kubernetes and their status. It is useful for debugging if there is an issue with any of the workloads.

![](docs/assets/images/kx.as.code_openlens.png)

### KX.AS.CODE Management with the KX.AS.CODE Portal (ALPHA)

The KX.AS.CODE portal makes adding and removing applications easier, and provides status on current installed items.

![](docs/assets/images/kx.as.code_portal.png)

### KX.AS.CODE Portal - Applications

Applications and be removed and added from the KX.AS.CODE Portal's application screen.

![](docs/assets/images/kx.as.code_portal_applications.png)

### KX.AS.CODE Portal - Application Groups

Applications can be installed in integrated groups.

![](docs/assets/images/kx.as.code_portal_application_groups.png)

