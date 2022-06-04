import React from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import StatusTag from "../StatusTag";
import StatusPoint from "../StatusPoint";
import { useState, useEffect, useRef } from "react";
import AppLogo from "./AppLogo";
import { toast } from "react-toastify";
import LinearProgress from "@mui/material/LinearProgress";
import axios from "axios";
import ApplicationStatusActionButton from "./ApplicationStatusActionButton";

function ApplicationCard2(props) {
  const { history } = props;

  const [appId, setAppId] = useState("");
  const [appName, setAppName] = useState("");
  const [allQueueStatus, setAllQueueStatus] = useState([]);
  const [applicationData, setApplicationData] = useState({});
  const [appQueue, setAppQueue] = useState("undefined");

  const refreshActionButton = useRef(null);

  var defaultPayload = {
    install_folder: "undefined",
    name: "undefined",
    action: "undefined",
    retries: "0",
  };

  const NotificationMessage = (notificationProps) => (
    <div className="flex items-center">
      <AppLogo height={"40px"} width={"40px"} appName={props.app.name} />
      <div className="ml-2">{notificationProps.notificationMessage}</div>
    </div>
  );

  const notify = (action) => {
    const notificationMessage = `${
      action === "install" ? "Installation" : "Uninstallation"
    } Action added to Queue for ${appName}.`;

    toast.info(
      <NotificationMessage notificationMessage={notificationMessage} />,
      {
        position: "top-right",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      }
    );
  };

  const getApplicationDataByName = async () => {
    try {
      const respoonseData = await axios.get(
        "http://localhost:5001/api/applications/" + props.app.name
      );
      return respoonseData.data;
    } catch (error) {
      console.log("Error: ", error);
    }
  };

  const applicationInstallHandler = async () => {
    notify("install");
    getApplicationDataByName().then((appData) => {
      var payloadObj = {
        install_folder: appData.installation_group_folder,
        name: appData.name,
        action: "install",
        retries: "0",
      };
      const applicationPayload = payloadObj;

      axios
        .post(
          "http://localhost:5001/api/add/application/pending_queue",
          applicationPayload
        )
        .then(() => {
          // setAppQueue("pending_queue");
          // props.fetchQueueData();
          props.fetchApplicationAndQueueData();
        })
        .then(() => {
          setTimeout(() => {
            refreshActionButton.current();
          }, 2000);
        })
        .catch((error) => {
          console.error("There was an error!", error);
        });
    });
  };

  const applicationUninstallHandler = async () => {
    notify("uninstall");
    getApplicationDataByName().then((appData) => {
      var payloadObj = {
        install_folder: appData.installation_group_folder,
        name: appData.name,
        action: "uninstall",
        retries: "0",
      };
      const applicationPayload = payloadObj;

      axios
        .post(
          "http://localhost:5001/api/add/application/pending_queue",
          applicationPayload
        )
        .then(() => {
          // setAppQueue("pending_queue");
          // props.fetchQueueData();
          props.fetchApplicationAndQueueData();
        })
        .catch((error) => {
          console.error("There was an error!", error);
        });
    });
  };

  const setUp = () => {
    const slug =
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());
    setAppId(slug);
  };

  const getQueueByAppName2 = () => {
    props.queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === props.app.name) {
        setAppQueue(JSON.parse(obj.payload).name);
        console.log("in GetQueue queue Name: ", obj.routing_key);
        return obj.routing_key;
      } else {
      }
    });

    // .then(() => {
    //   if (res !== undefined) {
    //     // setAppQueue(res);
    //   }
    // });
  };

  const getQueueByAppName = () => {
    return props.queueData.filter(function (obj) {
      // console.log("in GetQueue app Name-1: ", obj);

      if (JSON.parse(obj.payload).name === props.app.name) {
        console.log("in GetQueue queue Name: ", obj.routing_key);
        return obj.routing_key;
      } else {
      }
    });
    // .then((obj) => {
    //   console.log("queue name: ", obj[0].routing_key);
    //   return obj[0].routing_key;
    // });
  };

  const getTransformedName = () => {
    return props.app.name
      .replaceAll("-", " ")
      .replaceAll("_", " ")
      .replace(/\b\w/g, (l) => l.toUpperCase());
  };

  const getSlug = () => {
    return (
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase())
    );
  };

  const fetchAppQueueData33 = async () => {
    return await props.queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === props.app.name) {
        setAppQueue(obj.routing_key);
        // console.log("in GetQueue queue Name: ", obj.routing_key);
        return obj.routing_key;
      } else {
      }
    });
  };

  useEffect(() => {
    // print queue/ instalation status by setAppName
    // console.log("App Name: ", props.app.name);
    // console.log("Installation Status: ", props.getQueNameNew(props.app.name));

    setUp();

    fetchAppQueueData33().catch("Error: ", console.error);

    setAppName(
      props.app.name
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l) => l.toUpperCase())
    );
    return () => {};
  }, [appQueue]);

  const drawAppTags = (appTags) => {
    return appTags.map((appTag, i) => {
      return (
        <li
          key={i}
          className="rounded bg-gray-500 text-sm mr-1.5 mb-2 px-1.5  w-auto inline-block"
        >
          {appTag
            .replaceAll("-", " ")
            .replaceAll("_", " ")
            .replace(/\b\w/g, (l) => l.toUpperCase())}
        </li>
      );
    });
  };

  const UninstallButton = () => {
    return "uninstall button";
  };

  return (
    <>
      {props.isListLayout ? (
        <>
          <div
            className={`cursor-auto flex flex-col col-span-full rounded`}
            loading="lazy"
          >
            <div className="grid grid-cols-12 hover:bg-gray-700 bg-inv2 rounded items-center px-5 py-2">
              <div className="flex col-span-10 items-center">
                <div className="grid grid-cols-12 w-full items-center">
                  <div className="flex col-span-4 w-full">
                    <Link
                      to={"/apps/" + getSlug()}
                      className="mx-3 flex col-span-6"
                    >
                      <div className="flex items-center">
                        {/* Icon */}
                        <div className="">
                          <AppLogo width={"50px"} appName={props.app.name} />
                          {/* <StatusTag installStatus={props.app.queueName} /> */}
                        </div>
                        <div className="mx-3 flex col-span-6">
                          <div>
                            {/* Category name */}
                            <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-1">
                              {props.app.installation_group_folder}
                            </div>
                            <h2 className="hover:underline hover:cursor-pointer text-lg text-white mb-2 flex items-center">
                              {allQueueStatus != "" && (
                                <StatusPoint installStatus={allQueueStatus} />
                              )}
                              {getTransformedName()}
                            </h2>
                          </div>
                        </div>
                      </div>
                    </Link>
                  </div>
                  <div className="flex col-span-8 w-full">
                    <ul className="float-left">
                      {props.app.categories &&
                        drawAppTags(props.app.categories)}
                    </ul>
                  </div>
                </div>
              </div>
              <div className="flex col-span-2 w-full justify-end">
                <ApplicationStatusActionButton
                  // isMqConnected={props.isMqConnected}
                  isMqConnected={true}
                  getQueueStatusList={props.getQueueStatusList}
                  appName={props.app.name}
                  category={props.app.installation_group_folder}
                  applicationInstallHandler={applicationInstallHandler}
                  refreshActionButton={refreshActionButton}
                />
              </div>
            </div>
          </div>
        </>
      ) : (
        <div
          className={`flex flex-col col-span-full bg-inv2 shadow-lg rounded ${
            props.isListLayout ? "col-span-full" : "sm:col-span-6 xl:col-span-4"
          }`}
          loading="lazy"
        >
          <div className="p-6">
            <header className="flex justify-between items-start mb-2">
              {/* Icon */}
              <div className="flex content-start">
                <AppLogo
                  height={"50px"}
                  width={"50px"}
                  appName={props.app.name}
                />
                {/* <StatusTag installStatus={props.app.queueName} /> */}
              </div>
              {/* Menu button */}
              {props.app.installation_group_folder != "core" && (
                <EditMenu className="relative inline-flex">
                  {props.app.installation_group_folder === "completed_queue" ? (
                    <li>
                      <Link
                        className="font-medium text-sm text-red-500 hover:text-red-600 flex py-1 px-3"
                        to="#0"
                      >
                        <div className="flex items-start">
                          <TrashCan32 className="p-1 flex my-auto" />
                        </div>
                        <span className="flex my-auto">Uninstall</span>
                      </Link>
                    </li>
                  ) : (
                    <li>
                      <Link
                        className="font-medium text-sm text-white hover:text-gray-500 flex py-1 px-3"
                        to="#0"
                      >
                        <div className="flex items-start">
                          <Restart32 className="p-1 flex my-auto" />
                        </div>
                        <span className="flex my-auto">Install</span>
                      </Link>
                    </li>
                  )}
                </EditMenu>
              )}
            </header>

            <Link to={"/apps/" + getSlug()}>
              {/* Category name */}
              <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-2">
                {props.app.installation_group_folder}
              </div>
              <h2 className="hover:underline hover:cursor-pointer text-2xl text-white mb-2 flex items-center">
                {allQueueStatus != "" && (
                  <StatusPoint installStatus={allQueueStatus} />
                )}
                {getTransformedName()}
              </h2>
            </Link>
            <div className="text-xs font-semibold text-gray-400 uppercase mb-1"></div>
            <div className="pb-5">{props.app.Description}</div>

            <div className="">
              <ApplicationStatusActionButton
                isMqConnected={props.isMqConnected}
                getQueueStatusList={props.getQueueStatusList}
                appName={props.app.name}
                category={props.app.installation_group_folder}
                applicationInstallHandler={applicationInstallHandler}
              />
            </div>
            {/* Seperator */}
            <div className="pb-3 mb-3 border-b-2 border-gray-600 w-full"></div>

            <div className="float-left">
              <ul className="float-left">
                {props.app.categories && drawAppTags(props.app.categories)}
              </ul>
            </div>
          </div>

          <div className="flex-grow"></div>
        </div>
      )}
    </>
  );
}

export default ApplicationCard2;
