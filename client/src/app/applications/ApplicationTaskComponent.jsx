import React, { useState, useEffect } from "react";
import { VscTerminalPowershell } from "react-icons/vsc";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Tooltip from "@mui/material/Tooltip";

export default function ApplicationTaskComponent(props) {
  useEffect(() => { }, []);
  return (
    <div className="bg-ghBlack4 p-2 mt-3">
      <div
        key={props.key}
        className="items-center flex justify-between text-base"
      >
        <span className="flex mr-2 font-bold">
          {props.task.title}
          <Tooltip title={props.task.description} placement="top" arrow>
            <button className="inline">
              <HiOutlineInformationCircle className="ml-1" />
            </button>
          </Tooltip>
        </span>
        <span>
          <button
            to="#0"
            onClick={() => {
              props.taskExecutionHandler(props.task.name);
            }}
            className="bg-kxBlue p-1 px-4 items-center flex hover:pr-5"
          >
            <span>
              <VscTerminalPowershell className="mr-2" />
            </span>{" "}
            Execute
          </button>
        </span>

      </div>

      {!props.task.inputs.length == 0 ? (<div>
        <div className="text-sm text-gray-400">Execute with Paramter</div>
        {props.task.inputs.map((input, i) => {
          return (<div className="">
            <div className="mt-1 text-sm font-bold">{input.argumentKey}</div>
            <input
              type={input.fieldType}
              placeholder={input.argumentDefaultValue}
              className="focus:ring-1 focus:ring-kxBlue bg-ghBlack px-2 py-2 placeholder-blueGray-300 text-blueGray-600 text-base border-0 shadow outline-none focus:outline-none"
              onChange={(e) => {
              }}
            /></div>)
        })}
      </div>) : (null)}
    </div>
  );
}
