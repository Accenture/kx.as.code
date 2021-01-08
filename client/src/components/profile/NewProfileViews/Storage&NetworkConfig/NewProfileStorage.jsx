import React from "react";
import "./NewProfileStorage.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { NewProfileTemplate } from "../../index";
import Counter from '../../../ReusableComponent/Counter/Counter.js'
import Cards from '../../../ReusableComponent/Card/Cards'
import { TextBox, DropDown, CustomizedCheckbox } from "../../../ReusableComponent/index";

const NewProfileStorage = () => {
    const storageConfig = require("../../../ReusableComponent/CardMocks/StorageConfig.json");
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
                        <label id="new-title">Gluster FS Storage</label>
                        <label id="new-title2">Main Node Only</label>
                        <Counter max={10} min={1}></Counter>
                    </Grid>
                    <Grid item>
                        <label id="new-title">Local Storage Volumes</label>
                        <label id="new-title2">All Nodes</label>
                        <Counter max={10} min={1} label={'# of 1 GB volumes'}></Counter>
                        <Counter max={10} min={1} label={'# of 5 GB volumes'}></Counter>
                        <Counter max={10} min={1} label={'# of 10 GB volumes'}></Counter>
                        <Counter max={10} min={1} label={'# of 15 GB volumes'}></Counter>
                        <Counter max={10} min={1} label={'# of 30 GB volumes'}></Counter>
                    </Grid>
                    <br></br>
                    <br></br>
                    <Grid item>
                        <label id="new-title">Networking</label>
                        <label id="new-title2">Main Node Only</label>
                    </Grid>
                    <br></br>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Main Node Ip Address</label>
                        {/* <IPut style={{width:"100% !important"}} name="ipAddress" /> */}
                    </Grid>
                    <Grid item>
                        <TextBox htmlFor="new-prof-gen-form-base-password" type="text" className='text-input3' placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Worker Node 1 Ip Address</label>
                        {/* <IPut style={{width:"100% !important"}} name="ipAddress" /> */}
                    </Grid>
                    <Grid item>
                        <TextBox htmlFor="new-prof-gen-form-base-password" type="text" className='text-input3' placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Worker Node 2 Ip Address</label>
                    </Grid>
                    <Grid item>
                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input3" type="text" placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Secondary DNS Server</label>
                    </Grid>
                    <Grid item>
                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input3" type="text" placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Gateway</label>
                    </Grid>
                    <Grid item>
                        <TextBox htmlFor="new-prof-gen-form-base-password" type="text" className="text-input3" placeholder="Default: L3arnandshare" />
                    </Grid>
                </Grid>
                <Grid container direction="column" justify="flex-start" alignItems="center">

                    <Grid>
                        <Box style={{ height: '538px' }}></Box>
                    </Grid>
                    <Grid item>
                        <label id="new-title2">Kubernetes Specific</label>
                    </Grid>
                    <br></br>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">Kubernetes Load Balance Range</label>
                        <br>
                        </br>
                        <label htmlFor="new-prof-gen-form-base-domain" className="titlecustom">Start</label>
                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input2" type="text" placeholder="  .  .  ." />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain" className="titlecustom">End </label>
                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input2" type="text" placeholder="  .  .  ." />
                    </Grid>
                </Grid>
                <Grid container direction="column" justify="flex-start" alignItems="center" >
                    <Grid item style={{position:'relative',right:'200px'}}>
                        <label id="new-title3">Required Capacity Summary</label>
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
                        <Box>
                        <label id="title3">
                            The above is calculated based on the selection made on the left
                        </label>
                        </Box>
                    </Grid>
                    <div style={{ height: "195px" }}></div>
                    <Grid item>
                        <label id="new-title2">Optional Proxy Setting</label>
                    </Grid>
                    <br></br>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">HTTP Proxy</label>
                    </Grid>
                    <Grid item>

                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input3" type="text" placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">HTTPS Proxy</label>
                    </Grid>
                    <Grid item>

                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input3" type="text" placeholder="Default: L3arnandshare" />
                    </Grid>
                    <Grid item>
                        <label htmlFor="new-prof-gen-form-base-domain">No Proxy</label>
                    </Grid>
                    <Grid item>

                        <TextBox htmlFor="new-prof-gen-form-base-password" className="text-input3" type="text" placeholder="Default: L3arnandshare" />
                    </Grid>
                </Grid>
            </Box>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileStorage);