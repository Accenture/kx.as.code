import React, { useState, useEffect, Component } from "react";
import { Link, NavLink } from "react-router-dom";
// import EditMenu from "../EditMenu";
// import { TrashCan32, Restart32 } from "@carbon/icons-react";
import ApplicationStatusActionButton from "../applications/ApplicationStatusActionButton";
import { MdArrowBackIosNew } from "react-icons/md";
import { MdArrowForwardIos } from "react-icons/md";
import {
  CarouselProvider,
  Slider,
  Slide,
  ButtonBack,
  ButtonNext,
} from "pure-react-carousel";
import "pure-react-carousel/dist/react-carousel.es.css";
import Tooltip from "@mui/material/Tooltip";

// import image from "../../media/png/appImgs/postman.png";

// import AliceCarousel from "react-alice-carousel";
import "react-alice-carousel/lib/alice-carousel.css";

// const responsive = {
//   0: { items: 3 },
//   568: { items: 3 },
//   1024: { items: 3 },
// };
// const Gallery = (props) => {
//   return (
//     <AliceCarousel
//       mouseTracking
//       items={props.itemsList}
//       responsive={responsive}
//       controlsStrategy="default"
//       disableDotsControls={true}
//       // paddingRight={20}
//     />
//   );
// };

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
    setAppGroupComponents(components);
  }

  const setImageList = (appGroupComponents) => {
    // var itemsTmp = [];
    appGroupComponents.map((appName) => {
      setItemsList((current) => [
        ...current,
        <img
          className="p-1 rounded"
          style={{ height: "50px", width: "50px" }}
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
          <div className="pb-4">
            <header className="flex justify-between items-start">
              {/* Category name */}
              {/* <div className="text-white bg-ghBlack2 rounded p-0 px-1.5">
                {"Undefined"}
              </div> */}
            </header>

            <div className="flex items-center">
              <Link to={"/application-groups/" + appGroupBreadcrumb}>
                <h2
                  className="hover:underline hover:cursor-pointer text-lg text-white truncate"
                  alt={props.appGroup.title}
                >
                  {props.appGroup.title}
                </h2>
              </Link>
              {/* <div className="bg-ghBlack2 p-1 rounded center text-center ml-3 w-8 text-sm">
                {appGroupComponents.length}
              </div> */}
            </div>
            <div className="text-gray-500">
              {appGroupComponents.length} Applications
            </div>
          </div>

          {/* Main Card Content */}
          {/* <div className="mb-4">{props.appGroup.description}</div> */}
          {/* 
          <div className="flex">
            <ul className="float-left">
              {drawApplicationGroupCardComponentsTags(appGroupComponents)}
            </ul>
          </div> */}
          <div className="">
            {/* <Gallery itemsList={itemsList} /> */}

            <CarouselProvider
              visibleSlides={4}
              totalSlides={appGroupComponents.length}
              step={1}
              naturalSlideWidth={500}
              naturalSlideHeight={500}
            >
              <div className="flex items-center py-5                                                                                                                                                                                                                                                                                                                                                                                   ">
                <div className="h-14">
                  <ButtonBack className="hover:bg-gray-600 px-3 text-sm rounded items-center flex h-full">
                    <MdArrowBackIosNew />
                  </ButtonBack>
                </div>
                <div className="w-full">
                  <Slider>
                    {itemsList.map((image, i) => {
                      return (
                        <Slide index={i}>
                          <Tooltip
                            title={appGroupComponents[i]}
                            placement="top"
                            arrow
                          >
                            <NavLink to={`/apps/${appGroupComponents[i]}`}>
                              <div className="flex justify-center rounded-md hover:bg-gray-600 p-1 hover:pointer">
                                {image}
                              </div>
                            </NavLink>
                          </Tooltip>
                        </Slide>
                      );
                    })}
                  </Slider>
                </div>
                <div className="h-14">
                  <ButtonNext className="hover:bg-gray-600 px-3 text-sm rounded items-center flex h-full">
                    <MdArrowForwardIos />
                  </ButtonNext>
                </div>
              </div>

              {/* <div className="flex justify-between pb-4">
                <ButtonBack className="hover:bg-gray-600 p-2 px-3 text-sm rounded items-center flex">
                  <MdArrowBackIosNew />
                </ButtonBack>
                <ButtonNext className="hover:bg-gray-600 p-2 px-3 text-sm rounded items-center flex">
                  <MdArrowForwardIos />
                </ButtonNext>
              </div> */}
            </CarouselProvider>
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
      </div>
    </div>
  );
}

export default ApplicationGroupCard;
