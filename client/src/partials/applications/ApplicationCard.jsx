import React from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { HiOutlineInformationCircle } from "react-icons/hi";
import StatusTag from "../StatusTag";
import StatusPoint from "../StatusPoint";
import { useState, useEffect, useRef } from "react";
import AppLogo from "./AppLogo";
import { toast } from "react-toastify";
import LinearProgress from "@mui/material/LinearProgress";
import axios from "axios";
import ApplicationStatusActionButton from "./ApplicationStatusActionButton";
import ApplicationCategoryTag from "../ApplicationCategoryTag";
import Tooltip from "@mui/material/Tooltip";
import Checkbox from "@mui/material/Checkbox";

function ApplicationCard(props) {
  const { history } = props;

  const [appId, setAppId] = useState("");
  const [appName, setAppName] = useState("");
  const [allQueueStatus, setAllQueueStatus] = useState([]);
  const [applicationData, setApplicationData] = useState({});
  const [appQueue, setAppQueue] = useState("undefined");
  const [isSelected, setIsSelected] = useState(false);
  const [isHover, setIsHover] = useState(false);
  const [isHovering, setIsHovering] = useState(false);

  const refreshActionButton = useRef(null);

  const selectHandler = () => {
    setIsSelected(!isSelected);
    if (isSelected) {
      props.applicationSelectedCount("select");
    } else {
      props.applicationSelectedCount("unselect");
    }
  };

  const handleMouseOver = () => {
    setIsHovering(true);
  };

  const handleMouseOut = () => {
    setIsHovering(false);
  };

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
          // setTimeout(() => {
          //   refreshActionButton.current();
          // }, 2000);
        })
        .catch((error) => {
          console.error("There was an error!", error);
        });
    });
  };

  const actionHandler = async (installFolder, name, action) => {
    //TODO -> rewrite notify function
    //notify("action")
    getApplicationDataByName().then((appData) => {
      var payloadObj = {
        install_folder: installFolder,
        name: name,
        action: action,
        retries: "0",
      };
      const applicationPayload = payloadObj;

      if (action === "install") {
        axios
          .post(
            // TODO -> add new endpoint for task actions
            "http://localhost:5001/api/add/application/pending_queue",
            applicationPayload
          )
          .then(() => {
            // TODO rewrite to fetchAppsData() + fetchQueuesData()
            props.fetchApplicationAndQueueData();
          })
          .catch((error) => {
            console.error("Installation Error: ", error);
          });
      } else if (action === "uninstall") {
        axios
          .get
          // TODO -> add consume function
          ()
          .then(() => {
            // TODO rewrite to fetchAppsData() + fetchQueuesData()
            props.fetchApplicationAndQueueData();
          })
          .catch((error) => {
            console.error("Uninstallation Error: ", error);
          });
      } else if (action === "taskExecution") {
        // add post request for task execution
      }
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
    console.log("App: ", props.app);
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
  }, [appQueue, isSelected]);

  const drawAppTags = (appTags) => {
    return appTags.map((appTag, i) => {
      return (
        <ApplicationCategoryTag
          appTag={appTag}
          keyId={i}
          addCategoryTofilterTags={props.addCategoryTofilterTags}
        />
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
            className={`cursor-auto flex flex-col col-span-full rounded ${
              props.isListLayout
                ? "col-span-full"
                : "sm:col-span-6 xl:col-span-4"
            }`}
            loading="lazy"
          >
            <div className="grid grid-cols-12 hover:bg-gray-700 bg-inv3 rounded items-center px-5 py-2">
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
                          <AppLogo
                            //height={"40px"}
                            //width={"40px"}
                            appName={props.app.name}
                          />
                          {/* <StatusTag installStatus={props.app.queueName} /> */}
                        </div>
                        <div className="mx-3 flex col-span-6">
                          <div>
                            {/* Category name */}
                            <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-1">
                              {props.app.installation_group_folder}
                            </div>
                            <h2 className="hover:underline hover:cursor-pointer text-[16px] text-white mb-2 flex items-center">
                              {allQueueStatus != "" && (
                                <StatusPoint installStatus={allQueueStatus} />
                              )}
                              {getTransformedName()}
                              <Tooltip
                                title={props.app.Description}
                                placement="top"
                                arrow
                              >
                                <button className="inline">
                                  <HiOutlineInformationCircle className="ml-1" />
                                </button>
                              </Tooltip>
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
                  isMqConnected={props.isMqConnected}
                  getQueueStatusList={props.getQueueStatusList}
                  appName={props.app.name}
                  category={props.app.installation_group_folder}
                  applicationInstallHandler={applicationInstallHandler}
                  applicationUninstallHandler={applicationUninstallHandler}
                  refreshActionButton={refreshActionButton}
                />
              </div>
            </div>
          </div>
        </>
      ) : (
        <div
          className={`relative flex flex-col col-span-full ${
            isSelected ? "hover:border-kxBlue" : "hover:bg-gray-700"
          } hover:bg-gray-700 bg-inv3 rounded border-2 ${
            isSelected ? "border-kxBlue" : "border-inv3"
          } hover:border-2 hover:border-gray-600 ${
            props.isListLayout ? "col-span-full" : "sm:col-span-6 xl:col-span-3"
          }`}
          loading="lazy"
          onMouseOver={handleMouseOver}
          onMouseOut={handleMouseOut}
          s
        >
          <div className="p-6">
            <header className="flex justify-between items-start mb-2">
              {/* Icon */}
              <div className="">
                <AppLogo
                  //height={"50px"}
                  // width={"50px"}
                  appName={props.app.name}
                />
                {/* <StatusTag installStatus={props.app.queueName} /> */}
              </div>
              {/* Menu button */}
              {/* {props.app.installation_group_folder != "core" && (
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
              )} */}
              <div className="">
                <div
                  className={`${
                    isHovering || isSelected ? "visible" : "hidden"
                  }`}
                >
                  <Checkbox checked={isSelected} onChange={selectHandler} />
                </div>
              </div>
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
                <Tooltip title={props.app.Description} placement="top" arrow>
                  <button className="inline-block">
                    <HiOutlineInformationCircle className="ml-1 text-base" />
                  </button>
                </Tooltip>
              </h2>
            </Link>
            <div className="text-xs font-semibold text-gray-400 uppercase mb-1"></div>
            {/* <div className="pb-5 line-clamp-4">{props.app.Description}</div> */}
            <div className="">
              {/* {console.log("in render queue: ", appQueue)} */}
              {/* {appQueue === "pending_queue" && (
            <button
              className="bg-kxBlue/50 p-3 px-5 rounded items-center flex"
              disabled
            >
              <svg
                className="animate-spin -ml-1 mr-3 h-5 w-5 text-white"
                fill="none"
                viewBox="0 0 24 24"
              >
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                ></circle>
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                ></path>
              </svg>
              Installing...
            </button>
          )} */}
              {/* {!props.isMqConnected && (
            <div className="text-red-500 border-red-500 rounded-md border p-2 flex">
              <AiOutlineWarning className="mt-auto mb-auto table text-4xl mr-2" />
              Installation Status not available. Please check conneciton to
              RabbitMQ service.
            </div>
          )} */}
              {/* 
          {appQueue != "pending_queue" &&
            (appQueue != "completed_queue" && props.isMqConnected ? (
              <div className="">
                <button
                  onClick={applicationInstallHandler}
                  className="bg-kxBlue p-3 px-5 rounded items-center flex"
                >
                  Install
                </button>

                {appQueue === "failed_queue" && (
                  <div className="p-2 mt-4 rounded-md text-red-500 flex item-center border border-red-500">
                    <AiOutlineWarning className="mt-auto mb-auto table text-2xl mr-2" />
                    <div>
                      ERROR: An error occured when trying to install {appName}.
                    </div>
                  </div>
                )}
              </div>
            ) : (
              ""
            ))}
          */}

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
            <div className="float-left h-12">
              <ul className="float-left">
                {props.app.categories && drawAppTags(props.app.categories)}
              </ul>
            </div>
          </div>
          <div className="flex-grow"></div>
          {/* <div
            className={`w-full bg-gray-500 absolute bottom-0 transform transition-all duration-300 ease-in ${
              isHovering
                ? "visible transform transition duration-300 h-20"
                : "scale-y-0 h-0"
            }`}
          >
            Test
          </div> */}

          <div
            className={`w-full bg-gray-700 absolute -bottom-20 h-20 p-5 ${
              isHovering
                ? "h-20 visible transition-transform -translate-y-20 ease-out duration-500"
                : ""
            }`}
          >
            {props.app.available_tasks ? props.app.available_tasks.length : 0}{" "}
            Executable Tasks.
          </div>
          <div className="w-full absolute bg-inv1 h-20 -bottom-20"></div>
        </div>
      )}
    </>
  );
}

export default ApplicationCard;
