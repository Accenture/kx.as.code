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
import HealthcheckDashboard from "../partials/dashboard/HealthcheckDashboard"


const HealthcheckInfoComponent = ({ healthcheckStatus }) => {
  return (
    <div className="rounded h-10 m-2 w-5 bg-green-500">
    </div>
  )
}

const QueueComponent = ({ queueName, count, index, moveQueue }) => {
  const [isDragging, setIsDragging] = useState(false);

  const [, drag, preview] = useDrag({
    type: "QUEUE_COMPONENT",
    item: { queueName, index },
    collect: (monitor) => {
      setIsDragging(!!monitor.isDragging());
      return {};
    },
  });

  const [, drop] = useDrop({
    accept: "QUEUE_COMPONENT",
    hover: (draggedItem) => {
      if (draggedItem.index !== index) {
        moveQueue(draggedItem.index, index);
        draggedItem.index = index;
      }
    },
  });

  return (
    <div
      ref={(node) => {
        drag(drop(node));
        preview(node);
      }}
      className={`col-span-3 bg-gray-700 hover:bg-[#3d4d63] rounded-md h-40 p-3`}
      style={{
        border: isDragging ? "1px solid white" : "",
        opacity: isDragging ? 0.5 : 1,
      }}
    >
      <div className="text-base uppercase">{queueName}</div>
      <Tooltip title={`Open ${queueName} messages in new Tab.`} placement="top" arrow>
        <a href={`http://localhost:5001/mock/api/queues/${queueName}`} className="hover:underline hover:text-kxBlue" target="_blank">
          <div className="flex justify-center mt-5 text-2xl">
            {count}
          </div>
          <div className="flex justify-center text-sm">Messages</div>
        </a>
      </Tooltip>
    </div>
  );
};

const Dashboard = () => {
  const [queueList, setQueueList] = useState([
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
    "notification_queue",
  ]);

  const [queueData, setQueueData] = useState([]);
  const [isOpenQueueDashboardSection, setIsOpenQueueDashboardSection] = useState(true);
  const [isOpenAppsHealthcheckDashboardSection, setIsOpenAppsHealthcheckDashboardSection] = useState(true);
  const [applicationData, setApplicationData] = useState([]);
  const [healthCheckData, setHealthCheckData] = useState([]);



  const fetchApplicationData = () => {
    axios.get("http://localhost:5001/api/applications").then((response) => {
      setApplicationData(response.data);
    });
  };

  const fetchQueueData = async () => {
    try {
      const responses = await Promise.all(
        queueList.map((queue) =>
          axios.get(`http://localhost:5001/mock/api/queues/${queue}`)
        )
      );

      const allQueueData = responses.flatMap((response) => response.data);
      setQueueData(allQueueData);
    } catch (error) {
      console.error("Error fetching queue data:", error);
    }
  };

  const moveQueue = (fromIndex, toIndex) => {
    setQueueList((prevList) => {
      const updatedQueueList = [...prevList];
      const [movedQueue] = updatedQueueList.splice(fromIndex, 1);
      updatedQueueList.splice(toIndex, 0, movedQueue);
      return updatedQueueList;
    });
  };

  const fetchhealthcheckData = async () => {
    try {
      const response = await fetch("http://localhost:5001/healthcheckdata");
      const data = await response.json();
      setHealthCheckData(data);
    } catch (error) {
      console.error("Error fetching health check data:", error);
    }
  };

  useEffect(() => {
    fetchQueueData();
    fetchApplicationData();

    // Initial fetch
    fetchhealthcheckData();

    // Fetch data every minute
    const intervalId = setInterval(() => {
      fetchhealthcheckData();
    }, 60000); // 60000 milliseconds = 1 minute

    // Cleanup function to clear the interval when the component unmounts
    return () => clearInterval(intervalId);
    
  }, []);

  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      <div className="text-white text-xl font-bold py-5 italic">MY DASHBOARD</div>

      {/* Dashboard Section Queue Monitoring */}
      <div className={`mb-5 bg-inv px-5 rounded-md border border-gray-600 ${isOpenQueueDashboardSection > 0 ? "py-5" : "pt-5"} `}>

        {/* Dashboard section header */}
        <div className="flex justify-between items-center pb-5">
          {/* Dashboard section title */}
          <div className="text-base items-center">
            RabbitMQ Queues Monitoring
          </div>
          <div className=''>
            <Button
              variant="outlined"
              size="small"
              className="h-full text-black"
              onClick={(e) => {
                setIsOpenQueueDashboardSection(!isOpenQueueDashboardSection);
              }}
            >
              {isOpenQueueDashboardSection ? (
                <ExpandLessIcon fontSize="small" />
              ) : (
                <ExpandMoreIcon fontSize="small" />
              )}
            </Button>
          </div>
        </div>

        <DndProvider backend={HTML5Backend}>
          <div className={`grid grid-cols-12 gap-2 hover:border-gray-400 ${isOpenQueueDashboardSection > 0 ? "visible" : "hidden"} hover:cursor-pointer`}>
            {queueList.map((queueName, index) => (
              <QueueComponent
                key={index}
                queueName={queueName}
                count={queueData.filter((app) => app.routing_key === queueName).length}
                index={index}
                moveQueue={moveQueue}
              />
            ))}
          </div>
        </DndProvider>

      </div>

      <HealthcheckDashboard healthCheckData={healthCheckData} />

    </div>
  );
};

export default Dashboard;
