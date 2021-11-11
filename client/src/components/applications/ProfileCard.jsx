import React from "react";
import { Box, Button } from "@material-ui/core";
import { FontAwesomeIcon } from ""

const ProfileCard = (props) => (
  <Box className="ProfileCard">
    <Box className="info-column" >
      <span></span>
      <span></span>
      <span></span>
      <span>Lorem</span>
    </Box>
    <Box className="action-column">
      <Button className="prof-card-btn-duplicate">DUPLICATE</Button>
      <Button className="prof-card-btn-delete">DELETE</Button>
      <Button className="prof-card-btn-chevron-right">
        <FontAwesomeIcon icon="chevron-right" />
      </Button>
    </Box>
  </Box>
);

export default ProfileCard;
