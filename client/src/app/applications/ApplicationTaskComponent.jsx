import React, { useState, useEffect } from "react";
import { VscTerminalPowershell } from "react-icons/vsc";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Tooltip from "@mui/material/Tooltip";
import axios from "axios";
import Button from '@mui/material/Button';
import { ToastContainer, toast } from "react-toastify";

export default function ApplicationTaskComponent(props) {
  const [inputValues, setInputValues] = useState({});

  const NotificationMessage = (notificationProps) => (
    // <div className="flex items-center">
    //   <AppLogo height={"40px"} width={"40px"} appName={props.app.name} />
    //   <div className="ml-2">{notificationProps.notificationMessage}</div>
    // </div>
    <div className="flex items-center">
      <div className="ml-2">{notificationProps.notificationMessage}</div>
    </div>
  );

  const notify = (message, logLevel) => {
    // const notificationMessage = `${
    //   action === "install" ? "Installation" : "Uninstallation"
    // } Action added to Queue for ${appName}.`;
    const notificationMessage = message;

    if (logLevel === "info") {
      toast.info(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel} className="bg-green-500"
        />,
        {
          position: "top-right",
          autoClose: 6000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          theme: "dark",
          style: {
            backgroundColor: "#2f3640",
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "success") {
      toast.success(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
          position: "top-right",
          autoClose: 6000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          theme: "dark",
          style: {
            backgroundColor: "#2f3640",
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "error") {
      toast.error(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
          position: "top-right",
          autoClose: 6000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          theme: "dark",
          style: {
            backgroundColor: "#2f3640",
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "warn") {
      toast.warn(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
          position: "top-right",
          autoClose: 6000,
          hideProgressBar: false,
          closeOnClick: true,
          pauseOnHover: true,
          draggable: true,
          progress: undefined,
          theme: "dark",
          style: {
            backgroundColor: "#2f3640",
            borderRadius: 0
          }
        }
      );
    }
  };


  const taskExecutionHandler = async (taskName) => {
    const appData = props.appData;

    if (!props.checkApplicationIsInPendingQueue(appData.name)) {
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
        notify(`${taskName} Task executed.`, "info");
    } else {
      notify(`${taskName} Task already in Execution Queue.`, "info")
    }
};

useEffect(() => { }, []);

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
        <Button
          sx={{
            backgroundColor: "#5a86ff",
            color: "white",
            '&:hover': {
              backgroundColor: "#5a86ff"
            }

          }}
          to="#0"
          onClick={() => {
            taskExecutionHandler(props.task.name);
          }}
        >
          <span>
            <VscTerminalPowershell className="mr-2" />
          </span>{" "}
          Execute
        </Button>
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
                type={input.fieldType} // correct html input types has to be used -> Modify in metadata.json
                maxlength={input.fieldLength ? input.fieldLength : null}
                min={input.minValue ? input.minValue : null}
                max={input.maxValue ? input.maxValue : null}
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
