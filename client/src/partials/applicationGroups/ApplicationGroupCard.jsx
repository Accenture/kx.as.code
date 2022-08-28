import React, { useState, useEffect, Component } from "react";
import { Link } from "react-router-dom";
import EditMenu from "../EditMenu";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import ApplicationStatusActionButton from "../applications/ApplicationStatusActionButton";

import image from "../../media/png/appImgs/postman.png";

import AliceCarousel from "react-alice-carousel";
import "react-alice-carousel/lib/alice-carousel.css";

const responsive = {
  0: { items: 3 },
  568: { items: 3 },
  1024: { items: 3 },
};
const Gallery = (props) => {
  return (
    <AliceCarousel
      mouseTracking
      items={props.itemsList}
      responsive={responsive}
      controlsStrategy="default"
      disableDotsControls={true}
      // paddingRight={20}
    />
  );
};

const handleDragStart = (e) => e.preventDefault();

function ApplicationGroupCard(props) {
  const appGroupBreadcrumb = props.appGroup.title
    .replaceAll(" ", "-")
    .replace(/\b\w/g, (l) => l.toLowerCase());
  //const appGroupCategory = props.appGroup.group_category.toUpperCase().replaceAll("_", " ");

  const [appGroupComponents, setAppGroupComponents] = useState([]);
  const [isMqConnected, setIsMqConnected] = useState(true);
  const [itemsList, setItemsList] = useState([]);

  useEffect(() => {
    fetchAllComponents(props.appGroup.action_queues);
    return () => {};
  }, []);

  async function fetchAllComponents(action_queues) {
    var components = await action_queues["install"].map((q) => {
      return q.name;
    });
    setImageList(components);
  }

  const setImageList = (appGroupComponents) => {
    // var itemsTmp = [];
    appGroupComponents.map((appName) => {
      console.log("appName setImg: ", appName);
      console.log("itemsList: ", itemsList);

      // const res = import(`../../media/png/appImgs/${appName}.png`);
      // console.log("RES: ", res);

      // setItemsList(

      // )
      //   <img
      //     src={require(`../../media/png/appImgs/${appName}.png`).default}
      //     onDragStart={handleDragStart}
      //     role="presentation"
      //   />
      // );

      // setItemsList(itemsTmp);

      setItemsList((current) => [
        ...current,
        <img
          className="bg-ghBlack3 p-3 rounded"
          heigth="50px"
          width="50px"
          src={require(`../../media/png/appImgs/${appName}.png`).default}
          onDragStart={handleDragStart}
          role="presentation"
        />,
      ]);
    });
  };

  const drawComponentsWithAppImages = () => {};

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
    <div className="col-span-full sm:col-span-6 xl:col-span-3 hover:bg-gray-700 bg-inv3 rounded">
      <div className="relative">
        <div className="p-6">
          {/* Header */}
          <div className="h-[100px]">
            <header className="flex justify-between items-start">
              {/* Category name */}
              <div className="text-white bg-ghBlack2 rounded p-0 px-1.5">
                {"Undefined"}
              </div>
            </header>

            <div className="">
              <Link to={"/application-groups/" + appGroupBreadcrumb}>
                <h2
                  className="hover:underline hover:cursor-pointer text-2xl text-white truncate"
                  alt={props.appGroup.title}
                >
                  {props.appGroup.title}
                </h2>
              </Link>
            </div>
          </div>

          {/* Main Card Content */}
          <div className="mb-4">{props.appGroup.description}</div>

          <div className="flex h-[50px]">
            <ul className="float-left">
              {drawApplicationGroupCardComponentsTags(appGroupComponents)}
            </ul>
          </div>
          <div>
            <Gallery itemsList={itemsList} />
          </div>
          <div className="">
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
