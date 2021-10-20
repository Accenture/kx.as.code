import React, { Component } from "react";
import "../applications/ApplicationCard.scss";
import { Box, Button, Grid } from "@material-ui/core";


class ApplicationCard extends Component {
  constructor(props) {
    super(props);
    this.state = {
      payloadData: {},
      queueName: "",
      appName: ""
    }
  }

  componentWillMount(){
    this.setState({
      payloadData: JSON.parse(this.props.item.payload),
      queueName: this.props.item.routing_key.replace("_"," ").replace(/\b\w/g, l => l.toUpperCase()),
      appName: this.props.item
    })
  }

  render() {
    return (
      <Grid item xs={6} className="application-card-wrapper">
        <div className="application-card-info">
          <div>Installation Status: {this.state.queueName}</div>
          <div>{this.state.payloadData.name.replaceAll("-"," ").replace(/\b\w/g, l => l.toUpperCase())}</div>
          <div>Install Folder: {this.state.payloadData.install_folder}</div>
          <div>Retries: {this.state.payloadData.retries}</div>
        </div>
      </Grid>
    );
  }
}

export default ApplicationCard;