import React from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import StatusTag from "../StatusTag";
import StatusPoint from "../StatusPoint";
import { useState, useEffect } from "react";
import AppLogo from "./AppLogo";
import { toast } from "react-toastify";

function ApplicationCard2(props) {
  const { history } = props;

  const [appId, setAppId] = useState("");
  const [appName, setAppName] = useState("");
  const [queueStatus, setQueueStatus] = useState("");

  const NotificationMessage = ({ closeToast, toastProps }) => (
    <div className="flex items-center">
      <AppLogo height={"40px"} width={"40px"} appName={props.app.name} />
      <div className="ml-2"> Installation started for {appName}.</div>
    </div>
  );

  const notify = () => {
    const notificationMessage2 = "Installation started for " + appName + ".";

    toast.info(<NotificationMessage />, {
      position: "top-right",
      autoClose: 5000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
      theme: "dark",
    });
  };

  const applicationInstallHandler = () => {
    notify();
  };

  const setUp = () => {
    const slug =
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());
    setAppId(slug);

    const queueObj = getAppQueueData(props.app.name)[0];

    if (queueObj != undefined && queueObj != null) {
      setQueueStatus(queueObj.routing_key);
    }
  };

  const getAppQueueData = (appName) => {
    var queueName = props.queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === appName) {
        return obj;
      } else {
      }
    });
    return queueName;
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
  useEffect(() => {
    setUp();

    setAppName(
      props.app.name
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l) => l.toUpperCase())
    );
    return () => {};
  }, []);

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

  return (
    <div
      className="flex flex-col col-span-full sm:col-span-6 xl:col-span-4 bg-inv2 shadow-lg rounded"
      loading="lazy"
    >
      <div className="p-6">
        <header className="flex justify-between items-start mb-2">
          {/* Icon */}
          <div className="flex content-start">
            <AppLogo height={"50px"} width={"50px"} appName={props.app.name} />
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
            {queueStatus != "" && <StatusPoint installStatus={queueStatus} />}
            {getTransformedName()}
          </h2>
        </Link>
        <div className="text-xs font-semibold text-gray-400 uppercase mb-1"></div>
        <div className="pb-5">{props.app.Description}</div>
        <div className="pb-3 mb-3 border-b-2 border-gray-600">
          {queueStatus === "pending_queue" ? (
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
          ) : (
            <button
              onClick={applicationInstallHandler}
              className="bg-kxBlue p-3 px-5 rounded items-center flex"
            >
              Install
            </button>
          )}
        </div>
        <div className="float-left">
          <ul className="float-left">
            {props.app.categories && drawAppTags(props.app.categories)}
          </ul>
        </div>
      </div>

      <div className="flex-grow"></div>
    </div>
  );
}

export default ApplicationCard2;
