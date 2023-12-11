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
        // console.log("list-actionbutton: ", props.getQueueStatusList(props.appName));
        return () => { };
    }, []);

    const getActionButton = () => {
        if (props.isMqConnected) { // TODO: Disable in API Mock Mode
            if (props.getQueueStatusList(props.appName).includes("pending_queue") || props.getQueueStatusList(props.appName).includes("wip_queue") || props.getQueueStatusList(props.appName).includes("retry_queue")) {
                return (
                    <div className="flex w-full">
                        <button
                            className="bg-ghBlack4 p-3 items-center justify-center flex w-full py-1"
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
                            <span className="text-white text-sm">Processing...</span>
                        </button>
                        <Tooltip title={`Re-install ${props.appName}`} placement="top" arrow>
                            <button className="bg-kxBlue2 p-2 ml-1 py-1">
                                <RestartAltIcon
                                    className="text-white"
                                    aria-label="list"
                                    onClick={() => {
                                        props.applicationInstallHandler();
                                    }}
                                />
                            </button>
                        </Tooltip>
                    </div>
                );
            } else if (
                props.getQueueStatusList(props.appName).includes("completed_queue") &&
                props.category != "core"
            ) {
                return (
                    <div className="flex w-full">
                    <button
                        className="bg-statusRed p-2 px-3 justify-center items-center flex w-full py-1"
                        onClick={() => {
                            props.applicationUninstallHandler();
                        }}
                    >
                        <div className="flex items-start">
                            <ImCross className="p-0.5 flex my-auto" />
                        </div>
                        <span className="flex my-auto text-sm">Uninstall</span>
                    </button>
                    <Tooltip title={`Re-install ${props.appName}`} placement="top" arrow>
                    <button className="bg-kxBlue2 p-2 ml-1 py-1">
                        <RestartAltIcon
                            aria-label="list"
                            className="text-white"
                            onClick={() => {
                                props.applicationInstallHandler();
                            }}
                        />
                    </button>
                </Tooltip>
                </div>
                    
                );
            } else if (props.category != "core") {
                return (
                    <div className="flex w-full">
                        <button
                            className="bg-kxBlue p-2 px-5 items-center justify-center flex w-full py-1"
                            onClick={() => {
                                props.applicationInstallHandler();
                            }}
                        >
                            <div className="flex items-start">
                                <FaArrowAltCircleDown className="mr-2 flex my-auto text-white" />
                            </div>
                            <span className="flex my-auto text-sm">Install</span>
                        </button>
                    </div>
                );
            }
        } else {
            return (

                <button
                    className="border-red-500 border px-5 text-kxRed text-sm flex p-1 items-center"
                    onClick={() => {
                        props.applicationInstallHandler();
                    }}
                >
                    <AiOutlineWarning className="text-lg mr-2" />
                     Error
                </button>

            );
        }
    };

    useEffect(() => {
        return () => {
            // props.refreshActionButton.current = getActionButton;
        };
    }, []);

    return <div className="w-full justify-center flex mx-3">{getActionButton()}</div>;
};

export default ApplicationStatusActionButton;
