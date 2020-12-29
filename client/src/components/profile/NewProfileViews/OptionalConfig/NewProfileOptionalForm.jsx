import React, { useState } from 'react';
import { withRouter } from "react-router";
import "./NewProfileOptionalForm.scss";
import { Box, Grid } from "@material-ui/core";
import { TextBox } from "../../../ReusableComponent/index";

const NewProfileOptionalForm = () => {
    const [activeColor, setActiveColor] = useState('#3290d1');

    return (
        <Box
            id="new-prof-gen-form"
            display="flex"
            flexDirection="row"
            justifyContent="center"
            alignItems="flex-start"
        >
            <Grid container direction="column" justify="flex-start" alignItems="center">
                <Grid item>
                    <label htmlFor="new-prof-opt-form-primary-color-selection">Primary Color Selection</label>
                </Grid>
                <Grid item>
                    <TextBox htmlFor="new-prof-opt-form-primary-color-selection" placeholder="Hex: #" />
                </Grid>
                <Grid item>
                    <span className={`dot dot-grey ${activeColor == '#3b6e81' ? 'active' : ''}`} onClick={() => setActiveColor('#3b6e81')}></span>
                    <span className={`dot dot-blue ${activeColor == '#3290d1' ? 'active' : ''}`} onClick={() => setActiveColor('#3290d1')}></span>
                    <span className={`dot dot-green ${activeColor == '#2ecd73' ? 'active' : ''}`} onClick={() => setActiveColor('#2ecd73')}></span>
                    <span className={`dot dot-orange ${activeColor == '#e77e23' ? 'active' : ''}`} onClick={() => setActiveColor('#e77e23')}></span>
                    <span className={`dot dot-yellow ${activeColor == '#ecdf5b' ? 'active' : ''}`} onClick={() => setActiveColor('#ecdf5b')}></span>
                </Grid>
                <hr className="hz-line" />
                <Grid item className="custom-color">
                    <label className="align-label" htmlFor="new-prof-opt-form-primary-color-selection">Custom HEX Color</label>
                    <span className="dot dot-black"></span>
                </Grid>
            </Grid>

            <Grid container direction="column" justify="flex-start" alignItems="center">
                <Grid item>
                    <label htmlFor="new-prof-opt-form-docker-hub-username">Docker Hub Username</label>
                </Grid>
                <Grid item>
                    <TextBox id="new-prof-opt-form-docker-hub-username" />
                </Grid>
                <Grid item>
                    <label htmlFor="new-prof-opt-form-docker-hub-password">Docker Hub Password</label>
                </Grid>
                <Grid item>
                    <TextBox id="new-prof-opt-form-docker-hub-password" type="password" />
                </Grid>
                <Grid item>
                    <ul>
                        <li>If you are starting multiple environments, then you may hit Docker limits and your application installations could fail.</li>
                        <a href={"https://docs.docker.com/docker-hub/download-rate-limit/"}>https://docs.docker.com/docker-hub/download-rate-limit/</a>
                    </ul>
                </Grid>
            </Grid>
        </Box>)
};

export default withRouter(NewProfileOptionalForm);
