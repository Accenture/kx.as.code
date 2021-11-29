import React, { Component } from "react";
// import "../applications/ApplicationCard.scss";
import { Box, Button, Grid } from "@material-ui/core";
import "./ProfileCard.scss";


class ApplicationCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      appName: "",
      queueName: "",
      category: "", 
      retries: 0
    }
  }

  componentWillMount() {
    this.setState({
      appName: this.props.app.appName.replace("_", " ").replace(/\b\w/g, l => l.toUpperCase()),
      queueName: this.props.app.queueName,
      category: this.props.app.category, 
      retries: this.props.app.retries
    })
  }

  render() {
    return (
      <Box className="ProfileCard">
        <Box className="info-column" >
          <span>Installation Status: {this.state.queueName}</span>
          <span>{this.state.appName.replaceAll("-", " ").replace(/\b\w/g, l => l.toUpperCase())}</span>
          <span>Catergory: {this.state.category}</span>
          <span>Retries: {this.state.retries}</span>
        </Box>
      </Box>
    );
  }
}

export default ApplicationCard;