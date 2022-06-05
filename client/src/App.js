import React, { useEffect, useState } from "react";
import { Switch, Route, useLocation } from "react-router-dom";

import "./css/style.scss";

import { focusHandling } from "cruip-js-toolkit";
import "./charts/ChartjsConfig";

// Import pages
import Dashboard from "./pages/Dashboard";

import Sidebar from "./partials/Sidebar";
import Header from "./partials/Header";
import Settings from "./pages/Settings";
import BasicBreadcrumbs from "./partials/BasicBreadcrumbs";
import ExampleApp1 from "./partials/ExampleApp1";
import AppDetails from "./pages/AppDetails";
import Home2 from "./pages/Home";
import ApplicationGroups from "./pages/ApplicationGroups";
import { Applications2 } from "./pages/Applications2";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import KXASCodeNotifications from "./partials/applications/KXASCodeNotifications";
import { ThemeProvider, createTheme } from "@mui/material/styles";


function App() {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const location = useLocation();

  const darkTheme = createTheme({
    palette: {
      mode: "dark",
    },
  });


  useEffect(() => {
    document.querySelector("html").style.scrollBehavior = "auto";
    window.scroll({ top: 0 });
    document.querySelector("html").style.scrollBehavior = "";
    focusHandling("outline");
  }, [location.pathname]); // triggered on route change

  return (
    <>
        <ThemeProvider theme={darkTheme}>

      {/* <KXASCodeNotifications /> */}
      <div className="flex h-screen overflow-hidden bg-inv1 text-white text-sm">
        {/* Sidebar */}
        <Sidebar sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

        {/* Content area */}
        <div className="relative flex flex-col flex-1 overflow-y-auto overflow-x-hidden">
          {/*  Site header */}
          <Header sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />
          <ToastContainer
            position="bottom-right"
            autoClose={5000}
            hideProgressBar={false}
            newestOnTop={false}
            closeOnClick
            rtl={false}
            pauseOnFocusLoss
            draggable
            pauseOnHover
          />
          <main className="pb-20">
            <BasicBreadcrumbs />
            <Switch>
              <Route exact path="/" component={Home2} />
              <Route exact path="/dashboard">
                <Dashboard />
              </Route>
              <Route exact path="/apps">
                <Applications2 />
              </Route>
              <Route
                exact
                path="/application-groups"
                render={(props) => <ApplicationGroups {...props} />}
              />
              <Route
                exact
                path="/settings"
                render={(props) => <Settings {...props} />}
              />
              <Route
                path="/apps/:app"
                render={(props) => <AppDetails {...props} />}
              />
            </Switch>
          </main>
        </div>
      </div>
      </ThemeProvider>
    </>
  );
}

export default App;
