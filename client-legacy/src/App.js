import React, { Suspense, Component } from 'react';
import "./App.scss";
import Dashboard from './components/dashboard/Dashboard';
import { HashRouter, Route, Switch } from "react-router-dom";
// import { Box } from "@material-ui/core";

import TopPanel from "./layout/components/TopPanel";
import LeftPanel from "./layout/components/LeftPanel";
import ApplicationView from './components/application/ApplicationView';
import SettingsView from './components/settings/SettingsView';


class App extends Component {

  constructor(props) {
    super(props);
    this.state = {
      isLoading: true,
    }
  }

  componentWillUnmount() {

  }

  componentDidMount() {
    
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
                  <Route path="/apps" component={ApplicationView} />
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
