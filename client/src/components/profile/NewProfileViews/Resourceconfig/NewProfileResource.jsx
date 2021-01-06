import React from "react";
import "./NewProfileResource.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate } from "../../index";
import CustomizedSlider from '../../../ReusableComponent/Sliders/Sliders.js'
import { Box, Grid } from "@material-ui/core";
import CustomizedCheckbox from '../../../ReusableComponent/Checkbox/checkbox'
const NewProfileResource = () => {
    return (
        <NewProfileTemplate>
            <Box
                id="new-prof-gen-form"
                display="flex"
                flexDirection="row"
                justifyContent="center"
                alignItems="flex-start"
            >
                <Grid container direction="column" justify="flex-start" alignItems="center">
                    <Grid item>
                        <label id="new-title">Allocate Physical Resources</label>
                        <Box className="card">
                            <CustomizedSlider defaultValue={0} min={0} max={6} name={'CPU'} size={'6 VCORES'}></CustomizedSlider>
                            <CustomizedSlider defaultValue={0} min={0} max={12} name={'MEMORY'} size={'12 GB'}></CustomizedSlider>
                        </Box>
                    </Grid>
                    <Grid item>
                        <label id="new-title">Distributed Allocated Resources</label>
                        <label id="new-title2">Main Node</label>
                        <Box className="card">

                            <CustomizedSlider defaultValue={0} min={0} max={2} name={'CPU'} size={'2 VCORES'}></CustomizedSlider>
                            <CustomizedSlider defaultValue={0} min={0} max={4} name={'MEMORY'} size={'4 GB'}></CustomizedSlider>
                        </Box>
                    </Grid>
                    <Grid item>
                        <label id="title3">
                            Based on the above choices, you have 4 VCORES and
                        <br>
                            </br>
                        8GB RAM remaining for allocation to worker nodes.
                        </label>
                    </Grid>
                </Grid>
                <Grid container direction="column" justify="flex-start" alignItems="center">
                    <Grid item>
                        <Box className="checkbox">
                            <CustomizedCheckbox />
                            <label id="title3">Allow Kubernetes workloads to be scheduled on the main node</label>
                        </Box>
                    </Grid>
                    <Grid item>
                        <ul className="align-list">
                            <li>Note, this is recommended for lower spec'd.</li>
                            <li>environment that cannot afford a dedicated</li>
                            <li>main node in terms of available resource</li>
                            <li><br></br></li>
                            <li>
                                This will be selected automatically if worker
          </li>
                            <li>nodes to be provisioned is set to 0</li>
                        </ul>
                    </Grid>
                    <br></br>
                    <br></br>
                    <br></br>
                    <Grid>
                        <label id="new-title2">Worker Nodes</label>
                        <Box className="card2">
                            <CustomizedSlider defaultValue={0} min={0} max={2} name={'NUMBER OF WORKER NODES '} size={'2'}></CustomizedSlider>
                        </Box>
                    </Grid>
                    <Grid item>
                        <label id="title3">
                            2 VCORES, 4GB RAM for each worker node
                        </label>
                    </Grid>


                </Grid>
            </Box>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileResource);