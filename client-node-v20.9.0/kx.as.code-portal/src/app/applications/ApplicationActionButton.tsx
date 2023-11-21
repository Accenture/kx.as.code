import React, { useEffect } from "react";
import { ImCross } from "react-icons/im";
import { FaArrowAltCircleDown } from "react-icons/fa";
import RestartAltIcon from "@mui/icons-material/RestartAlt";
import Tooltip from "@mui/material/Tooltip";
import { AiOutlineWarning } from "react-icons/ai";
import { Link } from "react-router-dom";

interface ApplicationStatusActionButtonProps {
  isMqConnected: boolean;
  getQueueStatusList: (appName: string) => string[];
  appName: string;
  category: string;
  applicationInstallHandler: () => void;
  applicationUninstallHandler: () => void;
}

const ApplicationStatusActionButton: React.FC<ApplicationStatusActionButtonProps> = (
  props
) => {
  useEffect(() => {
    console.log("list-actionbutton: ", props.getQueueStatusList(props.appName));
    return () => {};
  }, []);

  const getActionButton = () => {
    if (!props.isMqConnected) {
      if (true) { // TODO: props.getQueueStatusList(props.appName) === "pending_queue" ???
        return (
          <div className="flex">
            <button
              className="bg-gray-600 p-2 px-5 rounded-bl rounded-tl items-center flex"
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
              <span className="text-white">Processing...</span>
            </button>
            <Tooltip
              title={`Re-install ${props.appName}`}
              placement="top"
              arrow
            >
              <button className="bg-kxBlue p-2 rounded-br rounded-tr ml-1 text-white">
                <RestartAltIcon
                  aria-label="list"
                  color="inherit"
                  onClick={() => {
                    props.applicationInstallHandler();
                  }}
                />
              </button>
            </Tooltip>
          </div>
        );
      } 
    } else {
      return (
        // <Link
        //   className="border-red-500 border p-2 px-5 rounded items-center flex text-red-500"
        //   to="#0"
        //   onClick={() => {
        //     props.applicationInstallHandler();
        //   }}
        // >
        //   <span className="flex my-auto text-base">
        //     <AiOutlineWarning className="mt-auto mb-auto table text-lg mr-2" />
        //     ActionButton Error
        //   </span>
        // </Link>
        <></>
      );
    }
  };

  useEffect(() => {
    return () => {
      // props.refreshActionButton.current = getActionButton;
    };
  }, []);

  return <div className="">{getActionButton()}</div>;
};

export default ApplicationStatusActionButton;
