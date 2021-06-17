import React from "react";
import "./LeftPanel.scss";
import InboxIcon from "@material-ui/icons/Inbox";
import DraftsIcon from "@material-ui/icons/Drafts";
import { Box, Link } from "@material-ui/core";

const preventDefault = (event) => event.preventDefault();

const LeftPanel = () => (
  <Box id="LeftPanel">
    <Box id="left-nav-1" className="left-nav">
      <Link href="#" onClick={preventDefault}>
        <InboxIcon />
      </Link>
    </Box>
    <Box id="left-nav-2" className="left-nav">
      <Link href="#" onClick={preventDefault}>
        <DraftsIcon />
      </Link>
    </Box>
  </Box>
);

export default LeftPanel;
