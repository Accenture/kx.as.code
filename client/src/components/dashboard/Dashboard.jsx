import React from "react";
import { Box } from "@material-ui/core";
import { useTranslation } from 'react-i18next';
const Dashboard = (props) => {
    const { t } = useTranslation();
    return (
        <Box id="Home">
          <h1>{t("HOME_TITLE")}</h1>
          <p>{t("HOME_SUBTITLE")}</p>
        </Box>
    );
};
export default Dashboard;
