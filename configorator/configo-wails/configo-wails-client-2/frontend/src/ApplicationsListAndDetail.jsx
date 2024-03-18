import React, { useState, useEffect, useRef } from 'react';
import applicationsJson from './assets/templates/applications.json';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import JSONConfigTabContent from './JSONConfigTabContent';
import { ListItemCardApplication } from './ListItemCardApplication';

import {
    getPanelElement,
    getPanelGroupElement,
    getResizeHandleElement,
    Panel,
    PanelGroup,
    PanelResizeHandle,
} from "react-resizable-panels";
import ApplicationSelection from './ApplicationSelection';
import { FilterInput } from './FilterInput';
import { InfoBox } from './InfoBox';
import InputField from './InputField';
import AppLogo from './AppLogo';
import Add from '@mui/icons-material/Add';
import { Delete } from '@mui/icons-material';


export function ApplicationsListAndDetail({ setJsonData, applicationGroupDetailTab, setApplicationGroupDetailTab, windowHeight,
    defaultLayout = [30, 70] }) {

    const initialData = [
        {
            "name": "argocd",
            "namespace": "argocd",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "imageTag": "v2.4.8"
            },
            "minimum_resources": {
                "cpu": "1000",
                "memory": "3000"
            },
            "helm_params": {
                "repository_url": "https://argoproj.github.io/argo-helm",
                "repository_name": "argo/argo-cd",
                "helm_version": "4.10.5",
                "set_key_values": [
                    "global.image.tag={{imageTag}}",
                    "installCRDs=false",
                    "configs.secret.argocdServerAdminPassword='{{argoCdAdminPassword}}'",
                    "controller.clusterAdminAccess.enabled=true",
                    "server.clusterAdminAccess.enabled=true",
                    "server.extraArgs[0]=--insecure"
                ]
            },
            "categories": [
                "gitops"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes",
            "shortcut_text": "Argo CD",
            "shortcut_icon": "argocd.png",
            "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/swagger-ui",
            "api_docs_url": "https://argoproj.github.io/argo-cd/developer-guide/api-docs/",
            "vendor_docs_url": "https://argoproj.github.io/argo-cd/",
            "pre_install_scripts": [
                "installArgoCdCli.sh",
                "createArgoCdPassword.sh",
                "createIngressObjects.sh"
            ],
            "post_install_scripts": [
                "deployOauth2.sh"
            ]
        },
        {
            "name": "artifactory",
            "namespace": "artifactory",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "appVersion": "7.41.4"
            },
            "helm_params": {
                "repository_url": "https://charts.jfrog.io",
                "repository_name": "jfrog/artifactory-oss",
                "helm_version": "107.41.4",
                "set_key_values": []
            },
            "categories": [
                "artifact-repository",
                "docker-registry"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/artifactory/api/system/ping",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "OK",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/artifactory/api/system/ping",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "OK",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "JFrog Artifactory is a universal DevOps solution providing end-to-end automation and management of binaries and artifacts through the application delivery process",
            "shortcut_text": "Artifactory",
            "shortcut_icon": "artifactory.png",
            "api_docs_type": "web",
            "api_docs_url": "https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API",
            "vendor_docs_url": "https://www.jfrog.com/confluence/display/JFROG/JFrog+Artifactory",
            "pre_install_scripts": [
                "createPasswords.sh"
            ],
            "post_install_scripts": [
                "configureJfrogArtifactory.sh",
                "changeAdminPassword.sh"
            ]
        },
        {
            "name": "consul",
            "namespace": "consul",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "consulVersion": "1.11.3",
                "consulK8sVersion": "0.41.1"
            },
            "helm_params": {
                "repository_url": "https://helm.releases.hashicorp.com",
                "repository_name": "hashicorp/consul",
                "helm_version": "0.41.1",
                "set_key_values": []
            },
            "categories": [
                "service-discovery",
                "service-mesh"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Consul is a free and open-source service networking platform developed by HashiCorp",
            "shortcut_text": "HashiCorp Consul",
            "shortcut_icon": "consul.png",
            "api_docs_type": "web",
            "api_docs_url": "",
            "vendor_docs_url": "",
            "pre_install_scripts": [
                "setDatacenterVariable.sh"
            ],
            "post_install_scripts": []
        },
        {
            "name": "gitea",
            "namespace": "gitea",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "imageTag": "1.16.5"
            },
            "helm_params": {
                "repository_url": "https://dl.gitea.io/charts/",
                "repository_name": "gitea-charts/gitea",
                "helm_version": "5.0.4",
                "set_key_values": []
            },
            "categories": [
                "git-repository",
                "oauth-provider"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Gitea is a community managed lightweight code hosting solution written in Go.",
            "shortcut_text": "Gitea",
            "shortcut_icon": "gitea.png",
            "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/devcenter-api-2.0",
            "api_docs_url": "https://docs.gitea.io/en-us/api-usage/",
            "vendor_docs_url": "https://docs.gitea.io/",
            "pre_install_scripts": [
                "createPasswords.sh"
            ],
            "post_install_scripts": []
        },
        {
            "name": "gitlab",
            "namespace": "gitlab",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "minimum_resources": {
                "cpu": "1000",
                "memory": "3000"
            },
            "environment_variables": {
                "gitlabVersion": "v14.10.4",
                "gitabRunnerVersion": "v14.10.1",
                "s3BucketsToCreate": "gitlab-artifacts-storage;gitlab-backup-storage;gitlab-lfs-storage;gitlab-packages-storage;gitlab-registry-storage;gitlab-uploads-storage;runner-cache",
                "gitlabDindImageVersion": "19.03.13-dind"
            },
            "helm_params": {
                "repository_url": "https://charts.gitlab.io/",
                "repository_name": "gitlab/gitlab",
                "helm_version": "5.10.4",
                "set_key_values": [
                    "global.hosts.domain={{baseDomain}}",
                    "global.hosts.externalIP={{nginxIngressIp}}",
                    "global.image.imagePullSecrets[0]=gitlab-image-pull-secret",
                    "externalUrl=https://{{componentName}}.{{baseDomain}}",
                    "global.edition=ce",
                    "prometheus.install=false",
                    "global.smtp.enabled=false",
                    "gitlab-runner.install=true",
                    "gitlab-runner.image=docker-registry.{{baseDomain}}/devops/gitlab-runner:alpine-{{gitabRunnerVersion}}",
                    "gitlab-runner.imagePullSecrets[0].name=gitlab-image-pull-secret",
                    "gitlab-runner.runners.privileged=true",
                    "gitlab-runner.runners.imagePullSecrets[0]=gitlab-image-pull-secret",
                    "gitlab-runner.certsSecretName=kx.as.code-wildcard-cert",
                    "global.ingress.class=nginx",
                    "global.ingress.enabled=true",
                    "global.ingress.tls.enabled=true",
                    "gitlab.webservice.ingress.tls.secretName=kx.as.code-wildcard-cert",
                    "nginx-ingress.enabled=false",
                    "global.certmanager.install=false",
                    "certmanager.install=false",
                    "global.ingress.configureCertmanager=false",
                    "global.hosts.https=true",
                    "global.minio.enabled=false",
                    "registry.enabled=false",
                    "global.appConfig.lfs.bucket=gitlab-lfs-storage",
                    "global.appConfig.lfs.connection.secret=object-storage",
                    "global.appConfig.lfs.connection.key=connection",
                    "global.appConfig.artifacts.bucket=gitlab-artifacts-storage",
                    "global.appConfig.artifacts.connection.secret=object-storage",
                    "global.appConfig.artifacts.connection.key=connection",
                    "global.appConfig.uploads.connection.secret=object-storage",
                    "global.appConfig.uploads.bucket=gitlab-uploads-storage",
                    "global.appConfig.uploads.connection.key=connection",
                    "global.appConfig.packages.bucket=gitlab-packages-storage",
                    "global.appConfig.packages.connection.secret=object-storage",
                    "global.appConfig.packages.connection.key=connection",
                    "global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage",
                    "global.appConfig.externalDiffs.connection.secret=object-storage",
                    "global.appConfig.externalDiffs.connection.key=connection",
                    "global.appConfig.pseudonymizer.bucket=gitlab-pseudonymizer-storage",
                    "global.appConfig.pseudonymizer.connection.secret=object-storage",
                    "global.appConfig.pseudonymizer.connection.key=connection",
                    "redis.resources.requests.cpu=10m",
                    "redis.resources.requests.memory=64Mi",
                    "global.rails.bootsnap.enabled=false",
                    "gitlab.webservice.minReplicas=1",
                    "gitlab.webservice.maxReplicas=1",
                    "gitlab.webservice.resources.limits.memory=3G",
                    "gitlab.webservice.requests.cpu=100m",
                    "gitlab.webservice.requests.memory=900M",
                    "gitlab.workhorse.resources.limits.memory=100M",
                    "gitlab.workhorse.requests.cpu=10m",
                    "gitlab.workhorse.requests.memory=10M",
                    "gitlab.sidekiq.minReplicas=1",
                    "gitlab.sidekiq.maxReplicas=1",
                    "gitlab.sidekiq.resources.limits.memory=3G",
                    "gitlab.sidekiq.requests.cpu=50m",
                    "gitlab.sidekiq.requests.memory=625M",
                    "gitlab.gitlab-shell.minReplicas=1",
                    "gitlab.gitlab-shell.maxReplicas=1",
                    "gitlab.toolbox.backups.objectStorage.config.secret=s3cmd-config",
                    "gitlab.toolbox.backups.objectStorage.config.key=config",
                    "gitlab.gitaly.persistence.storageClass=kadalu.storage-pool-1",
                    "gitlab.gitaly.persistence.size=10Gi",
                    "postgresql.persistence.storageClass=local-storage-sc",
                    "postgresql.persistence.size=5Gi",
                    "redis.master.persistence.storageClass=local-storage-sc",
                    "redis.master.persistence.size=5Gi",
                    "global.certificates.customCAs[0].secret=intermediate-ca",
                    "global.certificates.customCAs[1].secret=root-ca",
                    "global.certificates.customCAs[2].secret=server-crt"
                ]
            },
            "categories": [
                "git-repository",
                "docker-registry",
                "cicd",
                "wiki",
                "issue-tracking"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/-/readiness",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": ".status",
                                "json_value": "ok"
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/-/readiness",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": ".status",
                                "json_value": "ok"
                            }
                        }
                    }
                }
            ],
            "Description": "GitLab is an open source end-to-end software development platform with built-in version control, issue tracking, code review, CI/CD, and more",
            "shortcut_text": "Gitlab",
            "shortcut_icon": "gitlab.png",
            "api_docs_type": "help",
            "api_docs_url": "https://{{componentName}}.{{baseDomain}}/help/api/api_resources.md",
            "vendor_docs_url": "https://docs.gitlab.com/ce/",
            "pre_install_scripts": [
                "buildAndPushCustomRunnerImageToCoreRegistry.sh",
                "getVariables.sh",
                "createS3Buckets.sh",
                "createSecrets.sh",
                "createOAuth.sh"
            ],
            "post_install_scripts": [
                "createLoginToken.sh",
                "createUsers.sh",
                "createGroups.sh",
                "createProjects.sh",
                "mapUsersToGroups.sh",
                "populateDemoProjects.sh",
                "createGroupVariables.sh"
            ]
        },
        {
            "name": "harbor",
            "namespace": "harbor",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "helm_params": {
                "repository_url": "https://helm.goharbor.io",
                "repository_name": "harbor/harbor",
                "helm_version": "1.9.3",
                "set_key_values": [
                    "persistence.enabled=true",
                    "persistence.persistentVolumeClaim.registry.storageClass=local-storage-sc",
                    "persistence.persistentVolumeClaim.registry.size=9Gi",
                    "persistence.persistentVolumeClaim.chartmuseum.size=5Gi",
                    "persistence.persistentVolumeClaim.chartmuseum.storageClass=kadalu.storage-pool-1",
                    "persistence.persistentVolumeClaim.database.size=5Gi",
                    "persistence.persistentVolumeClaim.database.storageClass=local-storage-sc",
                    "persistence.persistentVolumeClaim.redis.storageClass=local-storage-sc",
                    "persistence.persistentVolumeClaim.jobservice.storageClass=kadalu.storage-pool-1",
                    "persistence.persistentVolumeClaim.trivy.storageClass=kadalu.storage-pool-1",
                    "expose.type=ingress",
                    "expose.ingress.annotations.\"kubernetes\\.io/ingress\\.class\"=nginx",
                    "externalURL=https://{{componentName}}.{{baseDomain}}",
                    "expose.ingress.hosts.core={{componentName}}.{{baseDomain}}",
                    "expose.ingress.hosts.notary=notary.{{baseDomain}}",
                    "expose.tls.enabled=true",
                    "expose.tls.certSource=secret",
                    "expose.tls.caBundleSecretName=kx.as.code-wildcard-cert",
                    "expose.tls.caSecretName=kx.as.code-wildcard-cert",
                    "expose.tls.secretName=kx.as.code-wildcard-cert",
                    "expose.tls.notarySecretName=kx.as.code-wildcard-cert",
                    "harborAdminPassword=\"{{harborAdminPassword}}\"",
                    "expose.ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/proxy-body-size\"=\"10000m\"",
                    "logLevel=debug"
                ]
            },
            "categories": [
                "docker-registry",
                "helm-repository"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/api/v2.0/ping",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "Pong",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/api/v2.0/ping",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "Pong",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Harbor is an open source registry that secures artifacts with policies and role-based access control, ensures images are scanned and free from vulnerabilities, and signs images as trusted.",
            "shortcut_text": "Harbor",
            "shortcut_icon": "harbor.png",
            "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/devcenter-api-2.0",
            "api_docs_url": "https://goharbor.io/docs/2.1.0/build-customize-contribute/configure-swagger/",
            "vendor_docs_url": "https://goharbor.io/docs",
            "pre_install_scripts": [
                "createSecret.sh",
                "createHarborAdminPassword.sh"
            ],
            "post_install_scripts": [
                "createProjects.sh",
                "createRobotAccounts.sh",
                "createGitlabGroupVariables.sh",
                "deployOidc.sh"
            ]
        },
        {
            "name": "jenkins",
            "namespace": "jenkins",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "imageTag": "2.332.1-jdk11"
            },
            "helm_params": {
                "repository_url": "https://charts.jenkins.io",
                "repository_name": "jenkins/jenkins",
                "helm_version": "3.11.8",
                "set_key_values": []
            },
            "categories": [
                "cicd",
                "job-scheduling",
                "cron"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/login",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/login",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "The leading open source automation server, Jenkins provides hundreds of plugins to support building, deploying and automating any project.",
            "shortcut_text": "Jenkins",
            "shortcut_icon": "jenkins.png",
            "api_docs_url": "https://www.jenkins.io/doc/book/using/remote-access-api/",
            "vendor_docs_url": "https://www.jenkins.io/doc/",
            "pre_install_scripts": [
                "createSecret.sh"
            ],
            "post_install_scripts": []
        },
        {
            "name": "nexus3",
            "namespace": "nexus3",
            "installation_type": "helm",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "imageTag": "3.38.0"
            },
            "helm_params": {
                "repository_url": "https://sonatype.github.io/helm3-charts/",
                "repository_name": "sonatype/nexus-repository-manager",
                "helm_version": "38.0.0",
                "set_key_values": []
            },
            "categories": [
                "artifact-repository",
                "docker-registry"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/service/rest/v1/status",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/service/rest/v1/status",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Nexus3 manages binaries and build artifacts across your software supply chain.",
            "shortcut_text": "Nexus3 OSS",
            "shortcut_icon": "nexus3.png",
            "swagger_docs_url": "https://{{componentName}}.{{baseDomain}}/#admin/system/api",
            "api_docs_url": "https://help.sonatype.com/repomanager3/rest-and-integration-api",
            "vendor_docs_url": "https://help.sonatype.com/repomanager3",
            "pre_install_scripts": [],
            "post_install_scripts": []
        },
        {
            "name": "teamcity",
            "namespace": "teamcity",
            "installation_type": "script",
            "installation_group_folder": "cicd",
            "environment_variables": {
                "teamcityVersion": "2021.2.3"
            },
            "install_scripts": [
                "installTeamCity.sh"
            ],
            "categories": [
                "cicd"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/mnt",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "TeamCity is a continuous integration server that integrates with all major IDEs, version control and issue tracking systems, and can be used by teams of any size.",
            "shortcut_text": "Teamcity",
            "shortcut_icon": "teamcity.png",
            "pre_install_scripts": [
                "createGitProject.sh",
                "populateGitProject.sh",
                "rebuildDockerImage.sh"
            ],
            "post_install_scripts": []
        },
        {
            "name": "confluence",
            "namespace": "atlassian",
            "installation_type": "script",
            "installation_group_folder": "collaboration",
            "install_scripts": [
                "installConfluence.sh"
            ],
            "categories": [
                "collaboration",
                "wiki"
            ],
            "urls": [
                {
                    "url": "https://{{componentName}}.{{baseDomain}}",
                    "healthchecks": {
                        "liveliness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        },
                        "readiness": {
                            "http_path": "/",
                            "http_auth_required": false,
                            "expected_http_response_code": "200",
                            "expected_http_response_string": "",
                            "expected_json_response": {
                                "json_path": "",
                                "json_value": ""
                            },
                            "health_shell_check_command": "",
                            "expected_shell_check_command_response": ""
                        }
                    }
                }
            ],
            "Description": "Confluence is a team workspace where knowledge and collaboration meet. Trusted for documentation, decisions, project collaboration & Jira integrations.",
            "shortcut_text": "Atlassian Confluence",
            "shortcut_icon": "confluence.png",
            "pre_install_scripts": [
                "createGitProject.sh",
                "populateGitProject.sh"
            ],
            "post_install_scripts": []
        }
    ];

    const [searchTerm, setSearchTerm] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isListLayout, setIsListLayout] = useState(true);

    const [data2, setData2] = useState(applicationsJson);
    const [selectedItem, setSelectedItem] = useState(0);

    const refs = useRef();

    // *********** New Functions START ***********
    const handleItemClick = (index) => {
        setSelectedItem(index);
    };

    const handleInputChange = (field, value) => {
        setData2((prevData) => {
            const newData = [...prevData];
            newData[selectedItem][field] = value;
            return newData;
        });
    };

    const handleAddNewItem = () => {
        const existingApplications = data2.filter((obj) => obj.name.startsWith('New Application'));

        let nextNumber = 1;
        const existingNumbers = existingApplications.map((obj) => {
            const match = obj.name.match(/\d+$/);
            return match ? parseInt(match[0]) : 0;
        });
        while (existingNumbers.includes(nextNumber)) {
            nextNumber++;
        }

        const newObject = {
            name: `New Application ${nextNumber}`,
            Description: '',
        };

        setData2((prevData) => {
            const newData = [...prevData, newObject];
            setSelectedItem(newData.length - 1);
            return newData;
        });
    };

    const handleAddApplication = (app) => {
        console.log("app: ", app)
        setData2((prevData) => {
            const newData = [...prevData];
            newData[selectedItem].action_queues.install.push({ install_folder: app.installation_group_folder, name: app.name });
            return newData;
        });
    };

    const handleRemoveApplication = (app) => {
        setData2((prevData) => {
            const newData = [...prevData];
            const indexToRemove = newData[selectedItem].action_queues.install.findIndex(item => item.name === app.name);

            if (indexToRemove !== -1) {
                newData[selectedItem].action_queues.install.splice(indexToRemove, 1);
            }

            return newData;
        });
    };

    const handleDeleteItem = (index) => {
        setData2((prevData) => {
            const newData = [...prevData];
            newData.splice(index, 1);
            if (selectedItem === index) {
                setSelectedItem(selectedItem - 1);
            }
            return newData;
        });
    };

    const generateUniqueTitle = (title, newData) => {
        let newTitle = "";
        newTitle = title !== "" ? newTitle = title + "-COPY" : "No Titel-COPY"
        let count = 1;

        while (newData.some(item => item.name === newTitle || item.name.startsWith(newTitle + '-'))) {
            count++;
            newTitle = title + `-COPY (${count})`;
        }
        return newTitle;
    };

    const handleDublicateItem = (index) => {
        setData2((prevData) => {
            const newData = [...prevData];
            const itemToDuplicate = newData[index];

            const duplicatedItem = { ...itemToDuplicate };

            duplicatedItem.name = generateUniqueTitle(duplicatedItem.name, newData);

            newData.splice(index + 1, 0, duplicatedItem);

            return newData;
        });
    };
    // *********** New Functions END ***********

    const updateFieldInJsonObjectById = (id, fieldName, value) => {
        const updatedArray = JSON.parse(JSON.stringify(applicationsJson));
        const targetObject = updatedArray.find((obj) => obj.id === id);
        if (targetObject) {
            targetObject[fieldName] = value;
        }
        return updatedArray;
    };

    const removeApplicationGroupById = (id) => {
        const updatedData = data.filter((item) => item.id !== id);
        setData(updatedData)
        const updatedJsonString = JSON.stringify(updatedData, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    const handleKeyDown = (e) => {
        if (e.key === 'ArrowUp' && selectedItem > 0) {
            handleItemClick(selectedItem - 1);
        } else if (e.key === 'ArrowDown' && selectedItem < data2.length - 1) {
            handleItemClick(selectedItem + 1);
        }
    };

    useEffect(() => {
        const groupElement = getPanelGroupElement("group");
        const leftPanelElement = getPanelElement("left-panel");
        const rightPanelElement = getPanelElement("right-panel");
        const resizeHandleElement = getResizeHandleElement("resize-handle");

        refs.current = {
            groupElement,
            leftPanelElement,
            rightPanelElement,
            resizeHandleElement,
        };

        const listElement = document.getElementById('list');
        listElement.scrollTop = selectedItem * 50;

        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener('keydown', handleKeyDown);
        };
    }, [data2, applicationsJson, windowHeight, selectedItem]);

    const drawApplicationGroupCards = () => {
        const filteredData = data2.filter((application) => {
            const lowerCaseName = (application.name || "").toLowerCase();
            return searchTerm === "" || lowerCaseName.includes(searchTerm.toLowerCase().trim());
        });

        if (filteredData.length === 0) {
            if (searchTerm !== "") {
                return (
                    <InfoBox>
                        <div className='ml-1'>No results found for "{searchTerm}".</div>
                    </InfoBox>
                );
            }
            else {
                return (
                    <InfoBox>
                        <div className='ml-1'>No available Applications.</div>
                    </InfoBox>
                );
            }
        }

        return filteredData
            .map((application, index) => (
                <ListItemCardApplication itemData={application} isListLayout={isListLayout} index={index} selectedItem={selectedItem} handleItemClick={handleItemClick} handleDeleteItem={handleDeleteItem} handleDublicateItem={handleDublicateItem} />
            ));
    };


    const addApplicationToApplicationGroupById = (id, newApplicationObject) => {
        setData((prevData) => {
            return prevData.map((group) => {
                if (group.id === id) {
                    const isExisting = group.action_queues.install.some((obj) => obj.name === newApplicationObject.name);

                    if (!isExisting) {
                        group.action_queues.install = [...group.action_queues.install, newApplicationObject];
                    }
                }
                return group;
            });
        });

        const updatedJsonString = JSON.stringify(data, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    return (
        <div id='config-ui-container' className='flex flex-col'>
            <PanelGroup direction="horizontal" id="group" className="tab-content dark:text-white text-black flex-1">
                <Panel defaultSize={defaultLayout[0]} id="left-panel" className='min-w-[250px]'>

                    {/* Search Input Field with filter button */}
                    <FilterInput setSearchTerm={setSearchTerm} searchTerm={searchTerm} itemsCount={data2.length} itemName={"Applications"} hasActionButton={true} actionFunction={handleAddNewItem} />
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack2 overflow-y-scroll px-2 py-3 custom-scrollbar" style={{ height: `${windowHeight - 103 - 67 - 40 - 67}px` }} id="list">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawApplicationGroupCards()}
                    </div>
                </Panel>
                <PanelResizeHandle id="resize-handle" className='w-1 hover:bg-kxBlue bg-ghBlack2' />
                <Panel defaultSize={defaultLayout[1]} id="right-panel" className="min-w-[300px]">
                    {/* <ApplicationGroupsModal isOpen={modalIsOpen} onRequestClose={closeModal} applicationGroupTitle={detailsObject.title} applicationGroup={detailsObject} addApplicationToApplicationGroupById={addApplicationToApplicationGroupById} /> */}

                    <div className={` ${applicationGroupDetailTab == "config-ui" ? "bg-ghBlack2" : "bg-ghBlack2"} overflow-y-scroll custom-scrollbar pt-0`} style={{ height: `${windowHeight - 103 - 40 - 53}px` }}>

                        {/* Application Group Details JSON View Toggle */}
                        <div className="sticky top-0 dark:bg-ghBlack2" style={{ zIndex: "10" }}>
                            <div className='flex itmes-center text-sm '>
                                <button
                                    onClick={() => { setApplicationGroupDetailTab("config-ui") }}
                                    className={` ${applicationGroupDetailTab == "config-ui" ? 'border-kxBlue border-b-3 bg-ghBlack4 text-white' : 'border-ghBlack2 hover:border-ghBlack4 border-b-3 hover:bg-ghBlack3'} px-3 py-0 text-gray-400 hover:text-white`}
                                >
                                    Config UI
                                </button>
                                <button
                                    onClick={() => { setApplicationGroupDetailTab("json") }}
                                    className={` ${applicationGroupDetailTab == "json" ? 'border-kxBlue border-b-3 bg-ghBlack4 text-white' : 'border-ghBlack2 border-b-3 hover:border-ghBlack4 hover:bg-ghBlack3'} px-3 py-0 text-gray-400 hover:text-white`}
                                >
                                    JSON
                                </button>
                            </div>
                        </div>

                        {selectedItem !== null && data2[selectedItem] && (

                            applicationGroupDetailTab == "config-ui" ? (
                                <div className='px-3'>

                                    <div className="pt-3">

                                        {/* Details Actions Header */}
                                        <div className='flex justify-end'>

                                        </div>
                                        <div className="bg-ghBlack3 h-[120px] w-[120px] rounded-sm mb-3 mx-auto" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                                            <AppLogo appName={data2[selectedItem].name} size={90} className="" />
                                        </div>

                                        <InputField inputType={"input"} type={"text"} placeholder={"Add an Application name"} dataKey={"application_name"} label={"Application Name"} value={data2[selectedItem].name}/>

                                        <InputField inputType={"textarea"} type={"text"} placeholder={"Add an Application Description"} dataKey={"application_desc"} label={"Application Description"} value={data2[selectedItem].Description} />

                                        <InputField inputType={"input"} type={"text"} placeholder={"Add a Namespace"} dataKey={"application_namespace"} label={"Namespace"} value={data2[selectedItem].namespace} />

                                        <InputField inputType={"input"} type={"text"} placeholder={"Add an Installation Type"} dataKey={"application_installation_type"} label={"Installation Type"} />

                                        <InputField inputType={"input"} type={"text"} placeholder={"Add an Installation Group Folder"} dataKey={"application_installation_group_folder"} label={"Installation Group Folder"} />

                                        <h2 className='p-2 text-gray-400 font-semibold mb-2 mt-5'>Helm Parameter</h2>
                                        <InputField inputType={"input"} type={"text"} placeholder={"Add an Repository URL"} dataKey={""} label={"Repository URL"} />

                                        <InputField inputType={"input"} type={"text"} placeholder={"Add an Helm version"} dataKey={""} label={"Helm version"} />

                                        <h3 className='p-2 text-gray-400 mb-2 mt-2 border-gray-400 items-center flex justify-center'>
                                            <span>Key values</span>
                                            <button className='p-1 hover:bg-ghBlack4 rounded-sm ml-2 flex justify-center items-center'>
                                                <Add className="text-white" fontSize='small' />
                                            </button>
                                        </h3>
                                        <div className='mb-[100px]'>
                                            <div className='flex items-center'>
                                                <div className='grid grid-cols-12 w-full'>
                                                    <div className="col-span-6">
                                                        <input value={"global.image.tag"} type="text" className='w-full border-gray-600 border p-2 border-r-0 focus:bg-ghBlack4 bg-ghBlack2 focus:outline-none' />
                                                    </div>
                                                    <div className="col-span-6">
                                                        <input value={"v2.4.8"} type="text" className='w-full border-gray-600 border p-2 focus:bg-ghBlack4 bg-ghBlack2 focus:outline-none' />
                                                    </div>
                                                </div>
                                                <div>
                                                    <button className='p-1 hover:bg-ghBlack4 rounded-sm ml-2 flex justify-center items-center'>
                                                        <Delete className="text-white" fontSize='small' />
                                                    </button>
                                                </div>
                                            </div>

                                            <div className='flex items-center'>
                                                <div className='grid grid-cols-12 w-full'>
                                                    <div className="col-span-6">
                                                        <input value={"installCRDs"} type="text" className='w-full border-gray-600 border p-2 border-r-0 focus:bg-ghBlack4 bg-ghBlack2 focus:outline-none border-t-0' />
                                                    </div>
                                                    <div className="col-span-6">
                                                        <input value={"false"} type="text" className='w-full border-gray-600 border p-2 focus:bg-ghBlack4 bg-ghBlack2 focus:outline-none border-t-0' />
                                                    </div>
                                                </div>
                                                <div>
                                                    <button className='p-1 hover:bg-ghBlack4 rounded-sm ml-2 flex justify-center items-center'>
                                                        <Delete className="text-white" fontSize='small' />
                                                    </button>
                                                </div>
                                            </div>
                                        </div>

                                    </div>

                                    <div className="items-center">
                                        {/* <ApplicationSelection applicationGroupTitle={data2[selectedItem].title} applicationGroup={data2[selectedItem]} addApplicationToApplicationGroupById={addApplicationToApplicationGroupById} handleAddApplication={handleAddApplication} handleRemoveApplication={handleRemoveApplication} /> */}
                                    </div>

                                </div>) : (
                                <JSONConfigTabContent jsonData={JSON.stringify(data2[selectedItem], null, 2)} fileName={data2[selectedItem].name} />
                            )
                        )}
                    </div>
                </Panel>
            </PanelGroup>
        </div>
    )
};