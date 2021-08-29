import {React, Component} from "react";
import { Box, Button } from "@material-ui/core"
import { useTranslation } from 'react-i18next';
import "../dashboard/Dashboard.scss"
import "../applications/ApplicationCard"
import ApplicationCard from "../applications/ApplicationCard";
import * as API from './api';
import URLSearchParams from 'url-search-params';


export default class Dashboard extends Component {

  constructor(props) {
    super(props);
    this.state = {
      a: "",
      b: "",
      result: ""
    };
  }

  componentDidMount() { 
    console.log(API);
    API.subscribe(({result})=>{
      this.setState({
        result: result
      })
   });
  }

  handleChange(event) {
    this.setState({
      [event.target.name]: event.target.value}
    );
  }

  handleSubmit(event) {
    event.preventDefault();

    const params = new URLSearchParams();
    params.append('a', this.state.a);
    params.append('b', this.state.b);

    fetch(`${API.API_URL}/api/calc/sum`, { method: 'POST', body: params })
    .then(res => res.json());
  }

  render() {
    // const { t } = useTranslation();
    return (
      <Box id="Home">
        <Box className="application-cards">
          <ApplicationCard />
          <ApplicationCard />
          <ApplicationCard />
          <ApplicationCard />

        </Box>
      </Box>
    );
  }
}