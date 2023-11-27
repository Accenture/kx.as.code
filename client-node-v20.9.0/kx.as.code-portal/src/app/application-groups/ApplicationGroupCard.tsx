import React, { useState, useEffect } from "react";
import Link from "next/link";
import Image from 'next/image';
import {
  CarouselProvider,
  Slider,
  Slide,
  ButtonBack,
  ButtonNext,
} from "pure-react-carousel";
import "pure-react-carousel/dist/react-carousel.es.css";
import { MdArrowBackIosNew, MdArrowForwardIos } from "react-icons/md";
import ApplicationStatusActionButton from "../applications/ApplicationStatusActionButton";
import Tooltip from "@mui/material/Tooltip";
import { transformName } from "../utils/application";


interface ApplicationGroupCardProps {
  appGroup: any; // Replace 'any' with the actual type if available
}

const handleDragStart = (e: React.DragEvent<HTMLImageElement>) => e.preventDefault();

const ApplicationGroupCard: React.FC<ApplicationGroupCardProps> = (props) => {
  const appGroupBreadcrumb = props.appGroup.title
    .replaceAll(" ", "-")
    .replace(/\b\w/g, (l: any) => l.toLowerCase());

  const [appGroupComponents, setAppGroupComponents] = useState<string[]>([]);
  const [itemsList, setItemsList] = useState<JSX.Element[]>([]);

  useEffect(() => {
    fetchAllComponents(props.appGroup.action_queues);
    return () => { };
  }, [props.appGroup]);

  async function fetchAllComponents(action_queues: { install: { name: string }[] }) {
    const components = action_queues.install.map((q) => q.name);
    setImageList(components);
    setAppGroupComponents(components);
  }

  const setImageList = (appGroupComponents: string[]) => {
    // Clear the itemsList
    setItemsList([]);

    appGroupComponents.forEach((appName, i) => {
      setItemsList((current) => [
        ...current,
        // <Image
        //   className="p-1 object-contain"
        //   src={`/media/png/appImgs/${appName}.png`}
        //   height={50}
        //   width={50}
        //   alt=""
        //   key={i}
        //   onDragStart={handleDragStart}
        //   role="presentation"
        // />
        <img
          className="p-1"
          style={{ height: '60px', width: '60px', objectFit: 'contain' }}
          src={`/media/png/appImgs/${appName}.png`}
          onDragStart={handleDragStart}
          role="presentation"
          key={i}
        />,
      ]);
    });
  };

  const drawApplicationGroupCardComponentsTags = (appGroupComponentTags: string[]) => {
    return appGroupComponentTags.map((appGroupComponent, i) => (
      <li
        key={i}
        className="bg-gray-500 text-sm mr-1.5 mb-2 px-1.5 w-auto inline-block"
      >
        {appGroupComponent
          .replaceAll("-", " ")
          .replaceAll("_", " ")
          .replace(/\b\w/g, (l) => l.toUpperCase())}
      </li>
    ));
  };

  return (
    <div className="col-span-full sm:col-span-6 xl:col-span-3 hover:bg-ghBlack3 bg-ghBlack2">
      <div className="relative">
        <div className="p-6">
          {/* Header */}
          <div className="pb-4">
            <header className="items-start">
              <div className="flex items-center">
                <Link href={`/application-groups/${appGroupBreadcrumb}`}>
                  <h2
                    className="hover:underline hover:cursor-pointer text-lg text-white truncate"
                  >
                    {props.appGroup.title}
                  </h2>
                </Link>
              </div>
              <div className="text-gray-400 text-sm">
                {appGroupComponents.length}{" "}
                {appGroupComponents.length > 1 ? "Applications" : "Application"}
              </div>
            </header>
          </div>

          {/* Main Card Content */}
          <div className=" h-28">
            <CarouselProvider
              visibleSlides={4}
              totalSlides={appGroupComponents.length}
              step={1}
              naturalSlideWidth={500}
              naturalSlideHeight={500}
            >
              <div className="flex items-center py-5">
                <div className="h-14">
                  <ButtonBack className="hover:bg-ghBlack4 px-3 text-sm items-center flex h-full">
                    <MdArrowBackIosNew />
                  </ButtonBack>
                </div>
                <div className="w-full">
                  <Slider className="">{itemsList.map((image, i) => {
                    return (
                      <Slide index={i} key={i}>
                        <Tooltip
                          title={transformName(appGroupComponents[i])}
                          placement="top"
                          arrow
                        >
                          <div className="flex items-center justify-center hover:bg-ghBlack4 p-1 hover:pointer h-14" key={i}>
                            {image}
                          </div>
                        </Tooltip>
                      </Slide>
                    );
                  })}</Slider>
                </div>
                <div className="h-14">
                  <ButtonNext className="hover:bg-ghBlack4 px-3 text-sm items-center flex h-full">
                    <MdArrowForwardIos />
                  </ButtonNext>
                </div>
              </div>
            </CarouselProvider>
          </div>
          <div className="">
            <ApplicationStatusActionButton
              isMqConnected={true}
              getQueueStatusList={() => { }}
              appName={""}
              category={""}
              applicationInstallHandler={() => { }}
              refreshActionButton={() => { }}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

export default ApplicationGroupCard;
