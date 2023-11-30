import React, { useState, useEffect } from "react";
import { VscTerminalPowershell } from "react-icons/vsc";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Tooltip from "@mui/material/Tooltip";
import axios from "axios";

export default function ApplicationTaskComponent(props) {
  const [inputValues, setInputValues] = useState({});

  const taskExecutionHandler = async () => {
    const appData = props.appData;

    // Check if inputValues is empty
    const areInputValuesEmpty = Object.keys(inputValues).length === 0;

    if (areInputValuesEmpty) {
      const placeholderValues = {};
      props.task.inputs.forEach((input) => {
        placeholderValues[input.argumentKey] =
          inputValues[input.argumentKey] || input.argumentDefaultValue;
      });

      setInputValues(placeholderValues);
    }

    const appName = appData.name;
    const taskExecutionPayloadObj = {
      install_folder: appData.installation_group_folder,
      name: appName,
      task: props.task.name,
      action: "executeTask",
      retries: "0",
      input_parameters: inputValues,
    };

    console.info("DEBUG taskExecutionPayloadObj: ", taskExecutionPayloadObj);

    axios
      .post(
        "http://localhost:5001/api/add/application/pending_queue",
        taskExecutionPayloadObj
      )
      .catch((error) => {
        console.error("There was an error!", error);
      });
  };

  useEffect(() => {}, []);

  return (
    <div className="bg-ghBlack4 p-3 mt-3">
      <div className="items-center flex justify-between text-base">
        <span className="flex mr-2 font-bold">
          {props.task.name}
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
              taskExecutionHandler();
            }}
            className="bg-kxBlue p-1 px-4 items-center flex hover:bg-kxBlue2"
          >
            <span>
              <VscTerminalPowershell className="mr-2" />
            </span>{" "}
            Execute
          </button>
        </span>
      </div>

      {!props.task.inputs.length == 0 ? (
        <div>
          <div className="text-sm text-gray-400 mt-3">Execute with Parameter</div>
          {props.task.inputs.map((input, i) => {
            return (
              <div key={i} className="">
                <div className="mt-1 text-sm font-bold">{input.argumentKey}</div>
                <input
                  type={input.fieldType}
                  placeholder={input.argumentDefaultValue}
                  className="focus:ring-1 focus:ring-kxBlue bg-ghBlack px-2 py-2 placeholder-blueGray-300 text-blueGray-600 text-base border-0 shadow outline-none focus:outline-none"
                  onChange={(e) => {
                    setInputValues((prevValues) => ({
                      ...prevValues,
                      [input.argumentKey]: e.target.value,
                    }));
                  }}
                />
              </div>
            );
          })}
        </div>
      ) : null}
    </div>
  );
}
