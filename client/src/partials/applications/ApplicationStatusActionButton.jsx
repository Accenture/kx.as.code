import React from "react";
import { Link } from "react-router-dom";
import { ImCross } from "react-icons/im";
import { FaArrowAltCircleDown } from "react-icons/fa";
import { AiOutlineWarning } from "react-icons/ai";

import { useState, useEffect } from "react";

export default function ApplicationStatusActionButton(props) {
  const getActionButton = () => {
    if (
      props.getQueNameNew(props.appName) != undefined &&
      props.isMqConnected
    ) {
      if (props.getQueNameNew(props.appName).includes("pending_queue")) {
        return (
          <button
            className="bg-gray-600 p-2 px-5 rounded items-center flex"
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
        );
      } else if (
        props.getQueNameNew(props.appName).includes("completed_queue") &&
        !props.getQueNameNew(props.appName).includes("pending_queue") &&
        props.category != "core"
      ) {
        return (
          <button
            className="bg-red-500 p-2 px-5 rounded items-center flex"
            to="#0"
          >
            <div className="flex items-start">
              <ImCross className="p-0.5 flex my-auto" />
            </div>
            <span className="flex my-auto">Uninstall</span>
          </button>
        );
      } else if (
        !props.getQueNameNew(props.appName).includes("completed_queue") &&
        !props.getQueNameNew(props.appName).includes("pending_queue") &&
        props.category != "core"
      ) {
        return (
          <button
            className="bg-kxBlue p-2 px-5 rounded items-center flex"
            to="#0"
            onClick={() => {
              props.applicationInstallHandler();
            }}
          >
            <div className="flex items-start">
              <FaArrowAltCircleDown className="mr-2 flex my-auto text-white" />
            </div>
            <span className="flex my-auto">Install</span>
          </button>
        );
      }
    } else {
      return (
        <div className="text-red-500 border-red-500 rounded-md border p-2 flex">
          <AiOutlineWarning className="mt-auto mb-auto table text-4xl mr-2" />
          Installation Status not available. Please check conneciton to RabbitMQ
          service.
        </div>
      );
    }
  };

  useEffect(() => {
    return () => {};
  }, []);

  return (
    <>
      <div className="flex justify-center">{getActionButton()}</div>

      {/* <div>
        {props.getQueNameNew(props.appName).map((q) => {
          return <div>{q}</div>;
        })}
      </div> */}
    </>
  );
}
