import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { Cards } from "../../../ReusableComponent/index";
import { connect } from "react-redux";

const NewProfileReview2 = (props) => {
    const preFlightChecks = require("../../../ReusableComponent/CardMocks/PreFlightChecks.json");
    const download = require("../../../ReusableComponent/CardMocks/Download.json");
    const launchStatus = require("../../../ReusableComponent/CardMocks/LaunchStatus.json");
    return (
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
    )
}


const mapStateToProps = state => ({
    generalConfig: state.generalConfigReducer.generalConfig,
});

export default connect(mapStateToProps, null)(withRouter(NewProfileReview2));