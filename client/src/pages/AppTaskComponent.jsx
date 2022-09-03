import React, { useState, useEffect } from "react";
import { VscTerminalPowershell } from "react-icons/vsc";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Tooltip from "@mui/material/Tooltip";

export default function AppTaskComponent(props) {
  useEffect(() => {}, []);
  return (
    <div
      key={props.key}
      className="bg-ghBlack2 p-2 hover:bg-gray-700 rounded-md flex items-center justify-between mb-2 pl-4"
    >
      <span className="flex mr-2">
        {props.task.title}
        <Tooltip title={props.task.description} placement="top" arrow>
          <button className="inline">
            <HiOutlineInformationCircle className="ml-1 text-lg" />
          </button>
        </Tooltip>
      </span>
      <span>
        <button
          to="#0"
          onClick={() => {
            props.taskExecutionHandler(props.task.title);
          }}
          className="bg-kxBlue p-1 px-4 rounded items-center flex hover:pr-5"
        >
          <span>
            <VscTerminalPowershell className="text-2xl mr-2" />
          </span>{" "}
          Execute
        </button>
      </span>
    </div>
  );
}
