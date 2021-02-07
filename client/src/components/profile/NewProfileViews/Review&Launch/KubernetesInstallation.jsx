import React from 'react';
import { withRouter } from "react-router";
import "./KubernetesInstallation.scss";
import { Box, Grid } from "@material-ui/core";
import avatarIcon from "../../../../media/images/common/kubernetes.png";
import { NewProfileTemplate } from "../../index";
import NewProfileReview1 from "./NewProfileReview1";
import NewProfileReview2 from "./NewProfileReview2";
import { Cards } from "../../../ReusableComponent/index";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { connect } from "react-redux";

const KubernetesInstallation = (props) => {

    const installedData1 = [
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


    ];
    const installedData2 = [
        {
            name: "Local Storage",
            status: "",
            progress: "Install Pending"
        },
        {
            name: "GlusterFS Storage",
            status: "",
            progress: "Install Pending"
        },
        {
            name: "NgINX Inprogress Controller",
            status: "",
            progress: "Install Pending"
        },
        {
            name: "Metrics Server",
            status: "",
            progress: "Install Pending"
        },
        {
            name: "Kubernetes DashBoard",
            status: "",
            progress: "Install Pending"
        },

    ]

    return (
        <Box
            display="flex"
            flexDirection="column"
            justifyContent="center"
            alignItems="flex-start"
        >
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
                    <span>{installedData1.length + installedData2.length} Applications Installing</span>
                    <span className="installTime">Remaining for completion - 00:12:59</span>
                </div>
                <Box
                    display="flex"
                    flexDirection="row"
                    justifyContent="center"
                    alignItems="flex-start"
                >
                    <Grid container direction="column" >
                        <Grid id="grid1" item>
                            {
                                installedData1.map((data) => (
                                    <>
                                        <Box className="applicationCard" key={data} >
                                            <div className="app1">

                                                <FontAwesomeIcon icon="info-circle" />
                                                <img className="icons" src={String(avatarIcon)} />
                                                <div>
                                                    <span className="installConfirm" >{data.name}</span>
                                                    {
                                                        data.status === "spinner" ?
                                                            <FontAwesomeIcon className="font-icon-progress" icon="spinner" /> :
                                                            <b><span className="installStatus" >{data.status}</span></b>
                                                    }
                                                </div>
                                                <div>
                                                    <span >{data.progress}</span>
                                                </div>
                                            </div>
                                        </Box>
                                    </>
                                ))
                            }

                        </Grid>
                    </Grid>

                    <Grid container direction="column" >
                        <Grid id="grid2" item>
                            {
                                installedData2.map((data) => (
                                    <>
                                        <Box className="applicationCard" key={data}>
                                            <div className="app2" >

                                                <FontAwesomeIcon icon="info-circle" />
                                                <img className="icons" src={String(avatarIcon)} />
                                                <div >
                                                    <div>
                                                        <span className="installConfirm">{data.name}</span>
                                                        {
                                                            data.status === "spinner" ?
                                                                <FontAwesomeIcon className="font-icon-progress" icon="spinner" /> :
                                                                <b><span className="installStatus" >{data.status}</span></b>
                                                        }
                                                    </div>
                                                    <div>
                                                        <span >{data.progress}</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </Box>
                                    </>
                                ))
                            }
                        </Grid>
                    </Grid>
                </Box>
            </div>
        </Box>

    )
};

const mapStateToProps = state => ({
    generalConfig: state.generalConfigReducer.generalConfig,
});

export default connect(mapStateToProps, null)(withRouter(KubernetesInstallation));
