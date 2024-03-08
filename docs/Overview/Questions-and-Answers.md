# Questions and Answers

## What is the KX.AS.CODE Workstation?

It can be considered as a local cloud like Kubernetes environment with a lot of things you would expect to see when managing a Kubernetes cluster in the cloud, including an ingress controller, storage cluster, DNS, a certificate authority... and the best bit, you just have to fill out a couple of config files and `vagrant up`/`terraform apply`, and you are on your way!
Currently, KX.AS.CODE fulfills the following use cases:

1. DevOps training environment
2. Fullstack development/DevOps environment
3. A HomeLab DevOps environment! See our Raspberry Pi [build](../Build/Raspberry-Pi-Cluster.md) and [deployment](../Deployment/Raspberry-Pi-Cluster.md) guides!

You can follow our Raspberry Pi enablement progress on our [Discord Raspberry Pi channel](https://discord.gg/XC64HNgeXK){:target="\_blank"}!

![whatsinthebox](../assets/images/whatsinthebox.png)
Note, Kubernetes is now on v1.24. We wil update the image soon.

## Why did we create this workstation?

Many reasons! For our own learning and fun, for enabling others to enjoy and get into DevOps, as well as to give something back to the community, because we and everyone else in DevOps, benefit hugely from the wonderful OpenSource tools that are out there!

Additionally, the machines we use at work or have sitting at home are getting more powerful all the time, and not everyone has access to a cloud account, so lets use the power we have at home or at work to do more! :metal:

## What makes this different to other solutions?

As we originally envisaged this as a DevOps training/enablement environment, we didn't just want to deploy a bunch of empty tools, but to make it feel like a live project environment, with repositories and docker images already populated, and some processes in place, to demonstrate for example, topics such as container runtime security or GitOps.

## Where can I deploy KX.AS.CODE?

KX.AS.CODE can be deployed locally or in the cloud, be it a private or public cloud. The most tested solutions are currently OpenStack and VirtualBox. Here a full list of solutions we have run KX.AS.CODE on.

1. VMWare Workstation/Fusion (MacOSX, Linux and Windows)
2. VirtualBox (MacOSX, Linux and Windows)
3. Parallels (MacOSX)
4. AWS
5. OpenStack
6. VMWare VSphere (needs updating)

## What type of deployments does KX.AS.CODE support?

Depending on how big your laptop, desktop or server is, you can either deploy KX.AS.CODE in standalone mode, which means that everything happens in the one VM, or you can enable it to have multiple worker and main nodes provisioned.

It is possible through configuration, if physical resources are low, to have an additional worker node, and still have workloads started on the Kubernetes master.

## What is the minimal specification?

Whilst we have run it on some laptops with just 8GB ram, you will not have a good experience with this setup, even in standalone mode. The absolute minimum is a laptop/desktop/server with 12GB ram (allocating 8GB to KX.AS.CODE), although to have a good experience, it is recommended the host has at least 16GB ram, so that 12GB can be allocated to KX.AS.CODE.

After that, the more the merrier! 24GB upwards things are starting to look good. The less memory and CPU cores you have, the less solutions/tools you can provision on your Kubernetes cluster.
If you are deploying to the public cloud, then your possibilities are endless, and you can deploy the entire stack - currently around 30 DevOps tools and more to come!

!!! tip
    That said, we just started to bring KX.AS.CODE to the Raspberry Pi, so doing a lot of optimizations to enable KX.AS.CODE on lower spec hardware. See the following [guide](../Deployment/Minimal-Deployment.md) for running KX.AS.CODE in a low spec environment.

## Sounds good! Where can I get the images?

You can either build your own boxes (needed if you customized the solution), or just have Vagrant pull them from the [Vagrant Cloud](https://app.vagrantup.com/kxascode){:target="\_blank"} for you automatically.

Only the VMs for the local virtualization environments (VMWare, VirtualBox, Parallels) can be deployed via Jenkins at the moment. The private and public cloud deployments need some command line love, but it's as easy as changing into the directory and executing `terraform apply` (after modifying the base parameters in profile-config.json).

## Where is the solution now?

I guess it will never be "finished". DevOps is a fast paced world with lots of great tools coming out all the time. KX.AS.CODE was created and continues to be worked on as a side project by some very passionate and dedicated DevOps Engineers at Accenture Song ASG, who have not lost their appetite for learning and trying new tools, so expect more releases to come in future! :partying_face:
