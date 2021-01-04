import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import { NewProfileSteps } from "../index"
import "./NewProfileHeader.scss";
import { useHistory } from "react-router-dom";
import intl from "react-intl-universal";
import { connect } from "react-redux";
import { setDefaultView } from "../../../redux/actions";

const NewProfileHeader = (props) => {
  const history = useHistory();
  const handleClick = () => {
    props.setDefaultView();
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
      }
  }
}

export default connect(null, mapDispatchToProps)(withRouter(NewProfileHeader));