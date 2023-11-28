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
    const notificationMessage = `${action === "install" ? "Installation" : "Uninstallation"
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
        .replace(/\b\w/g, (l: any) => l.toLowerCase());
    setAppId(slug);
  };

  const getTransformedName = () => {
    return props.app.name
      .replaceAll("-", " ")
      .replaceAll("_", " ")
      .replace(/\b\w/g, (l: any) => l.toUpperCase());
  };

  const getSlug = () => {
    return (
      props.app.name &&
      props.app.name
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l: any) => l.toLowerCase())
    );
  };

  useEffect(() => {
    // console.log("App: ", props.app);
    setUp();
    setAppName(
      props.app.name
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l: any) => l.toUpperCase())
    );
    return () => { };
  }, [appQueue]);

  const drawAppTags = (appTags: string[]) => {
    return appTags.map((appTag, i) => (
      <ApplicationCategoryTag
        appTag={appTag}
        key={i}
        addCategoryTofilterTags={props.addCategoryTofilterTags}
      />
    ));
  };

  return (
    <>
      {props.isListLayout ? (
        <>
          <div
            className={`cursor-auto flex flex-col col-span-full ${props.isListLayout
              ? "col-span-full"
              : "sm:col-span-6 xl:col-span-4"
              }`}
          >
            <div className="grid grid-cols-12 hover:bg-ghBlack3 bg-ghBlack2 items-center py-1">
              <div className="flex col-span-10 items-center">
                <div className="grid grid-cols-12 items-center">
                  <div className="flex col-span-4 pr-5 border-r-2 border-ghBlack">

                    <div className="flex items-center w-[280px] pl-5">
                      <div className="h-auto w-10">
                        <AppLogo appName={props.app.name} />
                      </div>
                      <div className="mx-3 flex col-span-6">
                        <div>
                          <div className="text-white bg-ghBlack4 p-0 py-1 px-2 uppercase w-fit inline-block my-1 text-xs">
                            {props.app.installation_group_folder}
                          </div>
                          <Link
                            href={"/applications/" + getSlug()}
                            className=""
                          >
                            <h2 className="hover:underline hover:cursor-pointer text-base text-white flex items-center">
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
                          </Link>
                        </div>
                      </div>
                    </div>

                  </div>
                  <div className="flex col-span-6 w-full pl-2">
                    <ul className="float-left">
                      {props.app.categories &&
                        drawAppTags(props.app.categories)}
                    </ul>
                  </div>


                </div>
              </div>
              <div className="flex col-span-2 items-center justify-center border-l-2 border-ghBlack h-full">

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
          className={`relative flex flex-col col-span-full ${isChecked ? "hover:border-[#5a86ff]" : "hover:bg-ghBlack3 hover:border-ghBlack3"
            } hover:bg-ghBlack3 bg-ghBlack2 border ${isChecked ? "border-kxBlue" : "border-ghBlack2"
            } ${props.isListLayout ? "col-span-full" : "sm:col-span-6 xl:col-span-3"
            }`}
          onMouseOver={handleMouseOver}
          onMouseOut={handleMouseOut}
        >
          <div className="p-6">
            <div className="flex justify-between items-start mb-2">
              <div className="h-auto w-10">
                <AppLogo appName={props.app.name} />
              </div>
              <div className="h-10">
                <div
                  className={`${isHovering || isChecked ? "visible" : "hidden"
                    }`}
                >
                  <Checkbox
                    checked={isChecked}
                    onChange={(e) => handleCheckboxChange(e.target.checked)}
                  />
                </div>
              </div>
            </div>
            {/* <Link to={"/apps/" + getSlug()}> */}
            <div className="text-white bg-ghBlack2 p-0 px-1.5 uppercase w-fit inline-block my-2">
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
            <div className="pb-3 mb-3 w-full"></div>
            <div className="float-left h-32">
              <ul className="float-left">
                {props.app.categories && drawAppTags(props.app.categories)}
              </ul>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

export default ApplicationCard;
