import React from "react";
import { useHistory } from "react-router-dom";
import "./Home.scss";
import { Box, Button } from "@material-ui/core";
import intl from "react-intl-universal";
import ProfileCard from "./ProfileCard";
import { connect } from "react-redux";
import { setCurrentView } from "../../redux/actions";

const Home = (props) => {
  const history = useHistory();
  const handleClick = () => {
    props.setView(1);
    history.push("/new-profile-general")
  };
  return (
    <Box
      id="Home"
      display="flex"
      flexDirection="column"
      justifyContent="start-flex"
      alignItems="center"
    >
      <h1>{intl.get("HOME_TITLE")}</h1>
      <p>{intl.get("HOME_SUBTITLE")}</p>

      <Box>
        <Button onClick={handleClick}>
          {intl.get("HOME_NEW_PROFILE_BUTTON")}
        </Button>
        <Button>{intl.get("HOME_IMPORT_CONFIG_BUTTON")}</Button>
      </Box>
      <Box
        className="profile-cards"
        display="flex"
        flexDirection="row"
        justifyContent="center"
        alignItems="flex-start"
        flexWrap="wrap"
      >
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
          machineType="VMWare vSphere"
          profileName="Profile Name"
          domainName="Domain Name"
          ipAddress="IP Address"
        />
      </Box>
    </Box>
  );
};
const mapDispatchToProps = (dispatch) => {
  return {
      setView: (view) => {
          dispatch(setCurrentView(view))
      }
  }
}
export default connect(mapDispatchToProps)(Home);
