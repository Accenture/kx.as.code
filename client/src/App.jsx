import React, { Suspense, Component } from 'react';
import "./App.scss";
import Dashboard from './components/dashboard/Dashboard';
import { HashRouter, Route } from "react-router-dom";
import { Box } from "@material-ui/core";
import { library } from "@fortawesome/fontawesome-free"

import TopPanel from "./layout/components/TopPanel";
import LeftPanel from "./layout/components/LeftPanel";

class App extends Component {
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
        <div id="main">
          <div id="main-container">
            {/* Left panel */}
            <div id="LeftPanel-wrapper">
              <LeftPanel />
            </div>
            {/* Content */}
            <div id="content" >
              <HashRouter>
                <div>
                  <Route path="/" exact={true} component={Dashboard} />
                </div>
              </HashRouter>
            </div>
          </div>
        </div>
      </div>
          
      


        
      </Suspense>
    );
  }
}

export default App;
