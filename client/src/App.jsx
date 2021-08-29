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

      <Box id="App">
        {/* Top panel */}
        <Box id="TopPanel-wrapper">
          <HashRouter>
            <TopPanel />
          </HashRouter>
        </Box>
        {/* Main section - below top panel */}
        <Box id="main" flex="1">
          <Box id="main-container">
            {/* Left panel */}
            <Box id="LeftPanel-wrapper">
              <LeftPanel />
            </Box>
            {/* Content */}
            <Box id="content" >
              <HashRouter>
                <div>
                  <Route path="/" exact={true} component={Dashboard} />
                </div>
              </HashRouter>
            </Box>
          </Box>
        </Box>
      </Box>
          
      


        
      </Suspense>
    );
  }
}

export default App;
