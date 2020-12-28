import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import "./NewProfileFooter.scss";
import { useHistory } from "react-router-dom";
import { UIView } from "../../../redux/reducers/viewsReducer";
import { connect } from "react-redux";
import { setNextView, setLastView } from "../../../redux/actions";

const NewProfileHeader = (props) => {
  const history = useHistory();
  let currentView = props.view;
  let path = "/";
  const onClickNext = () => {
    currentView != UIView.Review && props.setNextView();
    currentView === UIView.General && (path = "/new-profile-resource");
    currentView === UIView.Resource && (path = "/new-profile-optional");
    currentView === UIView.Optional && (path = "/new-profile-storage");
    currentView === UIView.Storage && (path = "/new-profile-review");
    currentView === UIView.Review && (path = "/new-profile-review");
    history.push(path);
  }
  const onClickBack = () => {
    props.setLastView();
    currentView === UIView.Resource && (path = "/new-profile-general");
    currentView === UIView.Optional && (path = "/new-profile-resource");
    currentView === UIView.Storage && (path = "/new-profile-optional");
    currentView === UIView.Review && (path = "/new-profile-storage")
    history.push(path);
  }
  return (
    <Box id="new-profile-footer"
      textAlign="center">
      {((currentView === UIView.Resource) || (currentView === UIView.Optional) || (currentView === UIView.Storage) || (currentView === UIView.Review)) &&
        <Button id="new-prof-profiles-Next-button" onClick={onClickBack}>
          Back
          </Button>
      }
      <Button id="new-prof-profiles-Next-button" onClick={onClickNext}>
        Next
        </Button>
    </Box>
  );
};

const mapDispatchToProps = (dispatch) => {
  return {
    setNextView: () => {
      dispatch(setNextView())
    },
    setLastView: () => {
      dispatch(setLastView())
    }
  }
}

export default connect(null, mapDispatchToProps)(withRouter(NewProfileHeader));