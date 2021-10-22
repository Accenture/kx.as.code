import React from "react";
import { useHistory } from "react-router-dom";
import "./TopPanel.scss";
import { Box, Link } from "@material-ui/core";
import avatarIcon from "../../media/images/common/KX-AS-CODE-Avatar.png";

const TopPanel = () => {
  const history = useHistory();
  return (
    <header>
      <div>
        <Link onClick={() => history.push("/")}>
          {/* <img src={String(avatarIcon)} alt="profile" /> */}
        </Link>
      </div>
      <div>
        <h1>KX.AS.CODE</h1>
      </div>
    </header>
  );
};

export default TopPanel;
