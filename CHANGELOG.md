# Changelog

## [v0.8.13](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.13) (2023-03-05)

[Full Changelog](https://github.com/Accenture/kx.as.code/compare/v0.8.12...v0.8.13)

v0.8.13 is a bumper release with quite a few new features and bug fixes. 
Read the full list below for details.

**Implemented enhancements:**

- Improve validations on launcher script [\#436](https://github.com/Accenture/kx.as.code/issues/436)
- Use DockerHub login if provided to increase rate-limit [\#435](https://github.com/Accenture/kx.as.code/issues/435)
- Ensure K3s respects no-workloads-on-master setting [\#430](https://github.com/Accenture/kx.as.code/issues/430)
- Update Debian Linux to 11.5 [\#428](https://github.com/Accenture/kx.as.code/issues/428)
- Add more keyboard languages \(us,de,it,in,gb,fr,es,cn\) [\#424](https://github.com/Accenture/kx.as.code/issues/424)
- Ensure all logged in desktop users receive notifications [\#422](https://github.com/Accenture/kx.as.code/issues/422)
- Upgrade Remote Desktop applications [\#421](https://github.com/Accenture/kx.as.code/issues/421)
- Create common wrapper function for all script executions [\#412](https://github.com/Accenture/kx.as.code/issues/412)
- Add function to remove control characters from bash variables [\#406](https://github.com/Accenture/kx.as.code/issues/406)
- Remove line numbering in VIM [\#398](https://github.com/Accenture/kx.as.code/issues/398)
- Add central function to search for and download Maven artifacts [\#397](https://github.com/Accenture/kx.as.code/issues/397)
- Enable framework update from Git on start also with credentials [\#395](https://github.com/Accenture/kx.as.code/issues/395)
- Add Lynx for improved readability of API call HTML responses [\#394](https://github.com/Accenture/kx.as.code/issues/394)
- Add script execution duration for statistical purposes and debugging [\#393](https://github.com/Accenture/kx.as.code/issues/393)
- Add function to import custom Grafana dashboards via JSON file [\#390](https://github.com/Accenture/kx.as.code/issues/390)
- Add Prometheus-Stack operator component [\#389](https://github.com/Accenture/kx.as.code/issues/389)
- Allow namespace in Kubernetes YAML files to override component default [\#388](https://github.com/Accenture/kx.as.code/issues/388)
- Add JProfiler for JVM profiling [\#387](https://github.com/Accenture/kx.as.code/issues/387)
- Enable AWS EC2 management agent [\#386](https://github.com/Accenture/kx.as.code/issues/386)
- Create central function for command execution and associated error handling [\#385](https://github.com/Accenture/kx.as.code/issues/385)
- Enable installation to resume where it left off after script failure [\#384](https://github.com/Accenture/kx.as.code/issues/384)
- Enable notifications to Slack, E-Mail and Microsoft Teams [\#383](https://github.com/Accenture/kx.as.code/issues/383)

**Fixed bugs:**

- Cannot install K8s as apt-key no longer valid [\#432](https://github.com/Accenture/kx.as.code/issues/432)
- Harbor install fails when Keycloak not installed [\#420](https://github.com/Accenture/kx.as.code/issues/420)
- Secret salt file not generated on Windows [\#417](https://github.com/Accenture/kx.as.code/issues/417)
- Launched from portal tasks don't execute [\#415](https://github.com/Accenture/kx.as.code/issues/415)
- Helm persistence setting is breaking Grafana install [\#413](https://github.com/Accenture/kx.as.code/issues/413)
- Grafana desktop icon missing for Prometheus-Stack [\#411](https://github.com/Accenture/kx.as.code/issues/411)
- Grafana-Loki datasource and dashboard not imported into new Prometheus-Stack [\#410](https://github.com/Accenture/kx.as.code/issues/410)
- Graphite Helm install fails due to invalid ingress apiVersion [\#409](https://github.com/Accenture/kx.as.code/issues/409)
- Web health check fails if not all optional parameters passed [\#407](https://github.com/Accenture/kx.as.code/issues/407)
- Framework update fails as repository directory deemed not safe [\#405](https://github.com/Accenture/kx.as.code/issues/405)
- External DNS resolution not working inside Kubernetes pods [\#404](https://github.com/Accenture/kx.as.code/issues/404)
- SKEL directory not consistent across all scripts [\#403](https://github.com/Accenture/kx.as.code/issues/403)
- Retry for KX-Portal install is not working correctly [\#402](https://github.com/Accenture/kx.as.code/issues/402)
- Function downloadFile\(\) retry mechanism not working correctly [\#401](https://github.com/Accenture/kx.as.code/issues/401)
- checkUrlHealth\(\) fails if not all optional parameters passed [\#400](https://github.com/Accenture/kx.as.code/issues/400)
- KDE windows on desktop unmovable in NoMachine Remote Desktop [\#399](https://github.com/Accenture/kx.as.code/issues/399)
- VSCode desktop shortcut icon no longer shows [\#396](https://github.com/Accenture/kx.as.code/issues/396)
- Kubernetes YAML file validation fails for custom resources [\#392](https://github.com/Accenture/kx.as.code/issues/392)
- Running pods check not correct when "Evicted" pods present [\#391](https://github.com/Accenture/kx.as.code/issues/391)



