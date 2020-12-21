import React from "react";
import { withRouter } from "react-router";
import "./NewProfileGeneral.scss";
import { Box, Button } from "@material-ui/core";
import intl from "react-intl-universal";
import NewProfileGeneralForm from "./NewProfileGeneralForm";
import { useHistory } from "react-router-dom";

const NewProfileGeneral = () => {
  const history = useHistory();

  return (
    <Box
      id="NewProfileGeneral"
      display="flex"
      flexDirection="column"
      justifyContent="start-flex"
      alignItems="center"
    >
      <Button id="new-prof-profiles-button" onClick={() => history.push("/")}>
        Profiles
      </Button>
      <h1>{intl.get("NEW_PROFILE_GENERAL_TITLE")}</h1>
      <p>{intl.get("NEW_PROFILE_GENERAL_SUBTITLE")}</p>

      <Box id="new-prof-gen-steps-container">
        <Box className="horizontal-line"></Box>
        <Box
          id="new-prof-gen-steps"
          display="flex"
          flexDirection="row"
          justifyContent="space-between"
          alignItems="flex-start"
        >
          <Box className="step1"></Box>
          <Box className="step2"></Box>
          <Box className="step3"></Box>
        </Box>
        <Box
          id="new-prof-gen-step-labels"
          display="flex"
          flexDirection="row"
          justifyContent="space-between"
          alignItems="flex-start"
        >
          <Box className="step1-label">General Configurations</Box>
          <Box className="step2-label">Advanced Configurations</Box>
          <Box className="step3-label">Optional Configurations</Box>
        </Box>
      </Box>

      <NewProfileGeneralForm />
    </Box>
  );
};

export default withRouter(NewProfileGeneral);
