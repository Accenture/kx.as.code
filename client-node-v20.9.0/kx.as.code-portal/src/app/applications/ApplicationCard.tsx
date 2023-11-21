import React, { useState, useEffect, useRef } from "react";
import { HiOutlineInformationCircle } from "react-icons/hi";
import StatusPoint from "./StatusPoint";
import AppLogo from "./AppLogo";
import { toast } from "react-toastify";
import axios from "axios";
import ApplicationStatusActionButton from "./ApplicationActionButton";
import ApplicationCategoryTag from "./ApplicationCategoryTag";
import Tooltip from "@mui/material/Tooltip";
import Checkbox from "@mui/material/Checkbox";
import Link from 'next/link';

interface NotificationMessageProps {
  notificationMessage: string;
}

interface ApplicationCardProps {
  key: number;
  app: any;
  queueStatus: Promise<any[]>;
  queueList: string[];
  layout: boolean;
  addCategoryTofilterTags: (newCategoryObj: any) => void;
  isMqConnected: boolean;
  onCheck: (isChecked: boolean) => void;
  fetchApplicationAndQueueData: () => void;
  getQueueStatusList: (appName: string) => string[];
  isListLayout: boolean;
  queueData: any;
  applicationSelectedCount: (action: string) => void;
}

function ApplicationCard(props: ApplicationCardProps) {

  const [appId, setAppId] = useState<string>("");
  const [appName, setAppName] = useState<string>("");
  const [allQueueStatus, setAllQueueStatus] = useState<string[]>([]);
  const [appQueue, setAppQueue] = useState<string | undefined>("undefined");
  const [isHovering, setIsHovering] = useState<boolean>(false);
  const [isChecked, setIsChecked] = useState<boolean>(false);

  // const refreshActionButton = useRef<any>(null);

  const handleCheckboxChange = (isChecked: boolean) => {
    setIsChecked(isChecked);
    props.onCheck(isChecked);
  };

  const handleMouseOver = () => {
    setIsHovering(true);
  };

  const handleMouseOut = () => {
    setIsHovering(false);
  };

  const NotificationMessage: React.FC<NotificationMessageProps> = (
    notificationProps
  ) => (
    <div className="flex items-center">
      <AppLogo appName={props.app.name} />
      <div className="ml-2">{notificationProps.notificationMessage}</div>
    </div>
  );

  const notify = (action: string) => {
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
      const responseData = await axios.get(
        "http://localhost:5001/api/applications/" + props.app.name
      );
      return responseData.data;
    } catch (error) {
      console.log("Error: ", error);
    }
  };

  const applicationInstallHandler = async () => {
    notify("install");
    getApplicationDataByName().then((appData) => {
      const payloadObj = {
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
          props.fetchApplicationAndQueueData();
        })
        .catch((error) => {
          console.error("There was an error!", error);
        });
    });
  };

  const applicationUninstallHandler = async () => {
    notify("uninstall");
    getApplicationDataByName().then((appData) => {
      const payloadObj = {
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
        .replace(/\b\w/g, (l:any) => l.toLowerCase());
    setAppId(slug);
  };

  const getTransformedName = () => {
    return props.app.name
      .replaceAll("-", " ")
      .replaceAll("_", " ")
      .replace(/\b\w/g, (l:any) => l.toUpperCase());
  };

  const getSlug = () => {
    return (
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l:any) => l.toLowerCase())
    );
  };

  useEffect(() => {
    console.log("App: ", props.app);
    setUp();
    setAppName(
      props.app.name
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l:any) => l.toUpperCase())
    );
    return () => {};
  }, [appQueue]);

  const drawAppTags = (appTags: string[]) => {
    return appTags.map((appTag, i) => (
      <ApplicationCategoryTag
        appTag={appTag}
        keyId={i}
        addCategoryTofilterTags={props.addCategoryTofilterTags}
      />
    ));
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
          >
            <div className="grid grid-cols-12 hover:bg-[#3d4d63] bg-gray-700 rounded items-center px-5 py-2">
              <div className="flex col-span-10 items-center">
                <div className="grid grid-cols-12 w-full items-center">
                  <div className="flex col-span-4 w-full">
                    {/* <Link
                      to={"/apps/" + getSlug()}
                      className="mx-3 flex col-span-6"
                    > */}
                      <div className="flex items-center">
                        <div className="h-auto w-10">
                          <AppLogo appName={props.app.name} />
                        </div>
                        <div className="mx-3 flex col-span-6">
                          <div>
                            <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-1">
                              {props.app.installation_group_folder}
                            </div>
                            <h2 className="hover:underline hover:cursor-pointer text-[16px] text-white mb-2 flex items-center">
                              {/* {
                              allQueueStatus != "" && (
                                <StatusPoint installStatus={allQueueStatus} />
                              )} */}
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
                    {/* </Link> */}
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
                  // refreshActionButton={refreshActionButton}
                />
              </div>
            </div>
          </div>
        </>
      ) : (
        <div
          className={`relative flex flex-col col-span-full ${
            isChecked ? "hover:border-[#5a86ff]" : "hover:bg-[#3d4d63]"
          } hover:bg-[#3d4d63] bg-gray-700 rounded border-2 ${
            isChecked ? "border-kxBlue" : "border-gray-700"
          } ${
            props.isListLayout ? "col-span-full" : "sm:col-span-6 xl:col-span-3"
          }`}
          onMouseOver={handleMouseOver}
          onMouseOut={handleMouseOut}
        >
          <div className="p-6">
            <header className="flex justify-between items-start mb-2">
              <div className="h-auto w-10">
                <AppLogo appName={props.app.name} />
              </div>
              <div className="">
                <div
                  className={`${
                    isHovering || isChecked ? "visible" : "hidden"
                  }`}
                >
                  <Checkbox
                    checked={isChecked}
                    onChange={(e) => handleCheckboxChange(e.target.checked)}
                  />
                </div>
              </div>
            </header>
            {/* <Link to={"/apps/" + getSlug()}> */}
              <div className="text-white bg-ghBlack2 rounded p-0 px-1.5 uppercase w-fit inline-block my-2">
                {props.app.installation_group_folder}
              </div>
              <h2 className="hover:underline hover:cursor-pointer text-2xl text-white mb-2 flex items-center">
                {/* {allQueueStatus != "" && (
                  <StatusPoint installStatus={allQueueStatus} />
                )} */}
                {getTransformedName()}
                <Tooltip title={props.app.Description} placement="top" arrow>
                  <button className="inline-block">
                    <HiOutlineInformationCircle className="ml-1 text-base" />
                  </button>
                </Tooltip>
              </h2>
            {/* </Link> */}
            <div className="">
              <ApplicationStatusActionButton
                isMqConnected={props.isMqConnected}
                getQueueStatusList={props.getQueueStatusList}
                appName={props.app.name}
                category={props.app.installation_group_folder}
                applicationInstallHandler={applicationInstallHandler}
                applicationUninstallHandler={applicationUninstallHandler}
              />
            </div>
            <div className="pb-3 mb-3 border-b-2 border-gray-600 w-full"></div>
            <div className="float-left h-12">
              <ul className="float-left">
                {props.app.categories && drawAppTags(props.app.categories)}
              </ul>
            </div>
          </div>
          <div className="flex-grow"></div>
          <div
            className={`w-full bg-[#3d4d63] absolute bottom-[-82px] h-20 p-5 ${
              isHovering
                ? "h-20 visible transition-transform translate-y-[-82px] ease-out duration-500"
                : ""
            }`}
          >
            <span className="font-bold text-gray-400">Available Tasks: </span>
            {props.app.available_tasks
              ? props.app.available_tasks.length
              : 0}
          </div>
          <div className="w-full absolute bg-inv1 h-20 bottom-[-82px]"></div>
        </div>
      )}
    </>
  );
}

export default ApplicationCard;
