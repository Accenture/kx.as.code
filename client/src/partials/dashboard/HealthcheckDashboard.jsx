import React, { useState, useEffect } from "react";
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import Tooltip from "@mui/material/Tooltip";


const HealthcheckInfoComponent = ({ healthcheckStatus }) => {
  return (
    <div className="rounded h-10 m-2 w-5 bg-green-500">
    </div>
  )
}

const requestHealthcheck = (appName) => {
  // const isAppNameInQueue = queueData.some(item => item.routing_key === 'completed_queue' && item.name === appName);
  fetch('http://localhost:5001/mock/api/jenkins/healthcheck')
    .then(response => {
      if (response.status === 200) {
        console.log(`Healthcheck passed for ${appName}`);
        <HealthcheckInfoComponent healthcheckStatus={200} />
      } else {
        console.log(`Healthcheck failed for ${appName}`);
        <div>Error</div>
      }
    })
    .catch(error => {
      console.error('Error during healthcheck request:', error);
    });

};

const checkIsAppNameInCompletedQueue = (queueData, appName) => {
  return queueData.some(item => {
    try {
      const payloadObject = JSON.parse(item.payload);
      return item.routing_key === 'completed_queue' && payloadObject.name === appName;
    } catch (error) {
      console.error('Error parsing payload JSON:', error);
      return false;
    }
  });
};


const HealthcheckDashboard = (props) => {
  const [isOpenAppsHealthcheckDashboardSection, setIsOpenAppsHealthcheckDashboardSection] = useState(true);

  useEffect(() => {

  }, []);

  return (
    <div className={`mb-5 bg-inv px-5 rounded-md border border-gray-600 ${isOpenAppsHealthcheckDashboardSection > 0 ? "py-5" : "pt-5"} `}>
      {/* Dashboard section header */}
      <div className="flex justify-between items-center pb-5">
        {/* Dashboard section title */}
        <div className="text-base items-center">
          Application Healthcheck Monitoring
        </div>
        <div className=''>
          <Button
            variant="outlined"
            size="small"
            className="h-full text-black"
            onClick={(e) => {
              setIsOpenAppsHealthcheckDashboardSection(!isOpenAppsHealthcheckDashboardSection);
            }}
          >
            {isOpenAppsHealthcheckDashboardSection ? (
              <ExpandLessIcon fontSize="small" />
            ) : (
              <ExpandMoreIcon fontSize="small" />
            )}
          </Button>
        </div>
      </div>

      <div className={`w-full ${isOpenAppsHealthcheckDashboardSection > 0 ? "visible" : "hidden"}`}>
        {props.applicationData.map((item, key) => {
          const isInCompletedQueue = checkIsAppNameInCompletedQueue(props.queueData, item.name);
          return (
            <div key={key}>
              {isInCompletedQueue ? (
                <div className="px-5 p-2 bg-gray-700 mb-2 flex items-center rounded h-14">
                  <span className="w-1/5">{item.name}</span>
                  <span className="w-4/5">
                    {requestHealthcheck(item.name)}
                  </span>
                </div>
              ) : null}
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default HealthcheckDashboard;
