import { React, Component } from "react";
import { Box, Button, Grid } from "@material-ui/core"
import { useTranslation } from 'react-i18next';
import "../dashboard/Dashboard.scss"
<<<<<<< HEAD
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
=======
import "../applications/ApplicationCard"
import ApplicationCard from "../applications/ApplicationCard";
// import * as API from './api';
import URLSearchParams from 'url-search-params';
import axios from "axios";
>>>>>>> feature/rabbitmq-client-poc


export default class Dashboard extends Component {

  constructor(props) {
    super(props);
    this.state = {
      pendingData: [],
      completedData: [],
      failedData: [],
      retryData: [],
      wipData: []
    };
  }

  componentDidMount() {
    this.getData("pending_queue");
    this.getData("failed_queue");
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
        data = this.state.completedData
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
      if (queue_name == "pending_queue") {
        this.setState({
          pendingData: response.data
        })
      }
      else if (queue_name == "failed_queue") {
        this.setState({
          failedData: response.data
        })
      }
      else if (queue_name == "completed_queue") {
        this.setState({
          completedData: response.data
        })
      }
      else if (queue_name == "retry_queue") {
        this.setState({
          retryData: response.data
        })
      }
      else if (queue_name == "wip_queue") {
        this.setState({
          wipData: response.data
        })
      }
    }).catch(function (error) {
      console.log(error);
    })

  }

  handleChange(event) {
    this.setState({
      [event.target.name]: event.target.value
    }
    );
  }

  render() {

    return (
<<<<<<< HEAD
      <Grid id="main-content-dashboard" container spacing={8}>
        <Grid item xs={4} className="profile-cards" style={{ width: "100%" }}>

          Pending Queue

          {this.itemList("pending_queue")}
          Failed Queue
          {this.itemList("failed_queue")}
          Completed Queue
          {this.state.completedData !== 'undefined' && this.state.completedData.length > 0 ? this.itemList("completed_queue") : "Empty Queue"}
          Retry Queue
          {this.itemList("retry_queue")}
          WIP Queue
          {this.itemList("wip_queue")}
        </Grid>
      </Grid>
=======
      <div id="dashboard-content">

          <Grid container className="application-cards-container-left" style={{backgroundColor: "blue"}}>            
              {this.itemList("pending_queue")}
              {this.itemList("failed_queue")}
              {this.itemList("completed_queue")}
              {this.itemList("retry_queue")}
              {this.itemList("wip_queue")}
          </Grid>
          <div style={{backgroundColor: "orange"}}>
            Hello Grid right
          </div>
      </div>
>>>>>>> feature/rabbitmq-client-poc
    );
  }
}