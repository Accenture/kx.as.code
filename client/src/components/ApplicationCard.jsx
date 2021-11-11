import React, { Component } from "react";
// import "../applications/ApplicationCard.scss";
import { Box, Button, Grid } from "@material-ui/core";
import "./ProfileCard.scss";


class ApplicationCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      payloadData: {},
      queueName: "",
      appName: ""
    }
  }

  componentWillMount() {
    this.setState({
      payloadData: JSON.parse(this.props.item.payload),
      queueName: this.props.item.routing_key.replace("_", " ").replace(/\b\w/g, l => l.toUpperCase()),
      appName: this.props.item
    })
  }

  render() {
    return (
      <Box className="ProfileCard">
        <Box className="info-column" >
          <span>Installation Status: {this.state.queueName}</span>
          <span>{this.state.payloadData.name.replaceAll("-", " ").replace(/\b\w/g, l => l.toUpperCase())}</span>
          <span>Catergory: {this.state.payloadData.install_folder}</span>
          <span>Retries: {this.state.payloadData.retries}</span>
        </Box>
      </Box>
    );
  }
}

export default ApplicationCard;