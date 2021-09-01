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
      // a: "",
      // b: "",
      // result: ""
      items: []
    };
  }

  componentDidMount() {
    this.getItems();
    // console.log(API);
    // API.subscribe(({ result }) => {
    //   this.setState({
    //     result: result
    //   })
    // });
  }
  
  getItems = () => {
    axios.get("http://localhost:15672/api/queues/%2f/pending_queue").then(response => {
      this.setState({
        items: response
      })
      console.log(this.state.items);
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

  handleSubmit(event) {
    /*
    event.preventDefault();

    const params = new URLSearchParams();
    params.append('a', this.state.a);
    params.append('b', this.state.b);

    fetch(`${API.API_URL}/api/calc/sum`, { method: 'POST', body: params })
      .then(res => res.json());
    */
  }

  render() {
    // const { t } = useTranslation();
    // const result = this.state.result ? (
    //   <label>
    //     Result:
    //     <input type="text" value={this.state.result} name='b' readOnly />
    //   </label>
    // ) : ''
     return (
    //   <div>
    //     <div>
    //       <form onSubmit={this.handleSubmit}>
    //         <label>
    //           A:
    //           <input type="text" name='a' onChange={this.handleChange} />
    //         </label>
    //         <label>
    //           B:
    //           <input type="text" name='b' onChange={this.handleChange} />
    //         </label>
    //         {result}
    //         <br />
    //         <input type="submit" value="Add" />
    //       </form>
    //     </div>
        <Box id="Home">
          <Box className="application-cards">
            <ApplicationCard />
            <ApplicationCard />
            <ApplicationCard />
            <ApplicationCard />

          </Box>
        </Box>
      // </div>
    );
  }
}