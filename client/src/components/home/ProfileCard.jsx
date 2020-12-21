import React from "react";
import "./ProfileCard.scss";
import { Box, Button } from "@material-ui/core";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

const ProfileCard = (props) => (
  <Box
    className="ProfileCard"
    display="flex"
    flexDirection="row"
    justifyContent="space-between"
    alignItems="flex-start"
  >
    <Box
      className="info-column"
      display="flex"
      flexDirection="column"
      justifyContent="space-between"
      alignItems="flex-start"
    >
      <span>{props.subVmCategory}</span>
      <span>{props.profileName}</span>
      <span>{props.domainName}</span>
      <span>{props.ipAddress}</span>
    </Box>
    <Box
      className="action-column"
      display="flex"
      flexDirection="column"
      justifyContent="flex-end"
      alignItems="flex-end"
    >
      <Button className="prof-card-btn-duplicate">DUPLICATE</Button>
      <Button className="prof-card-btn-delete">DELETE</Button>
      <Button className="prof-card-btn-chevron-right">
        <FontAwesomeIcon icon="chevron-right" />
      </Button>
    </Box>
  </Box>
);

export default ProfileCard;
