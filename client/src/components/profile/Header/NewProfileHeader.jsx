import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import { NewProfileSteps } from "../index"
import "./NewProfileHeader.scss";
import { useHistory } from "react-router-dom";
import intl from "react-intl-universal";
import { connect } from "react-redux";
import { setDefaultView, setGeneralConfig, setOptionalConfig, setNetworkConfig, setStorageConfig } from "../../../redux/actions";

export const initialOptionalConfig = {
  dockerHubUserName: "",
  dockerHubPassword: "",   
}
const initialGeneralConfig = {
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

const initialNetworkConfig = {
  "MainNodeIP": "",
  "WorkerNode1IP": "",
  "WorkerNode2IP": "",
  "Gateway": "",
  "SecondaryDNS": "",
  "end": "",
  "HTTPProxy": "not defined",
  "HTTPSProxy": "not defined",
  "NoProxy": "not defined"  
}

const initialStorageConfig = {
  "MainNode": {
      "GlusterFS Storage": "20 GB",
      "Local volumes": "200 GB"
  },
  "WorkerNode": {
      "Local volumes": "200 GB"
  },
  "TOTAL": {
      "OVERALLTOTAL": "400 GB"
  }
}


const NewProfileHeader = (props) => {
  const history = useHistory();
  const handleClick = () => {
    props.setDefaultView();
    props.setGeneralConfig(initialGeneralConfig)
    props.setOptionalConfig(initialOptionalConfig)
    props.setNetworkConfig(initialNetworkConfig)
    props.setStorageConfig(initialStorageConfig)
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
    },
    setOptionalConfig: (optionalConfig) => {
      dispatch(setOptionalConfig(optionalConfig))
    },
    setNetworkConfig: (networkConfig) => {
      dispatch(setNetworkConfig(networkConfig))
    },setStorageConfig: (storageConfig) => {
      dispatch(setStorageConfig(storageConfig))
    }

  }
}



export default connect(null, mapDispatchToProps)(withRouter(NewProfileHeader));