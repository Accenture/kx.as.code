import React, { useState } from 'react';
import { withRouter } from "react-router";
import "./KubernetesInstallation.scss";
import { Box, Grid } from "@material-ui/core";
import avatarIcon from "../../../../media/images/common/kubernetes.png";
import { NewProfileTemplate } from "../../index";
import { Cards } from "../../../ReusableComponent/index";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

const KubernetesInstallation = () => {

    const installedData = [
        {
            name: "Kubernetes Tools",
            status: "Completed",
            progress: "Installed"
        },
        {
            name: "Base Kubernetes Services",
            status: "Completed",
            progress: "Installed"
        },
        {
            name: "Calico Network",
            status: "Completed",
            progress: "Installed"
        },
        {
            name: "CFSSL Certification Authority",
            status: "spinner",
            progress: "Install in Progress"
        },
        {
            name: "Metal LB Load Balancer",
            status: "",
            progress: "Install Pending"
        },
        {
            name: "Cert Managerr",
            status: "",
            progress: "Install Pending"
        },


    ]

    const generalConfig = Object.entries(require("../../../ReusableComponent/CardMocks/GeneralConfig.json"));
    const networkConfig = Object.entries(require("../../../ReusableComponent/CardMocks/NetworkConfig.json"));
    const storageConfig = require("../../../ReusableComponent/CardMocks/StorageConfig.json");
    const preFlightChecks = require("../../../ReusableComponent/CardMocks/PreFlightChecks.json");
    const download = require("../../../ReusableComponent/CardMocks/Download.json");
    const launchStatus = require("../../../ReusableComponent/CardMocks/LaunchStatus.json");
    return (

        <NewProfileTemplate>
            <Box
                id="new-prof-review-container"
                display="flex"
                flexDirection="column"
                justifyContent="center"
                alignItems="flex-start"
            >
                <Grid container direction="row" justify="flex-start" alignItems="center" id="container-1">
                    <Box>
                        <label id="title">General</label>
                        <Cards card={generalConfig} />
                    </Box>
                    <Box>
                        <label id="title">Networking</label>
                        <Cards card={networkConfig} />
                    </Box>
                    <Box>
                        <label id="title">Storage</label>
                        <Cards >
                            <Box id="main-node">
                                <Box id="card-title">Main Node</Box>
                                {Object.entries(storageConfig.MainNode).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                            <Box id="worker-node">
                                <Box id="card-title">Workers Nodes (x2)</Box>
                                {Object.entries(storageConfig.WorkerNode).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                            <Box>
                                {Object.entries(storageConfig.TOTAL).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                        </Cards>
                    </Box>
                </Grid>

                <Grid container direction="row" justify="flex-start" alignItems="center" id="container-1">
                    <Box>
                        <label id="title">Pre Flight Checks</label>
                        <Cards >
                            <Box id="main-node">
                                <Box id="card-title">Software Dependencies</Box>
                                {Object.entries(preFlightChecks.SoftwareDependencies).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                            <Box id="worker-node">
                                <Box id="card-title">Other Dependencies</Box>
                                {Object.entries(preFlightChecks.OtherDependencies).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                        </Cards>
                    </Box>
                    <Box>
                        <label id="title">Download</label>
                        <Cards >
                            <Box id="main-node">
                                <Box id="card-title">Versions</Box>
                                {Object.entries(download.Versions).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                        </Cards>
                    </Box>
                    <Box>
                        <label id="title">Launch status</label>
                        <Cards >
                            <Box id="main-node">
                                <Box id="card-title">Main Node</Box>
                                {Object.entries(launchStatus["Main Node"]).map(([key, value]) => <Box id="storage-key" key={key}>{key}<span id="storage-value">{value.toString()}</span></Box>)}
                            </Box>
                        </Cards>
                    </Box>
                </Grid>
            </Box>
            <Box className="kubernetesTitle">
                <label id="title">Kubernetes Installation</label>
            </Box>
            <div className="kubernetesContainer">
                <div className="baseTitle">
                    <span>Base Kubernetes Installation</span>
                    <span className="baseInstallProgress">In Progress</span>
                    <div className="progress">
                        <div className="progress-bar" role="progressbar" aria-valuenow="30" aria-valuemin="0" aria-valuemax="100" >
                        </div>
                    </div>

                </div>
                <hr className="hz-line" />
                <div className="installProgress">
                    <span>{installedData.length} Applications Installing</span>
                    <span className="installTime">Remaining for completion - 00:12:59</span>
                </div>
                <Grid container direction="column" justify="flex-start" alignItems="start">
                    <Grid item>
                        {
                            installedData.map(data => (
                                <>
                                    <Box className="applicationCard">
                                        <div>

                                            <FontAwesomeIcon icon="info-circle" />
                                            <img className="icons" src={String(avatarIcon)} />
                                            <div>
                                                <span className="installConfirm">{data.name}</span>
                                                {
                                                    data.status === "spinner" ?
                                                        <FontAwesomeIcon className="font-icon-progress" icon="spinner" /> :
                                                        <b><span className="installStatus">{data.status}</span></b>
                                                }
                                            </div>
                                            <div>
                                                <span>{data.progress}</span>
                                            </div>
                                        </div>
                                    </Box>
                                </>
                            ))
                        }

                    </Grid>
                </Grid>

            </div>
        </NewProfileTemplate>

    )
};

export default withRouter(KubernetesInstallation);