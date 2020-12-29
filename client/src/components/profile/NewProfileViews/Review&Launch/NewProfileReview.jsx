import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { NewProfileTemplate } from "../../index";
import { Cards } from "../../../ReusableComponent/index"

const NewProfileReview = () => {
    const generalConfig = require("../../../ReusableComponent/CardMocks/GeneralConfig.json")
    const networkConfig = require("../../../ReusableComponent/CardMocks/NetworkConfig.json")
    return (
        <NewProfileTemplate>
            <Box
                id="new-prof-review-container"
                display="flex"
                flexDirection="row"
                justifyContent="center"
                alignItems="flex-start"
            >
                <Grid container direction="row" justify="flex-start" alignItems="center" id="container">
                    <Box item >
                        <label id="card-title">General</label>
                        <Cards card={generalConfig}/>
                    </Box>
                    <Box item>
                        <label id="card-title">Networking</label>
                        <Cards card={networkConfig}/>
                    </Box>
                    <Box item>
                        <label id="card-title">Storage</label>
                        <Cards card={networkConfig}/>
                    </Box>
                </Grid>
            </Box>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileReview);