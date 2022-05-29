import React, { useState, useEffect } from "react";
// import NotFound from "../partials/NotFound";
import axios from "axios";
import AppLogo from "../partials/applications/AppLogo";
import ScreenshotCarroussel from "../partials/applications/ScreenshotCarroussel";

export default function AppDetails(props) {
  const [appData, setAppData] = useState([]);

  const {
    location: { pathname },
  } = props;
  const pathnames = pathname.split("/").filter((x) => x);

  const fetchAppData = () => {
    const slug = pathnames[pathnames.length - 1];
    console.log("path: ", slug);
    axios
      .get("http://localhost:5001/api/applications/" + slug)
      .then((response) => {
        console.log("appDetails: ", response.data);
        setAppData(response.data);
      });
  };

  useEffect(() => {
    fetchAppData();
  }, []);
  return (
    <div className="p-4">
      {/* Header */}
      <div className="grid grid-cols-12 border-b border-gray-500 py-5">
        <div className="col-span-10">
          <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-2 text-base">
            {appData.installation_group_folder}
          </div>
          <div className="flex items-center">
            <div className="mr-4">
              <AppLogo height={"50px"} width={"50px"} appName={appData.name} />
            </div>
            <div className="">
              <div className="text-3xl capitalize">{appData.name} </div>
              <div>{appData.Description}</div>
            </div>
          </div>
        </div>
        {/* right section header */}
        <div className="col-span-2"></div>
      </div>

      <h2 className="mt-5 text-2xl">Screenshots</h2>
      <ScreenshotCarroussel appName={appData.name} />
    </div>

    // <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto text-white">
    //   App Details Page
    //   <NotFound />
    // </div>
  );
}
