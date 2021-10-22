import { React, Component } from "react";
import { Box, Button, Grid } from "@material-ui/core"
import { useTranslation } from 'react-i18next';
import "../dashboard/Dashboard.scss"
import "../applications/ApplicationCard"
import ApplicationCard from "../applications/ApplicationCard";
// import * as API from './api';
import URLSearchParams from 'url-search-params';
import axios from "axios";


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
    );
  }
}