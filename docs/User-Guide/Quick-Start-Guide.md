# Quick Start Guide

The easiest way to configure and start KX.AS.CODE is via the Jenkins based configurator.

That said, editing the JSON directly is also not so difficult, but comes without the additional help and validations.

As this is a quick start guide, we will concentrate on the Jenkins approach here, and cover the manual start-up and more advanced options in another guide.

!!! note "For your convenience, pre-built KX.AS.CODE images have been uploaded to the Vagrant Cloud. You can find them under the following links:"
    - KX-Main - https://app.vagrantup.com/kxascode/boxes/kx-main
    - KX-Node - https://app.vagrantup.com/kxascode/boxes/kx-node

First you need to clone the KX.AS.CODE Github repository:

```
git clone https://github.com/Accenture/kx.as.code.git
```

Once cloned, change into the `kx.as.code` directory and navigate to the following path:
`base-vm/build/jenkins`

Before launching anything, create a copy of the `jenkins.env_template` file in the same directory, calling it `jenkins.env`.
Optionally, edit this file and amend as required the lines at the top - if for example, you already have something running on port 8080, you might want to change the default port here.
```
jenkins_listen_address = "127.0.0.1"  ## Set to localhost for security reasons
jenkins_server_port = "8080"
```

!!! info "If you are also intending to build KX.AS.CODE images, and not just launch existing public ones in the Vagrant Cloud, then you also need to add your Github.com credentials. This is only needed if building from a private Github.com repository (at time of writing, this is still the case for the main repository)"
    ```
    git_source_username = "change-me"
    git_source_password = "change-me"
    ```

Everything else in the file goes beyond the Quick Start guide, and will be described on other pages.


!!! note "Once the jenkins.env is ready, execute the launch script in order to start the Jenkins KX-Launcher job:"
    ```
    # Mac/Linux
    ./launchLocalBuildEnvironment.sh
    ```
    ```
    # Windows
    .\launchLocalBuildEnvironment.ps1
    ```

Once you receive the confirmation that Jenkins is up, you will receive the URL for accessing the launcher. Open it in your browser of choice.
!!! info "The URL will look something like this:"
    `http://127.0.0.1:8081/job/KX.AS.CODE_Launcher/build?delay=0sec`
    Port and IP may be different depending on changes you made in `jenkins.env`.

![images/jenkins_profile_selection_parallels.png](../images/jenkins_profile_selection_parallels.png)






