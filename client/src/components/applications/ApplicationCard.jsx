import React, { Component } from "react";
import "../applications/ApplicationCard.scss";
import { Box, Button } from "@material-ui/core";


class ApplicationCard extends Component {
  constructor(props) {
    super(props);
    this.state = {}
  }
  render() {
    return (
      <Box className="AppCard">
        <Box className="info-column" >
          <span>Application Type</span>
          <span>Application Name</span>
          <span>Lorem Ipsum</span>
          <span>Lorem Ipsum</span>
        </Box>
        <Box className="action-column">

        </Box>
      </Box>
    );
  }
}

export default ApplicationCard;