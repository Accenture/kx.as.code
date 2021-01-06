import React from "react";
import { Box, Button } from "@material-ui/core";
import { withRouter } from "react-router";
import "./NewProfileFooter.scss";
import { useHistory } from "react-router-dom";
import { UIView } from "../../../redux/reducers/viewsReducer";
import { connect } from "react-redux";
import { setNextView, setLastView } from "../../../redux/actions";
import { Label } from "@material-ui/icons";

const NewProfileHeader = (props) => {
  const history = useHistory();
  const currentView = props.view;
  let path = "/";
  const onClickNext = () => {
    currentView != UIView.ReviewB && props.setNextView();
    currentView === UIView.General && (path = "/new-profile-resource");
    currentView === UIView.Resource && (path = "/new-profile-storage");
    currentView === UIView.Storage && (path = "/new-profile-optional");
    currentView === UIView.Optional && (path = "/new-profile-review");
    currentView === UIView.Review && (path = "/new-profile-reviewA");
    history.push(path);
  }
  const onClickBack = () => {
    props.setLastView();
    currentView === UIView.Resource && (path = "/new-profile-general");
    currentView === UIView.Storage && (path = "/new-profile-resource");
    currentView === UIView.Optional && (path = "/new-profile-storage");
    currentView === UIView.Review && (path = "/new-profile-optional")
    currentView === UIView.ReviewA && (path = "/new-profile-review")
    currentView === UIView.ReviewB && (path = "/new-profile-reviewA")
    history.push(path);
  }
  return (
    <Box id="new-profile-footer"
      textAlign="center">
      {(currentView!= UIView.General) &&
        <Button id="new-prof-profiles-Next-button" onClick={onClickBack}>
          Back
        </Button>
      }
      {(currentView != UIView.ReviewA) && <Button id="new-prof-profiles-Next-button" onClick={onClickNext}>
        {(currentView != UIView.Review) ? "Next" : "Confirm"}
      </Button>}
      {(currentView === UIView.ReviewA) && <label id="loader">WAITING FOR SERVERS TO COME UP</label>}
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
