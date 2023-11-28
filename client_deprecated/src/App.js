import React, { useEffect, useState } from "react";
import { Switch, Route, useLocation } from "react-router-dom";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import { ThemeProvider, createTheme } from "@mui/material/styles";

import "./css/style.scss";
import { focusHandling } from "cruip-js-toolkit";
import "./charts/ChartjsConfig";
import Dashboard from "./pages/Dashboard";
import Sidebar from "./partials/Sidebar";
import Header from "./partials/Header";
import Settings from "./pages/Settings";
import BasicBreadcrumbs from "./partials/BasicBreadcrumbs";
import AppDetails from "./pages/AppDetails";
import Home2 from "./pages/Home";
import ApplicationGroups from "./pages/ApplicationGroups";
import { Applications } from "./pages/Applications";
import KXASCodeNotifications from "./partials/applications/KXASCodeNotifications";


function App() {

  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();
  const darkTheme = createTheme({ palette: { mode: "dark" } });

  useEffect(() => {
    document.querySelector("html").style.scrollBehavior = "auto";
    window.scroll({ top: 0 });
    document.querySelector("html").style.scrollBehavior = "";
    focusHandling("outline");
    
  }, [location.pathname]); // Triggered on route change

  const routes = [
    { path: "/", exact: true, component: Home2 },
    { path: "/dashboard", exact: true, component: Dashboard },
    { path: "/apps", exact: true, component: Applications },
    { path: "/application-groups", exact: true, component: ApplicationGroups },
    { path: "/settings", exact: true, component: Settings },
    { path: "/apps/:app", component: AppDetails },
  ];

  return (
    <ThemeProvider theme={darkTheme}>
      <KXASCodeNotifications />
      <div className="flex h-screen overflow-hidden bg-inv1 text-white text-sm">
        {/* Sidebar */}
        <Sidebar sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} />

        {/* Content area */}
        <div className="relative flex flex-col flex-1 overflow-y-auto overflow-x-hidden">
          {/* Site header */}
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
            {/* Breadcrumbs */}
            <BasicBreadcrumbs />

            {/* Routing */}
            <Switch>
              {routes.map((route, index) => (
                <Route key={index} {...route} />
              ))}
            </Switch>
          </main>
        </div>
      </div>
    </ThemeProvider>
  );
}

export default App;