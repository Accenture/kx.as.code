import React from "react";
import "./LeftPanel.scss";
import InboxIcon from "@material-ui/icons/Inbox";
import DraftsIcon from "@material-ui/icons/Drafts";
import { Box, Link } from "@material-ui/core";

const preventDefault = (event) => event.preventDefault();

const LeftPanel = () => (
  <aside id="sidenav">
    <div id="left-nav-1" className="left-nav">
      <Link href="#" onClick={preventDefault}>
        <InboxIcon />
      </Link>
    </div>
    <div id="left-nav-2" className="left-nav">
      <Link href="#" onClick={preventDefault}>
        <DraftsIcon />
      </Link>
    </div>
  </aside>
);

export default LeftPanel;
