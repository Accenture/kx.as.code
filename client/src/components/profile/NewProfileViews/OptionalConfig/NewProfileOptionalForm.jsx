import React, { useState, useReducer } from 'react';
import { withRouter } from "react-router";
import "./NewProfileOptionalForm.scss";
import { Box, Grid } from "@material-ui/core";
import { TextBox } from "../../../ReusableComponent/index";
import { connect } from "react-redux";
import { setOptionalConfig, setPrimaryColor } from "../../../../redux/actions";

const NewProfileOptionalForm = (props) => {
    const [activeColor, setActiveColor] = useState(props.primaryColor);
    const initialState = props.config;
    const [optionalConfig, setOptionalConfig] = useReducer(
        (state, newState) => ({...state, ...newState}),
        initialState)
    const onHandleChange = (e) => {
       const name = e.target.name;
       const newValue = e.target.value;
       setOptionalConfig({[name]: newValue}, props.setOptionalConfig(optionalConfig))
     }; 

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
                    <TextBox htmlFor="new-prof-opt-form-primary-color-selection" placeholder="Hex: #" value={activeColor} name={"primaryColor"}  />
                </Grid>
                <Grid item>
                    <span className={`dot dot-grey ${activeColor == '#3b6e81' ? 'active' : ''}`} onClick={() => setActiveColor('#3b6e81', props.setPrimaryColor(activeColor))}></span>
                    <span className={`dot dot-blue ${activeColor == '#3290d1' ? 'active' : ''}`} onClick={() => setActiveColor('#3290d1', props.setPrimaryColor(activeColor))}></span>
                    <span className={`dot dot-green ${activeColor == '#2ecd73' ? 'active' : ''}`} onClick={() => setActiveColor('#2ecd73', props.setPrimaryColor(activeColor))}></span>
                    <span className={`dot dot-orange ${activeColor == '#e77e23' ? 'active' : ''}`} onClick={() => setActiveColor('#e77e23', props.setPrimaryColor(activeColor))}></span>
                    <span className={`dot dot-yellow ${activeColor == '#ecdf5b' ? 'active' : ''}`} onClick={() => setActiveColor('#ecdf5b', props.setPrimaryColor(activeColor))}></span>
                </Grid>
                <hr className="hz-line" />
                <Grid item className="custom-color">
                    <label className="align-label" htmlFor="new-prof-opt-form-primary-color-selection">Custom Hex Color</label>
                    <span className="dot dot-black"></span>
                </Grid>
            </Grid>

            <Grid container direction="column" justify="flex-start" alignItems="center">
                <Grid item>
                    <label htmlFor="new-prof-opt-form-docker-hub-username">Docker Hub Username</label>
                </Grid>
                <Grid item>
                    <TextBox id="new-prof-opt-form-docker-hub-username"  onChange={onHandleChange} name="dockerHubUserName" value={optionalConfig.dockerHubUserName}/>
                </Grid>
                <Grid item>
                    <label htmlFor="new-prof-opt-form-docker-hub-password">Docker Hub Password</label>
                </Grid>
                <Grid item>
                    <TextBox id="new-prof-opt-form-docker-hub-password" type="password"  onChange={onHandleChange} name="dockerHubPassword" value={optionalConfig.dockerHubPassword}/>
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

const mapDispatchToProps = (dispatch) => {
    return {
        setOptionalConfig: (optionalConfig) => {
        dispatch(setOptionalConfig(optionalConfig))
      },
      setPrimaryColor: (primaryColor) => {
          dispatch(setPrimaryColor(primaryColor))
      }
    }
  }
  const mapStateToProps = state => ({
    config: state.optionalConfigReducer.optionalConfig,
    primaryColor: state.optionalConfigReducer.primaryColor
  });

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(NewProfileOptionalForm));
