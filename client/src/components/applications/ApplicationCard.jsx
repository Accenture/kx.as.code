import React, { Component } from "react";
import "../applications/ApplicationCard.scss";
import { Box, Button } from "@material-ui/core";


class ApplicationCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      payload_data: {},
      queue_name: ""
    }
  }

  componentDidMount(){
    this.setState({
      payload_data: JSON.parse(this.props.item.payload),
      queue_name: this.props.item.routing_key.replace("_"," ").replace(/\b\w/g, l => l.toUpperCase())
    })
  }

  render() {
    return (
      <Box className="AppCard">
        <Box className="info-column" >
          <span>Installation Status: {this.state.queue_name}</span>
          <span>{this.state.payload_data.name}</span>
          <span>Install Folder: {this.state.payload_data.install_folder}</span>
          <span>Retries: {this.state.payload_data.retries}</span>
        </Box>
        <Box className="action-column">

        </Box>
      </Box>
    );
  }
}

export default ApplicationCard;