import React from "react";
import "./LeftPanel.scss";
import InboxIcon from "@material-ui/icons/Inbox";
import DraftsIcon from "@material-ui/icons/Drafts";
import DashboardIcon from '@mui/icons-material/Dashboard';
import AssessmentIcon from '@mui/icons-material/Assessment';
import SettingsApplicationsIcon from '@mui/icons-material/SettingsApplications';
import AppsIcon from '@mui/icons-material/Apps';
import { Box, Link } from "@material-ui/core";

const preventDefault = (event) => event.preventDefault();

const LeftPanel = () => (
  <Box id="LeftPanel">
    <Box id="left-nav-1" className="left-nav">
      <Link href="/dashboard" onClick={preventDefault}>
        <div className="icon-label-left-panel-container">
          <AssessmentIcon />
          <span className="left-panel-label">Dashboard</span>
        </div>
      </Link>
    </Box>
    <Box id="left-nav-2" className="left-nav">
      <Link href="/apps" onClick={preventDefault}>
        <div className="icon-label-left-panel-container">
          <AppsIcon />
          <span className="left-panel-label" >Applications</span>
        </div>
      </Link>
    </Box>
    <Box id="left-nav-2" className="left-nav">
      <Link href="/settings" onClick={preventDefault}>
        <div className="icon-label-left-panel-container">
          <SettingsApplicationsIcon />
          <span className="left-panel-label">Settings</span>
        </div>
      </Link>
    </Box>
  </Box>
);

export default LeftPanel;
