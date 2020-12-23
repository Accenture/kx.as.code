import React from "react";
import { useHistory } from "react-router-dom";
import "./Home.scss";
import { Box, Button } from "@material-ui/core";
import intl from "react-intl-universal";
import ProfileCard from "./ProfileCard";

const Home = () => {
  const history = useHistory();

  return (
    <Box id="Home">
      <h1>{intl.get("HOME_TITLE")}</h1>
      <p>{intl.get("HOME_SUBTITLE")}</p>

      <Box>
        <Button onClick={() => history.push("/new-profile-general")}>
          {intl.get("HOME_NEW_PROFILE_BUTTON")}
        </Button>
        <Button>{intl.get("HOME_IMPORT_CONFIG_BUTTON")}</Button>
      </Box>
      <Box className="profile-cards">
        <ProfileCard
          subVmCategory="VMWare vSphere"
          profileName="Profile Name"
          domainName="Domain Name"
          ipAddress="IP Address"
        />
        <ProfileCard
          subVmCategory="VMWare vSphere"
          profileName="Profile Name"
          domainName="Domain Name"
          ipAddress="IP Address"
        />
        <ProfileCard
          subVmCategory="VMWare vSphere"
          profileName="Profile Name"
          domainName="Domain Name"
          ipAddress="IP Address"
        />
        <ProfileCard
          subVmCategory="VMWare vSphere"
          profileName="Profile Name"
          domainName="Domain Name"
          ipAddress="IP Address"
        />
      </Box>
    </Box>
  );
};

export default Home;
