import React from "react";
import { useHistory } from "react-router-dom";
import "./TopPanel.scss";
import { Box, Link } from "@material-ui/core";
import avatarIcon from "../../media/images/common/KX-AS-CODE-Avatar.png";

const TopPanel = () => {
  const history = useHistory();
  return (
    <Box id="TopPanel">
      <Box id="avatar">
        <Link onClick={() => history.push("/")}>
          <img src={String(avatarIcon)} />
        </Link>
      </Box>
      <Box>
        <h1>KX.AS.CODE</h1>
      </Box>
    </Box>
  );
};

export default TopPanel;
