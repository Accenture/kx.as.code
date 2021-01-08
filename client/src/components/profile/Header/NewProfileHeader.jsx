import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import { NewProfileSteps } from "../index"
import "./NewProfileHeader.scss";
import { useHistory } from "react-router-dom";
import intl from "react-intl-universal";
import { connect } from "react-redux";
import { setDefaultView, setGeneralConfig } from "../../../redux/actions";



const config = {
  profileColor: "",
  profileName: "",
  teamName: "",
  profileType: "",
  kubernetesSeesionTimeout: false,
  profileSubType: "",
  baseDomain: "",
  defaultUser: "",
  defaultPassword: "",
  certificationMode: false,
}

const NewProfileHeader = (props) => {
  const history = useHistory();
  const handleClick = () => {
    props.setDefaultView();
    props.setGeneralConfig(config)
    history.push("/");
  };
  return (
    <Box id="new-profile-header">
        <Button id="new-prof-profiles-button" onClick={handleClick}>
            Profiles
        </Button>
        <h1>{intl.get("NEW_PROFILE_GENERAL_TITLE")}</h1>
        <p id="para">{intl.get("NEW_PROFILE_GENERAL_SUBTITLE")}</p>
        <NewProfileSteps view={props.view}/>
      </Box>
  );
};

const mapDispatchToProps = (dispatch) => {
  return {
    setDefaultView: () => {
          dispatch(setDefaultView())
    },
    setGeneralConfig: (generalConfig) => {
        dispatch(setGeneralConfig(generalConfig))
    }
  }
}



export default connect(null, mapDispatchToProps)(withRouter(NewProfileHeader));