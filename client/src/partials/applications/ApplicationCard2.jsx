import React from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import StatusTag from "../StatusTag";
import StatusPoint from "../StatusPoint";
import { useState, useEffect } from "react";
import AppLogo from "./AppLogo";

function ApplicationCard2(props) {
  const [appId, setAppId] = useState("");
  const [appName, setAppName] = useState("");
  const [queueStatus, setQueueStatus] = useState("");

  const setUp = () => {
    const slug =
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());
    setAppId(slug);
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

  useEffect(() => {
    var queueObj = getAppQueueData(props.app.name)[0];
    if (queueObj != undefined && queueObj != null) {
      setQueueStatus(queueObj.routing_key);
    }
    setAppName(
      props.app.name
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l) => l.toUpperCase())
    );
    return () => {};
  }, [queueStatus]);

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
            <AppLogo appName={props.app.name} />
            {/* <StatusTag installStatus={props.app.queueName} /> */}
          </div>
          {/* Menu button */}
          {props.app.installation_group_folder != "core" && (
            <EditMenu className="relative inline-flex">
              <li>
                <Link
                  className="font-medium text-sm text-white hover:text-gray-500 flex py-1 px-3"
                  to="#0"
                >
                  <div className="flex items-start">
                    <Restart32 className="p-1 flex my-auto" />
                  </div>
                  <span className="flex my-auto">Reinstall</span>
                </Link>
              </li>

              <li>
                <Link
                  className="font-medium text-sm text-red-500 hover:text-red-600 flex py-1 px-3"
                  to="#0"
                >
                  <div className="flex items-start">
                    <TrashCan32 className="p-1 flex my-auto" />
                  </div>
                  <span className="flex my-auto">Delete</span>
                </Link>
              </li>
            </EditMenu>
          )}
        </header>
        <Link to={"/apps/" + appId}>
          {/* Category name */}
          <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-2">
            {props.app.installation_group_folder}
          </div>
          <h2 className="hover:underline hover:cursor-pointer text-2xl text-white mb-2 flex items-center">
            {queueStatus != "" && <StatusPoint installStatus={queueStatus} />}
            {appName}
          </h2>
        </Link>
        <div className="text-xs font-semibold text-gray-400 uppercase mb-1"></div>
        <div className="pb-5">{props.app.Description}</div>
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
