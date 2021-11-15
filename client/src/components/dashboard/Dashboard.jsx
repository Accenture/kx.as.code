import { React, Component } from "react";
import { Box, Button, Grid } from "@material-ui/core"
import { useTranslation } from 'react-i18next';
import "../dashboard/Dashboard.scss"
import ApplicationCard from "../ApplicationCard";
// import * as API from './api';
// import URLSearchParams from 'url-search-params';
import axios from "axios";
import Accordion from '@mui/material/Accordion';
import AccordionSummary from '@mui/material/AccordionSummary';
import AccordionDetails from '@mui/material/AccordionDetails';
import Typography from '@mui/material/Typography';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import { width } from "@mui/system";


export default class Dashboard extends Component {

  constructor(props) {
    super(props);
    this.state = {
      pendingData: [],
      completedData: [],
      failedData: [],
      retryData: [],
      wipData: [],
      queueDataAll: []
    };
  }

  componentDidMount() {
    this.getData("pending_queue");
    this.getData("failed_queue");
  }

  addQueueNameProperty(queueData, queueName) {

  }

  itemList(queue_name) {
    var data = "";
    switch (queue_name) {
      case "pending_queue":
        data = this.state.pendingData
        break;
      case "failed_queue":
        data = this.state.failedData
        break;
      case "completed_queue":
        data = this.state.completedData
        break;
      case "wip_queue":
        data = this.state.wipData
        break;
      case "retry_queue":
        data = this.state.retryData
        break;
      default:
        console.log("Queue not found -> ", queue_name);
        break;
    }
    return data.map(item => {
      return <ApplicationCard item={item} />
    })
  }


  getData = (queue_name) => {

    axios.get("http://localhost:5000/queues/" + queue_name).then(response => {
      console.log("ResponseData: ", response.data)

      this.setState({
        pendingData: response.data,
      })
      console.log("Queue Data All: ", this.state.queueDataAll)

    }).catch(function (error) {
      console.log(error);
    })

    // axios.get("http://localhost:5000/queues/" + queue_name).then(response => {
    //   console.log("ResponseData: ", response.data)
    //   if (queue_name == "pending_queue") {
    //     this.setState({
    //       pendingData: response.data,
    //       queueDataAll: JSON.parse(this.props.item.payload)
    //     })
    //     console.log("Queue Data All: ", this.state.queueDataAll)
    //   }
    //   else if (queue_name == "failed_queue") {
    //     this.setState({
    //       failedData: response.data
    //     })
    //   }
    //   else if (queue_name == "completed_queue") {
    //     this.setState({
    //       completedData: response.data
    //     })
    //   }
    //   else if (queue_name == "retry_queue") {
    //     this.setState({
    //       retryData: response.data
    //     })
    //   }
    //   else if (queue_name == "wip_queue") {
    //     this.setState({
    //       wipData: response.data
    //     })
    //   }
    // }).catch(function (error) {
    //   console.log(error);
    // })

  }

  handleChange(event) {
    this.setState({
      [event.target.name]: event.target.value
    }
    );
  }

  render() {

    return (
      <Grid id="main-content-dashboard" container spacing={4}>
        <Grid item xs={5} >
          <div className="profile-cards" style={{ width: "100%" }}>
            Pending Queue
            {this.state.pendingData !== 'undefined' && this.state.pendingData.length > 0 ? this.itemList("pending_queue") : "Empty Queue"}
            Failed Queue
            {this.state.failedData !== 'undefined' && this.state.failedData.length > 0 ? this.itemList("failed_queue") : "Empty Queue"}
            Completed Queue
            {this.state.completedData !== 'undefined' && this.state.completedData.length > 0 ? this.itemList("completed_queue") : "Empty Queue"}
            Retry Queue
            {this.state.retryData !== 'undefined' && this.state.retryData.length > 0 ? this.itemList("retry_queue") : "Empty Queue"}
            WIP Queue
            {this.state.wipData !== 'undefined' && this.state.wipData.length > 0 ? this.itemList("wip_queue") : "Empty Queue"}
          </div>
        </Grid>

        <Grid item xs={7} >
          <Grid item xs={12} >
            <div className="profile-cards" style={{ height: "39vh", marginBottom: "20px" }}>
              
            </div>
          </Grid>
          <Grid item xs={12} >
            <div className="profile-cards" style={{ height: "50px" }}>
              
            </div>
          </Grid>
        </Grid>

      </Grid>
    );
  }
}