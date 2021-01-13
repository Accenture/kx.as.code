import React from "react";
import { useHistory } from "react-router-dom";
import { withRouter } from "react-router";
import "./ListApplication.scss";
import { Box, Button, Grid } from "@material-ui/core";
import { InstalledCard } from "../../../ReusableComponent/index"

const ListApplication = () => {
    const listData = require("../../../ReusableComponent/CardMocks/InstalledListCard.json");
    return (
        <div id="home-header">
            <Box className="header-group">
                <Box className="header-group-right">
                    <label className="header-group-right-label">Available Memory : 12GB</label>
                    <br />
                    <label className="header-group-right-label">Disk Space Usage : 8GB</label>
                </Box>
                <b><h1>Application Groups</h1></b>
                <p>What groups do you want to Install into your KX.AS.CODE environement?</p>
            </Box>
            <Box className="header-group1">
                <Button className="header-group1-button">
                    SuperGroup01
                </Button>
                <Button className="header-group2-button">
                    SuperGroup02
                </Button>
                <Button className="header-group2-button">
                    SuperGroup03
                </Button>
            </Box>
            <Grid container direction="row" justify="flex-start" alignItems="center" id="container-1">
                {

                    listData.map(data => (
                        <>
                            <Box>
                                <InstalledCard data={data}>
                                </InstalledCard>
                            </Box>
                        </>

                    ))
                }
            </Grid>

        </div>
    )

}

export default withRouter(ListApplication);