import React from "react";
import { Box } from "@material-ui/core";
import { useTranslation } from 'react-i18next';
const Dashboard = (props) => {
    const { t } = useTranslation();
    return (
      <div>
        <Box id="Home">
          <h1>{t("HOME_TITLE")}</h1>
          <p>{t("HOME_SUBTITLE")}</p>
        </Box>
        <pre>{t("CoreComponents")}</pre>
      </div>
    );
};
export default Dashboard;
