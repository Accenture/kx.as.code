import { React, Component } from "react";
import { Box, Button } from "@material-ui/core"
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
    if(queue_name == "pending_queue"){
      return this.state.pendingData.map(item => {
        return <ApplicationCard item={item}/>
      })
    }
    else if(queue_name == "failed_queue"){
      return this.state.failedData.map(item => {
        return <ApplicationCard item={item}/>
      })
    }
  }

  getData = (queue_name) => {
    
      axios.get("http://localhost:5000/queues/" + queue_name).then(response => {

        if(queue_name == "pending_queue"){
          this.setState({
            pendingData: response.data
          })
        }
        else if(queue_name == "failed_queue"){
          this.setState({
            failedData: response.data
          })
        }
        else if(queue_name == "completed_queue"){
          this.setState({
            completedData: response.data
          })
        }
        else if(queue_name == "retry_queue"){
          this.setState({
            retryData: response.data
          })
        }
        else if(queue_name == "wip_queue"){
          this.setState({
            wipData: response.data
          })
        }
      }).catch(function (error){
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
        <Box id="Home">
          <Box className="application-cards">
            {this.itemList("pending_queue")}
            {this.itemList("failed_queue")}
            {this.itemList("completed_queue")}
            {this.itemList("retry_queue")}
            {this.itemList("wip_queue")}
          </Box>
        </Box>
    );
  }
}