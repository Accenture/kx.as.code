import React from "react";
import Tooltip from "@mui/material/Tooltip";

interface StatusPointProps {
  installStatus: string;
}

const StatusPoint: React.FC<StatusPointProps> = (props) => {
  const getTagBgColor = (installStatus: string): string => {
    if (installStatus === "completed_queue") {
      return "bg-statusNewGreen";
    } else if (installStatus === "pending_queue") {
      return "bg-statusNewOrange";
    } else if (installStatus === "failed_queue") {
      return "bg-statusNewRed";
    } else if (installStatus === "wip_queue") {
      return "bg-statusNewYellow";
    } else if (installStatus === "retry_queue") {
      return "bg-statusGray";
    } else {
      console.error("Unknown Installation Status (Install Status Tag)");
      return "";
    }
  };

  const getTagContent = (installStatus: string): string => {
    if (installStatus === "completed_queue") {
      return "Installed";
    } else if (installStatus === "pending_queue") {
      return "Installing";
    } else if (installStatus === "failed_queue") {
      return "Installation failed";
    } else if (installStatus === "wip_queue") {
      return "VIP";
    } else if (installStatus === "retry_queue") {
      return "tbd";
    } else {
      console.error("Unknown Installation Status (Install Status Tag)");
      return "";
    }
  };

  return (
    <Tooltip title={`${getTagContent(props.installStatus)}`} placement="top">
      <button
        className={`h-5 w-5 rounded-full mr-2 border-4 ${getTagBgColor(
          props.installStatus
        )}`}
      ></button>
    </Tooltip>
  );
};

export default StatusPoint;
