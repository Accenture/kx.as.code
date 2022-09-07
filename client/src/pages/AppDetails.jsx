import React, { useState, useEffect } from "react";
// import NotFound from "../partials/NotFound";
import axios from "axios";
import AppLogo from "../partials/applications/AppLogo";
import AppTaskComponent from "../pages/AppTaskComponent";
import ScreenshotCarroussel from "../partials/applications/ScreenshotCarroussel";
import { VscTerminalPowershell } from "react-icons/vsc";
import { FaArrowAltCircleDown } from "react-icons/fa";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Tooltip from "@mui/material/Tooltip";

export default function AppDetails(props) {
  const [appData, setAppData] = useState([]);
  const [availableTasksList, setAvailableTasksList] = useState([]);

  const {
    location: { pathname },
  } = props;
  const pathnames = pathname.split("/").filter((x) => x);

  const fetchAppData = () => {
    const slug = pathnames[pathnames.length - 1];
    axios
      .get("http://localhost:5001/api/applications/" + slug)
      .then((response) => {
        setAppData(response.data);
        if (response.data.hasOwnProperty("available_tasks")) {
          setAvailableTasksList(response.data.available_tasks);
        }
      });
  };

  // TODO clean up -> Dublicate Code
  const getApplicationDataByName = async () => {
    try {
      const respoonseData = await axios.get(
        "http://localhost:5001/api/applications/" + appData.name
      );
      return respoonseData.data;
    } catch (error) {
      console.log("Error: ", error);
    }
  };

  // TODO Rewrite all Installation / Execution Handler in one function with different parameters
  const taskExecutionHandler = async (taskName) => {
    // notify("install"); -> TODO: notifier for exutable tasks
    getApplicationDataByName().then((appData) => {
      var payloadObj = {
        install_folder: appData.installation_group_folder,
        name: appData.name,
        task: taskName, // TODO: pass task
        action: "executeTask",
        retries: "0",
      };
      const applicationPayload = payloadObj;

      // TODO rewrite Endpoint to add install and exe actions to pending_queue via POST
      axios
        .post(
          "http://localhost:5001/api/add/application/pending_queue",
          applicationPayload
        )
        .then(() => {
          // setAppQueue("pending_queue");
          // props.fetchQueueData();
          // props.fetchApplicationAndQueueData();
        })
        .then(() => {
          // setTimeout(() => {
          //   refreshActionButton.current();
          // }, 2000);
        })
        .catch((error) => {
          console.error("There was an error!", error);
        });
    });
  };

  const drawAwailableTasksComponents = () => {
    return availableTasksList.map((task, i) => {
      return (
        <AppTaskComponent
          key={i}
          task={task}
          taskExecutionHandler={taskExecutionHandler}
        />
      );
    });
  };

  useEffect(() => {
    fetchAppData();
  }, []);
  return (
    <div className="p-4">
      {/* Header */}
      <div className="grid grid-cols-12 py-5 rounded-lg p-5 items-center">
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
        <div className="col-span-2 justify-end flex">
          <button
            className="bg-kxBlue p-2 px-5 rounded items-center flex"
            to="#0"
            onClick={() => {}}
          >
            <div className="flex items-center">
              <FaArrowAltCircleDown className="mr-2 flex my-auto text-white" />
            </div>
            <span className="flex my-auto text-[16px] capitalize">
              Install {appData.name}
            </span>
          </button>
        </div>
      </div>

      {/* Header Section 2 */}

      <div className="grid grid-cols-12 mt-5">
        <div className="col-span-8 bg-inv3 p-5 mr-5 rounded-lg pt-10 border border-1 border-gray-700">
          <h2 className="mb-3 text-lg">Screenshots</h2>
          <ScreenshotCarroussel appName={appData.name} />
        </div>
        <div className="col-span-4 p-5 bg-inv3 rounded-lg pt-10 border border-1 border-gray-700">
          <h2 className="mb-3 text-lg">Executable Tasks</h2>
          {availableTasksList.length > 0 ? (
            drawAwailableTasksComponents()
          ) : (
            <div>No Tasks available.</div>
          )}
        </div>
      </div>
    </div>

    // <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto text-white">
    //   App Details Page
    //   <NotFound />
    // </div>
  );
}
