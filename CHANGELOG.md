# Changelog

## [v0.8.11](https://github.com/Accenture/kx.as.code/releases/tag/v0.8.11) (2022-09-18)

[Full Changelog](https://github.com/Accenture/kx.as.code/compare/v0.8.10...v0.8.11)

v0.8.11 is a bumper release with quite a few new features and bug fixes. A major new feature is the ability to execute "tasks" against a "component" once it has been installed (for example, "purge deleted images" in the "docker-registry" component). Tasks are defined in the component's metadata,json.  The client KX-Portal also received a number of updates, including the ability to launch the new tasks.
Read the full list below for more details.

**Implemented enhancements:**

- Remember startup-mode and orchestrator settings in Jenkins launcher [\#337](https://github.com/Accenture/kx.as.code/issues/337)
- Replace Typora with OpenSource alternative [\#335](https://github.com/Accenture/kx.as.code/issues/335)
- Add more dev tools, such as IntelliJ and Azure Data Studio [\#331](https://github.com/Accenture/kx.as.code/issues/331)
- Make it visible on application cards when an app has available tasks [\#329](https://github.com/Accenture/kx.as.code/issues/329)
- Allow variable substitutions for metadata.json environment variables [\#328](https://github.com/Accenture/kx.as.code/issues/328)
- Get version number dynamically from versions.json [\#326](https://github.com/Accenture/kx.as.code/issues/326)
- Add logLevel option to profile settings [\#322](https://github.com/Accenture/kx.as.code/issues/322)
- Add individually executable "tasks" after solution deployed [\#320](https://github.com/Accenture/kx.as.code/issues/320)
- Allow custom variables to be passed to VM via profile [\#318](https://github.com/Accenture/kx.as.code/issues/318)
- Add authentication option to downloadFile function [\#315](https://github.com/Accenture/kx.as.code/issues/315)
- Improve security for transferring credentials into VM [\#314](https://github.com/Accenture/kx.as.code/issues/314)
- Jenkins launcher to accept repo names other than kx.as.code [\#312](https://github.com/Accenture/kx.as.code/issues/312)
- Allow override of central functions with custom ones [\#302](https://github.com/Accenture/kx.as.code/issues/302)
- Add ability to customize background & logo [\#301](https://github.com/Accenture/kx.as.code/issues/301)
- Add basic UI frontend to core Docker-Registry component [\#300](https://github.com/Accenture/kx.as.code/issues/300)
- Application components not consistent when description text not all of same length [\#279](https://github.com/Accenture/kx.as.code/issues/279)
- Hide core components in GUI unless selected [\#278](https://github.com/Accenture/kx.as.code/issues/278)

**Fixed bugs:**

- Messages not ending up on notification\_queue [\#323](https://github.com/Accenture/kx.as.code/issues/323)
- Cannot delete docker images from registry via UI [\#321](https://github.com/Accenture/kx.as.code/issues/321)
- Git checkout not working if user is email address [\#311](https://github.com/Accenture/kx.as.code/issues/311)
- KX.AS.CODE auto-update source on first start not working [\#306](https://github.com/Accenture/kx.as.code/issues/306)
- Blank screen in KX-Portal from page 4 onwards [\#280](https://github.com/Accenture/kx.as.code/issues/280)



