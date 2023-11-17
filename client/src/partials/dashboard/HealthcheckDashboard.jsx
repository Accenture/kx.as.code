import React, { useState, useEffect, useRef } from 'react';
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import Tooltip from "@mui/material/Tooltip";
import AppLogo from "../applications/AppLogo";


const HealthcheckInfoBox = ({ healthcheckStatus }) => {
  var bgColorClass = "";
  if (healthcheckStatus === 200) {
    bgColorClass = 'bg-green-500';
  } else if (healthcheckStatus === 0) {
    bgColorClass = 'bg-gray-500';
  } else {
    bgColorClass = 'bg-red-500';
  } return (
    <div className={`rounded h-8 m-1 w-2 ${bgColorClass}`}>
    </div>
  );
};

const HealthCheckInfoComponent = ({ appName }) => {
  const [appHealthcheckDataArray, setAppHealthcheckDataArray] = useState([]);
  const [status, setStatus] = useState(0);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await fetch(`http://localhost:8000/mock/api/jenkins/healthcheck`);

        const healthcheckDataObj = {
          timestamp: new Date(),
          status: response.status,
        };

        setStatus(response.status);

        setAppHealthcheckDataArray(prevArray => [...prevArray, healthcheckDataObj]);
      } catch (error) {
        console.error('Error fetching data:', error);
      }
    };

    fetchData();

    const intervalId = setInterval(fetchData, 1000); 

    return () => clearInterval(intervalId);
  }, [appName]);

  useEffect(() => {
    const backgroundProcess = async () => {

    };

    backgroundProcess();
  }, [appHealthcheckDataArray]);

  return (
    <div className="flex justify-start">
      {appHealthcheckDataArray.map((healthcheckData, index) => (
        <HealthcheckInfoBox key={index} healthcheckStatus={healthcheckData.status} />
      ))}
    </div>
  );
};




const checkIsAppNameInCompletedQueue = (queueData, appName) => {
  for (const item of queueData) {
    try {
      const { routing_key, payload } = item;

      if (routing_key === 'notification_queue') {
        continue;
      }

      if (typeof payload !== 'string' || payload.trim() === '') {
        console.error('Invalid payload:', payload);
        continue;
      }

      const { name } = JSON.parse(payload);

      if (typeof name !== 'string' || name.trim() === '') {
        console.error('Invalid name:', name);
        continue;
      }

      if (routing_key === 'completed_queue' && name === appName) {
        return true;
      }
    } catch (error) {
      console.error('Error parsing payload JSON:', error);
      console.error('Problematic payload:', item.payload);
    }
  }
  return false;
};





const HealthcheckDashboard = (props) => {
  const [isOpenAppsHealthcheckDashboardSection, setIsOpenAppsHealthcheckDashboardSection] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");

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
        {/* Search Input Field */}
        <div className="group relative mb-5">
          <svg
            width="20"
            height="20"
            fill="currentColor"
            className="absolute left-3 top-1/2 -mt-2.5 text-gray-500 pointer-events-none group-focus-within:text-kxBlue"
            aria-hidden="true"
          >
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
            />
          </svg>
          <input
            type="text"
            placeholder="Search..."
            className="focus:ring-2 focus:ring-kxBlue focus:outline-none bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring min-w-80 pl-10"
            onChange={(e) => {
              setSearchTerm(e.target.value);
            }}
          />
        </div>
        {props.applicationData.filter((item) => {
          const lowerCaseName = (item.name || '').toLowerCase();
          if (searchTerm === "") {
            return true;
          } else {
            return lowerCaseName.includes(searchTerm.toLowerCase().trim());
          }
        }).map((item, key) => {
          const isInCompletedQueue = checkIsAppNameInCompletedQueue(props.queueData, item.name);
          return (
            <div key={key}>
              {isInCompletedQueue ? (
                <div className="px-5 p-2 bg-gray-700 hover:bg-[#3d4d63] mb-2 flex items-center rounded h-14">

                  <span className="w-1/5 flex items-center">
                    <span className="p-3 w-14 h-auto">
                      <AppLogo
                        appName={item.name}
                      />
                    </span>
                    <span>
                      {item.name}
                    </span>
                  </span>
                  <span className="w-4/5">
                    <HealthCheckInfoComponent appName={item.name} />
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
