import React from "react";
import { Box } from "@material-ui/core";
import "./NewProfileSteps.scss";
import { UIView } from "../../../redux/reducers/viewsReducer";

const NewProfileSteps = (props) => {
  const currentView = props.view;
  return (
      <Box id="new-prof-gen-steps-container">
        <Box className="horizontal-line"></Box>
        <Box
          id="new-prof-gen-steps"
          display="flex"
          flexDirection="row"
          justifyContent="space-between"
          alignItems="flex-start"
        >
          <Box className="step1">
            {currentView===UIView.General &&<Box id="current-step1"></Box>}
          </Box>
          <Box className="step2">
            {currentView===UIView.Resource &&<Box id="current-step2"></Box>}
          </Box>
          <Box className="step3">
            {currentView===UIView.Storage &&<Box id="current-step4"></Box>}
          </Box>
          <Box className="step4">
            {currentView===UIView.Optional &&<Box id="current-step3"></Box>}
          </Box>
          <Box className="step5">
            {((currentView===UIView.Review) || (currentView===UIView.ReviewA)) &&<Box id="current-step5"></Box>}
          </Box>
        </Box>
        <Box
          id="new-prof-gen-step-labels"
          display="flex"
          flexDirection="row"
          justifyContent="space-between"
          alignItems="flex-start"
        >
          <Box className="step1-label">General configurations</Box>
          <Box className="step2-label">Resource configurations</Box>
          <Box className="step3-label">Storage & Network configurations </Box>
          <Box className="step4-label">Optional configurations</Box>
          <Box className="step5-label">Review & Launch</Box>
        </Box>
      </Box>
  );
};

export default NewProfileSteps;