import React, { useReducer } from "react";
import { withRouter } from "react-router";
import "./NewProfileGeneralForm.scss";
import { Box, Grid } from "@material-ui/core";
import { TextBox, DropDown, CustomizedCheckbox } from "../../../ReusableComponent/index";
import { connect } from "react-redux";
import { setGeneralConfig } from "../../../../redux/actions";


const NewProfileGeneralForm = (props) => {
  const initialState = props.config;
  const [generalConfig, setGeneralConfig] = useReducer(
     (state, newState) => ({...state, ...newState}),
     initialState
  )
  const handleChange = (e) => {
    const name = e.target.name;
    const newValue = e.target.value;
    setGeneralConfig({[name]: newValue}, props.setGeneralConfig(generalConfig))
  }
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
          <label htmlFor="new-prof-gen-form-profile-name">Profile Name*</label>
        </Grid>
        <Grid item>
          {/* <Input id="new-prof-gen-form-profile-name" type="text" /> */}
          <TextBox name="profileName" onChange={handleChange} value={generalConfig.profileName}/>
        </Grid>
        <Grid item>
          <label htmlFor="new-prof-gen-form-team-name">Team Name</label>
        </Grid>
        <Grid item>
          {/* <Input id="new-prof-gen-form-team-name" type="text" /> */}
          <TextBox name="teamName" onChange={handleChange} value={generalConfig.teamName}/>
        </Grid>
        <Grid item>
          <label htmlFor="new-prof-gen-form-ssl-provider">Profile Type*</label>
        </Grid>
        <Grid item>
          <DropDown
            data={["Local Virtualization"]}
            id="new-prof-gen-form-ssl-provider"
            name="profileType"
            onChange={handleChange}
            value={generalConfig.profileType}/>
        </Grid>
        <Grid item>
          <label htmlFor="new-prof-gen-form-platform-selection-type">
            Profile Sub Type*
        </label>
        </Grid>
        <Grid item>
          <DropDown
            data={["VMWare", "VirtualBox", "Parallels"]}
            id="new-prof-gen-form-ssl-provider"
            name="profileSubType"
            onChange={handleChange}
            value={generalConfig.profileSubType}
          />
        </Grid>
        <Grid item>
          <CustomizedCheckbox name="kubernetesSeesionTimeout" onChange={handleChange} value={generalConfig.kubernetesSeesionTimeout}/>
          <label >Disable Kubernetes Session Timeout</label>
        </Grid>
      </Grid>

      <Grid container direction="column" justify="flex-start" alignItems="center">
        <Grid item>
          <label htmlFor="new-prof-gen-form-base-domain">Base Domain</label>
        </Grid>
        <Grid item>
          <TextBox  placeholder="Default: kx-as-code.local" name="baseDomain" onChange={handleChange} value={generalConfig.baseDomain}/>
        </Grid>
        <Grid item>
          <label htmlFor="new-prof-gen-form-base-user">Default User</label>
        </Grid>
        <Grid item>
          <TextBox name="defaultUser" onChange={handleChange}  placeholder="Default: kx.hero" value={generalConfig.defaultUser}/>
        </Grid>
        <Grid item>
          <label htmlFor="new-prof-gen-form-base-password">Default Password</label>
        </Grid>
        <Grid item>
          <TextBox name="defaultPassword" onChange={handleChange}type="password" placeholder="Default: L3arnandshare" value={generalConfig.defaultPassword}/>
        </Grid>
        <Grid item>
          <ul className="align-list">
            <li>At least 8 characters—the more characters, the better.</li>
            <li>A mixture of both uppercase and lowercase letters.</li>
            <li>A mixture of letters and numbers.</li>
            <li>
              Inclusion of at least one special character, e.g., ! @ # ? ] Note:
              do not use &lt; or &gt; in your password, as both can cause problems
              in Web browsers.
          </li>
          </ul>
        </Grid>
        <Grid item >
          <CustomizedCheckbox name="certificationMode" onChange={handleChange} value={generalConfig.certificationMode}/>
          <label >Certification Mode</label>
        </Grid>
      </Grid>

    </Box>
  );
}

const mapDispatchToProps = (dispatch) => {
  return {
    setGeneralConfig: (generalConfig) => {
      dispatch(setGeneralConfig(generalConfig))
    }
  }
}
const mapStateToProps = state => ({
  config: state.generalConfigReducer.generalConfig
});

export default connect(mapStateToProps, mapDispatchToProps)(withRouter(NewProfileGeneralForm));
