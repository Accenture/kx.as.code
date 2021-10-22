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
          <div id="sidenav">
            <HashRouter>
              <TopPanel />
            </HashRouter>
          </div>
          <LeftPanel />


          <div id="">
            <div>
              
            </div>
            <div id="main-content-2" >
              <HashRouter>
                <div>
                  <Route path="/" exact={true} component={Dashboard} />
                </div>
              </HashRouter>
            </div>
          </div>
        </div>





      </Suspense>
    );
  }
}

export default App;
