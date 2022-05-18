import React from "react";
import { Link } from "react-router-dom";
import { TrashCan32, Restart32 } from "@carbon/icons-react";
import { useState, useEffect } from "react";

export default function ApplicationStatusActionButton(props) {
  const getActionButton = () => {
    if (props.getQueNameNew(props.appName) != undefined) {
      props.getQueNameNew(props.appName).map((queue) => {
        if (queue === "completed_queue") {
          return (
            <button>
              <Link
                className="font-medium text-sm text-red-500 hover:text-red-600 flex py-1 px-3"
                to="#0"
              >
                <div className="flex items-start">
                  <TrashCan32 className="p-1 flex my-auto" />
                </div>
                <span className="flex my-auto">Uninstall</span>
              </Link>
            </button>
          );
        } else if (queue === "pending_queue") {
          return (
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
          );
        } else {
          return (
            <button
              //   onClick={applicationInstallHandler}
              className="bg-kxBlue p-3 px-5 rounded items-center flex"
            >
              Install
            </button>
          );
        }
      });
    }
  };

  useEffect(() => {
    return () => {};
  }, []);

  return <>{getActionButton()}</>;
}
