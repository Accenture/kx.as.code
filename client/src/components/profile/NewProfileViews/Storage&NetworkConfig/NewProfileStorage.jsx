import React, { useReducer } from "react";
import "./NewProfileStorage.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { NewProfileTemplate } from "../../index";
import Counter from '../../../ReusableComponent/Counter/Counter.js'
import Cards from '../../../ReusableComponent/Card/Cards'
import { TextBox, } from "../../../ReusableComponent/index";
import { connect } from "react-redux";
import { setNetworkConfig } from "../../../../redux/actions";

const NewProfileStorage = (props) => {
    const storageConfig = require("../../../ReusableComponent/CardMocks/StorageConfig.json");
    const initialNetworkState = props.networkConfig;
    const [networkConfig, setNetworkConfig] = useReducer(
        (state, newState) => ({...state, ...newState}),
        initialNetworkState
     )
     const handleChange = (e) => {
       const name = e.target.name;
       const newValue = e.target.value;
       setNetworkConfig({[name]: newValue}, props.setNetworkConfig(networkConfig))
     }
    return (
        <NewProfileTemplate>
            <Box
                display="flex"
                flexDirection="row"
                justifyContent="center"
                alignItems="flex-start"
            >
                <Grid container direction="column" justify="flex-start" alignItems="center" id="storage-container">
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
                        <label htmlFor="MainNodeIP">Main Node Ip Address</label>
                    </Grid>
                    <Grid item>
                        <TextBox 
                            name="MainNodeIP" 
                            type="text" 
                            className='text-input3' 
                            placeholder="             -          -          -                 "
                            onChange={handleChange}
                            value={networkConfig.MainNodeIP}
                        />
                    </Grid>
                    <Grid item>
                        <label htmlFor="WorkerNode1IP">Worker Node 1 Ip Address</label>
                    </Grid>
                    <Grid item>
                        <TextBox 
                            name="WorkerNode1IP" 
                            type="text" 
                            className='text-input3' 
                            placeholder="             -          -          -                 "
                            onChange={handleChange}
                            value={networkConfig.WorkerNode1IP} 
                        />
                    </Grid>
                    <Grid item>
                        <label htmlFor="WorkerNode2IP">Worker Node 2 Ip Address</label>
                    </Grid>
                    <Grid item>
                        <TextBox 
                            name="WorkerNode2IP" 
                            className="text-input3" 
                            type="text" 
                            placeholder="             -          -          -                 "
                            onChange={handleChange}
                            value={networkConfig.WorkerNode2IP}
                         />
                    </Grid>
                    <Grid item>
                        <label htmlFor="SecondaryDNS">Secondary DNS Server</label>
                    </Grid>
                    <Grid item>
                        <TextBox 
                            name="SecondaryDNS" 
                            className="text-input3" 
                            type="text" 
                            placeholder="           8    .   8   .    8   .   8         "
                            onChange={handleChange}
                            value={networkConfig.SecondaryDNS} 
                        />
                    </Grid>
                    <Grid item>
                        <label htmlFor="Gateway">Gateway</label>
                    </Grid>
                    <Grid item>
                        <TextBox 
                            name="Gateway" 
                            type="text" 
                            className="text-input3" 
                            placeholder="             -          -          -                 " 
                            onChange={handleChange}
                            value={networkConfig.Gateway}    
                        />
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
                        <label htmlFor="">Kubernetes Load Balance Range</label>
                        <br>
                        </br>
                        <label htmlFor="start" className="titlecustom">Start</label>
                        <TextBox 
                            name="start" 
                            className="text-input2" 
                            type="text" placeholder="      10    .    100    .    76    .    10"
                            onChange={handleChange} value={networkConfig.start}
                        />
                    </Grid>
                    <Grid item>
                        <label htmlFor="end" className="titlecustom">End </label>
                        <TextBox 
                            name="end" 
                            className="text-input2" 
                            type="text" placeholder="      10    .    100    .    76    .    60"
                            onChange={handleChange} 
                            value={networkConfig.end}
                        />
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
                        <label htmlFor="HTTPProxy">HTTP Proxy</label>
                    </Grid>
                    <Grid item>
                        <TextBox name="HTTPProxy" className="text-input3" type="text" onChange={handleChange} value={networkConfig.HTTPProxy}  />
                    </Grid>
                    <Grid item>
                        <label htmlFor="HTTPSProxy">HTTPS Proxy</label>
                    </Grid>
                    <Grid item>
                        <TextBox name="HTTPSProxy" className="text-input3" type="text"  onChange={handleChange} value={networkConfig.HTTPSProxy}/>
                    </Grid>
                    <Grid item>
                        <label htmlFor="NoProxy">No Proxy</label>
                    </Grid>
                    <Grid item>
                        <TextBox name="NoProxy" className="text-input3" type="text"  onChange={handleChange} value={networkConfig.NoProxy}/>
                    </Grid>
                </Grid>
 
            </Box>
        </NewProfileTemplate>
    )
}

const mapDispatchToProps = (dispatch) => {
    return {
      setNetworkConfig: (networkConfig) => {
        dispatch(setNetworkConfig(networkConfig))
      }
    }
  }
  const mapStateToProps = state => ({
    networkConfig: state.networkConfigReducer.networkConfig,
    storageConfig: state.storageConfigReducer.storageConfig
  });

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(NewProfileStorage));