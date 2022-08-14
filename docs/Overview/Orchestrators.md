# Orchestrators

A most recent change to KX.AS.CODE has been to allow the user to select between `K8s` and `K3s` before starting up KX.AS.CODE. It cannot be changed afterwards - this would require a re-deployment of KX.AS.CODE.

!!! tip
    K3s is recommended for low spec environments.

You can either manually select the orchestrator by editing your profile-config.json, see the Profile Configuration Guide, or select it in the Jenkins based launcher.

In the screenshot of the KX.AS.CODE Launcher below you can see the orchestrator selection box for `K8s` and `K3s`.

![](../assets/images/jenkins_minimal_setup.png){: .zoom}