import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { NewProfileTemplate } from "../../index";
import { Cards } from "../../../ReusableComponent/index";
import { connect } from "react-redux";

const NewProfileReview = (props) => {
    const generalConfig = Object.entries(props.generalConfig);
    const networkConfig = Object.entries(require("../../../ReusableComponent/CardMocks/NetworkConfig.json"));
    const storageConfig = require("../../../ReusableComponent/CardMocks/StorageConfig.json");
    return (
        <NewProfileTemplate>
            <Box
                id="new-prof-review-container"
                display="flex"
                flexDirection="row"
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
            </Box>
        </NewProfileTemplate>
    )
}


const mapStateToProps = state => ({
    generalConfig: state.generalConfigReducer.generalConfig,
  });

export default connect(mapStateToProps, null)(withRouter(NewProfileReview));