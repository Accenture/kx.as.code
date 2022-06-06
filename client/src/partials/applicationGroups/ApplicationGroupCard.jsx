import React, { useState, useEffect, Component } from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import ApplicationStatusActionButton from "../applications/ApplicationStatusActionButton";

function ApplicationGroupCard(props) {
  const appGroupBreadcrumb = props.appGroup.name
    .replaceAll(" ", "-")
    .replace(/\b\w/g, (l) => l.toLowerCase());
  const appGroupCategory = props.appGroup.group_category
    .toUpperCase()
    .replaceAll("_", " ");

  const [appGroupComponents, setAppGroupComponents] = useState([]);
  const [isMqConnected, setIsMqConnected] = useState(true);

  useEffect(() => {
    console.log("useEffect called.");
    return () => {};
  }, []);

  const drawApplicationGroupCardComponentsTags = (appGroupComponentTags) => {
    return appGroupComponentTags.map((appGroupComponent, i) => {
      return (
        <li
          key={i}
          className="rounded bg-gray-500 text-sm mr-1.5 mb-2 px-1.5  w-auto inline-block"
        >
          {appGroupComponent
            .replaceAll("-", " ")
            .replaceAll("_", " ")
            .replace(/\b\w/g, (l) => l.toUpperCase())}
        </li>
      );
    });
  };

  return (
    <div className="col-span-full sm:col-span-6 xl:col-span-4 bg-inv2 rounded">
      <div className="relative h-[400px]">
        <div className="flex-col justify-between p-6">
          {/* Header */}
          <header className="flex justify-between items-start">
            {/* Category name */}
            <div className="text-white bg-ghBlack2 rounded p-0 px-1.5">
              {appGroupCategory}
            </div>

            {/* Menu button */}
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
                  <span className="flex my-auto">Uninstall</span>
                </Link>
              </li>
            </EditMenu>
          </header>

          <div className="">
            <Link to={"/application-groups/" + appGroupBreadcrumb}>
              <h2 className="hover:underline hover:cursor-pointer text-2xl text-white">
                {props.appGroup.name}
              </h2>
            </Link>
          </div>

          {/* Main Card Content */}
          <div className="mb-4">{props.appGroup.description}</div>

          <div className="float-left">
            <ul className="float-left">
              {drawApplicationGroupCardComponentsTags(
                props.appGroup.components
              )}
            </ul>
          </div>
          <ApplicationStatusActionButton
            // isMqConnected={props.isMqConnected}
            isMqConnected={true}
            getQueueStatusList={() => {}}
            appName={""}
            category={""}
            applicationInstallHandler={() => {}}
            refreshActionButton={() => {}}
          />
        </div>

        {/* <div className="w-full flex justify-center">
          <button
            disabled
            className="btn rounded bg-kxBlue hover:bg-kxBlue2 p-2 px-6 absolute bottom-0 mb-8 "
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
            INSTALLING
          </button>
        </div> */}

        {/* Install Processing Bar */}
        {/* <div className="">
          <div className="rounded-t-none rounded bg-statusNewGreen absolute bottom-0 justify-center flex px-6 h-3 w-full"></div>
        </div> */}
      </div>
    </div>
  );
}

export default ApplicationGroupCard;
