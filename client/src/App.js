import React, { Suspense, Component } from 'react';
import "./App.scss";
import Dashboard from './components/dashboard/Dashboard';
import { HashRouter, Route, Switch } from "react-router-dom";
// import { Box } from "@material-ui/core";

import TopPanel from "./layout/components/TopPanel";
import LeftPanel from "./layout/components/LeftPanel";
import ApplicationView from './components/application/ApplicationView';
import SettingsView from './components/settings/SettingsView';
import axios from "axios";


class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      queueData: [],
      queueList: ["pending_queue", "failed_queue", "completed_queue", "retry_queue", "wip_queue"], 
      isLoading: true
    }
  }

  componentDidMount() {
    this.fetchQueueDataAndExtractApplicationMetadata()
  }

  async first_setAppMetaData(message, queue) {
    var app = {
      queueName: queue,
      appName: JSON.parse(message.payload).name,
      category: JSON.parse(message.payload).install_folder,
      retries: JSON.parse(message.payload).retries
    }
    return app;
  }

  async secondFunction(message, queue) {
    const app = await this.first_setAppMetaData(message, queue);
    const queueDataTmp = this.state.queueData
    queueDataTmp.push(app);
    this.setState({
      queueData : queueDataTmp
    })
  }

  fetchQueueDataAndExtractApplicationMetadata() {
    this.state.queueList.forEach(queue => {
      axios.get("http://localhost:5000/queues/" + queue).then(response => {
        response.data.forEach(message => {
          this.secondFunction(message, queue)
        });
      });
    })
    console.log("QueueData: ", this.state.queueData)
    this.setState({
      isLoading : false
    })
  }


  render() {
    return (
      <Suspense fallback="loading">
        <div id="App">
          {/* Top panel */}
          <div id="TopPanel-wrapper">
            <HashRouter>
              <TopPanel />
            </HashRouter>
          </div>
          {/* Main section - below top panel */}
          <div id="main" flex="1">
            <div id="main-container">
              {/* Left panel */}
              <div id="LeftPanel-wrapper">
                <LeftPanel />
              </div>
              {/* Content */}
              <div id="content" >
                <Switch>
                  <Route path="/dashboard" exact={true} component={Dashboard} />
                  <Route path="/apps" element={ <ApplicationView 
                  queueData={this.state.queueData} 
                  isLoading={this.state.isLoading}/>} component={ApplicationView}/>
                  <Route path="/settings" component={SettingsView} />
                </Switch>
              </div>
            </div>
          </div>
        </div>
      </Suspense>
    );
  }
}

export default App;
