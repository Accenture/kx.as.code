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
      items: []
    };
  }

  componentDidMount() {
    this.getData();
  }
  
  itemList() {
    return this.state.items.map(item => {
      return <ApplicationCard item={item}/>
    })
  }

  getData = () => {
    axios.get("http://localhost:5000/queues/pending_queue").then(response => {
      this.setState({
        items: response.data
      })
      console.log("Items: ", this.state.items);
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
            {this.itemList()}
          </Box>
        </Box>
    );
  }
}