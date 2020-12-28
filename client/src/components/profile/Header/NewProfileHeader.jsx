import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import { NewProfileSteps } from "../index"
import "./NewProfileHeader.scss";
import { useHistory } from "react-router-dom";
import intl from "react-intl-universal";


const NewProfileHeader = (props) => {
  const history = useHistory();
  return (
    <Box id="new-profile-header">
        <Button id="new-prof-profiles-button" onClick={() => history.push("/")}>
            Profiles
        </Button>
        <h1>{intl.get("NEW_PROFILE_GENERAL_TITLE")}</h1>
        <p>{intl.get("NEW_PROFILE_GENERAL_SUBTITLE")}</p>
        <NewProfileSteps view={props.view}/>
      </Box>
  );
};

export default withRouter(NewProfileHeader);