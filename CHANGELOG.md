# Changelog

## [Unreleased](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.15)

[Full Changelog](https://github.com/Accenture/kx.as.code/compare/v0.8.15...HEAD)

Many enhancements to the framework, multiple solutions added and upgraded. See below for full details.

## [v0.8.15](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.15) (2023-10-01)

[Full Changelog](https://github.com/Accenture/kx.as.code/compare/v0.8.14...v0.8.15)

**Implemented enhancements:**

- Upgrade Docker-Compose to v2.20.3 [\#587](https://github.com/Accenture/kx.as.code/issues/587)
- Add OpenVPN client [\#585](https://github.com/Accenture/kx.as.code/issues/585)
- Add Authelia Authentication and Authorization Portal [\#584](https://github.com/Accenture/kx.as.code/issues/584)
- Add pause\(\) function [\#583](https://github.com/Accenture/kx.as.code/issues/583)
- Enable GoPass groups for technical accounts [\#581](https://github.com/Accenture/kx.as.code/issues/581)
- Modify kubernetesGetServiceLoadBalancerIp\(\) to enable "cluster-ip" and "lb-ingress-ip" [\#580](https://github.com/Accenture/kx.as.code/issues/580)
- Change baseUser to have UID=1000 for improved permission handling [\#579](https://github.com/Accenture/kx.as.code/issues/579)
- Update checkApplicationInstalled\(\) to return error is 5xx is returned [\#578](https://github.com/Accenture/kx.as.code/issues/578)
- Add function for generating launch scripts for defined "Tasks" [\#577](https://github.com/Accenture/kx.as.code/issues/577)
- Add function for creating Prometheus Service Monitor [\#576](https://github.com/Accenture/kx.as.code/issues/576)
- Improve getProfileConfiguration\(\) to avoid "null" values [\#575](https://github.com/Accenture/kx.as.code/issues/575)
- Add function for cleanly exporting a Kubernetes resource [\#574](https://github.com/Accenture/kx.as.code/issues/574)
- Add function for scaling deployments up and down [\#573](https://github.com/Accenture/kx.as.code/issues/573)
- Add functions for managing Guacamole users [\#568](https://github.com/Accenture/kx.as.code/issues/568)
- Add pull-secret for local docker-registry to each namespace [\#567](https://github.com/Accenture/kx.as.code/issues/567)
- Improve display of execution duration times [\#566](https://github.com/Accenture/kx.as.code/issues/566)
- Enable alternative application health-check URL [\#565](https://github.com/Accenture/kx.as.code/issues/565)
- Allow alternative primary DNS server to be specified [\#564](https://github.com/Accenture/kx.as.code/issues/564)
- Add log rotation to avoid running out of disk space [\#563](https://github.com/Accenture/kx.as.code/issues/563)
- Add log cleanup for sensitive data [\#562](https://github.com/Accenture/kx.as.code/issues/562)
- Add OAUTH proxy for Keycloak redirect [\#561](https://github.com/Accenture/kx.as.code/issues/561)
- Add Python3 [\#560](https://github.com/Accenture/kx.as.code/issues/560)
- Add PyCharm [\#559](https://github.com/Accenture/kx.as.code/issues/559)
- Upgrade Postman to 10.13.6 [\#558](https://github.com/Accenture/kx.as.code/issues/558)
- Add PGAdmin [\#557](https://github.com/Accenture/kx.as.code/issues/557)
- Upgrade IntelliJ to 2023.2.2 [\#556](https://github.com/Accenture/kx.as.code/issues/556)
- Add AWSSAMCLI Tool [\#555](https://github.com/Accenture/kx.as.code/issues/555)
- Add AWSCLI tool [\#554](https://github.com/Accenture/kx.as.code/issues/554)
- Upgrade Remote Desktop Services [\#553](https://github.com/Accenture/kx.as.code/issues/553)
- Add ingress resources for kx-portal and remote-desktop [\#552](https://github.com/Accenture/kx.as.code/issues/552)
- Upgrade NGINX Ingress Controller to v1.9.0 [\#551](https://github.com/Accenture/kx.as.code/issues/551)
- Upgrade MetalLB to v0.13.10 [\#550](https://github.com/Accenture/kx.as.code/issues/550)
- Upgrade Keycloak to v17 [\#549](https://github.com/Accenture/kx.as.code/issues/549)
- Add "Tasks" for managing Docker Registry [\#548](https://github.com/Accenture/kx.as.code/issues/548)
- Upgrade Calico to v3.26.1 [\#547](https://github.com/Accenture/kx.as.code/issues/547)
- Create log and error handling wrapper for scripts and functions [\#546](https://github.com/Accenture/kx.as.code/issues/546)
- Update Ingress Resource Annotation [\#545](https://github.com/Accenture/kx.as.code/issues/545)

**Fixed bugs:**

- Sometimes kxAsCodeQueuePoller.service hangs on restart [\#589](https://github.com/Accenture/kx.as.code/issues/589)
- Some CIS hardening scripts breaking KX.AS.CODE [\#588](https://github.com/Accenture/kx.as.code/issues/588)
-  NVIM theme not working correctly [\#586](https://github.com/Accenture/kx.as.code/issues/586)
- pruneDockerRegistry\(\) fails if there are no images to prune [\#582](https://github.com/Accenture/kx.as.code/issues/582)
- Kubeval fails for some resource types [\#572](https://github.com/Accenture/kx.as.code/issues/572)
- Additional users not able to access Remote Desktop [\#571](https://github.com/Accenture/kx.as.code/issues/571)
- Desktop notification failures due to missing display for some users [\#570](https://github.com/Accenture/kx.as.code/issues/570)
- Some notifications fail due to special characters [\#569](https://github.com/Accenture/kx.as.code/issues/569)



