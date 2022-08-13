# History

History is the past, the future is [here](https://accenture.github.io/kx.as.code/Overview/Future-Roadmap/)

## [v0.8.9](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.9) (2022-08-12)
The major focus for this release has been the upgrade of Kubernetes to v1.24, and adding the option to use K3s instead of K8s. See below for other enhancements and bug fixes.

**Implemented enhancements:**

- Improve logging and debugging [\#260](https://github.com/Accenture/kx.as.code/issues/260)
- Add mechanism to automatically pull latest KX.AS.CODE on first boot [\#258](https://github.com/Accenture/kx.as.code/issues/258)
- Upgrade MinIO and migrate from Helm chart to Operator [\#257](https://github.com/Accenture/kx.as.code/issues/257)
- Add K3s and startup mode options to Jenkins based launcher [\#256](https://github.com/Accenture/kx.as.code/issues/256)
- Migrate helper scripts to central callable functions [\#255](https://github.com/Accenture/kx.as.code/issues/255)
- Upgrade OpenLens to 6.0.0 [\#254](https://github.com/Accenture/kx.as.code/issues/254)
- Add NeuVector to application library [\#253](https://github.com/Accenture/kx.as.code/issues/253)
- Allow option to continue processing queue after a component installation fails [\#252](https://github.com/Accenture/kx.as.code/issues/252)
- Add option to use K3s instead of K8s [\#248](https://github.com/Accenture/kx.as.code/issues/248)
- Upgrade Kubernetes from v1.2.1 to v1.2.4 [\#247](https://github.com/Accenture/kx.as.code/issues/247)

**Fixed bugs:**

- CoreDNS not updating correctly with custom server after upgrade to 1.24 [\#259](https://github.com/Accenture/kx.as.code/issues/259)
- Block-device auto selection detected wrong drive [\#251](https://github.com/Accenture/kx.as.code/issues/251)
- SDDM greeter takes up 20% CPU when idle [\#250](https://github.com/Accenture/kx.as.code/issues/250)
- Polling script exits when child script returns RC != 0 [\#249](https://github.com/Accenture/kx.as.code/issues/249)
- Jenkins unable to start using launchLocalBuildEnvironment.ps1 script [\#225](https://github.com/Accenture/kx.as.code/issues/225)

