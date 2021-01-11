import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { Cards } from "../../../ReusableComponent/index";
import { connect } from "react-redux";

const NewProfileReview1 = (props) => {
    const generalConfig = Object.entries(props.generalConfig);
    const networkConfig = Object.entries(props.networkConfig);
    const storageConfig = props.storageConfig;
    return (
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
    )
}


const mapStateToProps = state => ({
    generalConfig: state.generalConfigReducer.generalConfig,
    networkConfig: state.networkConfigReducer.networkConfig,
    storageConfig: state.storageConfigReducer.storageConfig,
});

export default connect(mapStateToProps, null)(withRouter(NewProfileReview1));