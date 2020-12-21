import { hot } from "react-hot-loader";
import React, { Component } from "react";
import { library } from "@fortawesome/fontawesome-svg-core";
import { faChevronRight } from "@fortawesome/free-solid-svg-icons";
import { Box } from "@material-ui/core";
import intl from "react-intl-universal";
import IntlPolyfill from "intl";
import "./App.scss";
import TopPanel from "./layout/components/TopPanel";
import LeftPanel from "./layout/components/LeftPanel";
import { HashRouter, Route } from "react-router-dom";
import Home from "./components/home/Home";
import NewProfileGeneral from "./components/profile/NewProfileGeneral";

window.Intl = IntlPolyfill;
require("intl/locale-data/jsonp/en-US.js");
require("intl/locale-data/jsonp/de-DE.js");

const SUPPORTED_LOCALES = [
  {
    name: "English",
    value: "en-US",
  },
  {
    name: "Deutsch",
    value: "de-DE",
  },
];

library.add(faChevronRight);

class App extends Component {
  constructor() {
    super();
    const currentLocale = SUPPORTED_LOCALES[0].value; // Determine user's locale here
    intl.init({
      currentLocale,
      locales: {
        [currentLocale]: require(`./locales/${currentLocale}.json`),
      },
    });
  }

  render() {
    return (
      <Box
        id="App"
        display="flex"
        flexDirection="column"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        {/* Top panel */}
        <Box id="TopPanel-wrapper">
          <HashRouter>
            <TopPanel />
          </HashRouter>
        </Box>
        {/* Main section - below top panel */}
        <Box id="main" flex="1">
          <Box
            id="main-container"
            display="flex"
            flexDirection="row"
            justifyContent="flex-start"
            alignItems="flex-start"
            height="100%"
          >
            {/* Left panel */}
            <Box id="LeftPanel-wrapper">
              <LeftPanel />
            </Box>
            {/* Content */}
            <Box id="content" padding="20px">
              <HashRouter>
                <div>
                  <Route path="/" exact={true} component={Home} />
                  <Route
                    path="/new-profile-general/"
                    exact={true}
                    component={NewProfileGeneral}
                  />
                </div>
              </HashRouter>
            </Box>
          </Box>
        </Box>
      </Box>
    );
  }
}

export default hot(module)(App);
