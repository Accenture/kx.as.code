import React from "react";
import { Link } from "react-router-dom";
import { ImCross } from "react-icons/im";
import { useState, useEffect } from "react";

export default function ApplicationStatusActionButton(props) {
  const getActionButton = () => {
    if (props.getQueNameNew(props.appName) != undefined) {
      if (props.getQueNameNew(props.appName).includes("pending_queue")) {
        return (
          <button
            className="bg-none p-2 px-5 rounded items-center flex"
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
            <span className="text-gray-300">Processing...</span>
          </button>
        );
      } else if (
        props.getQueNameNew(props.appName).includes("completed_queue") &&
        !props.getQueNameNew(props.appName).includes("pending_queue")
      ) {
        return (
          <button
            className="bg-red-500 p-2 px-5 rounded items-center flex"
            to="#0"
          >
            <div className="flex items-start">
              <ImCross className="mr-2 flex my-auto" />
            </div>
            <span className="flex my-auto">Uninstall</span>
          </button>
        );
      }
    }
  };

  useEffect(() => {
    return () => {};
  }, []);

  return (
    <>
      <div className="flex justify-center">{getActionButton()}</div>
      <div>
        {props.getQueNameNew(props.appName).map((q) => {
          return <div>{q}</div>;
        })}
      </div>
    </>
  );
}
