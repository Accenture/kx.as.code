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
      queueList: ['pending_queue', 'failed_queue', 'completed_queue', 'retry_queue', 'wip_queue'],
      isLoading: true,
      intervallId: null
    }
  }

  componentWillUnmount() {
    clearInterval(this.state.intervallId);
  }

  componentDidMount() {
    this.fetchQueueDataAndExtractApplicationMetadata();
    var intervallId = setInterval(this.fetchQueueDataAndExtractApplicationMetadata, 2000)
    this.setState({ intervallId: intervallId });
  }

  async f_setAppMetaData(message, queue) {
    var app = {
      queueName: queue,
      appName: JSON.parse(message.payload).name,
      category: JSON.parse(message.payload).install_folder,
      retries: JSON.parse(message.payload).retries
    }
    return app;
  }

  async s_function(message, queue) {
    const app = await this.f_setAppMetaData(message, queue);
    const queueDataTmp = this.state.queueData
    queueDataTmp.push(app);
    this.setState({
      queueData: queueDataTmp
    })
  }

  fetchQueueDataAndExtractApplicationMetadata() {
    //console.log("Queue List Type: ", typeof(this.state.queueList))
    //console.log("Queue List: ", this.state.queueList)

    var arr = this.state.queueList
    console.error("Arr: ", arr)
    arr.forEach(element => console.log(element))

    //this.state.queueList.forEach(queue => this.fetchData(queue));

    console.log("QueueData: ", this.state.queueData)
    this.setState({
      isLoading: false
    })
  }

  fetchData(queue) {
    console.log("debug-qList elem: ", queue)
    axios.get("http://localhost:5000/queues/" + queue).then(response => {
      response.data.forEach(message => {
        this.s_function(message, queue)
      });
    });
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
                  <Route path="/apps" element={<ApplicationView
                    queueData={this.state.queueData}
                    isLoading={this.state.isLoading} />} component={ApplicationView} />
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
