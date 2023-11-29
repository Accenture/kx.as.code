'use client';
import { useEffect, useState } from "react";
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import Tooltip from "@mui/material/Tooltip";
import HealthcheckDashboard from "./HealthcheckDashboard";

interface HealthcheckInfoProps {
  healthcheckStatus: string;
}

const HealthcheckInfoComponent: React.FC<HealthcheckInfoProps> = ({ healthcheckStatus }) => {
  return (
    <div className="h-10 m-2 w-5 bg-green-500">
    </div>
  );
};

interface QueueComponentProps {
  queueName: string;
  count: number;
  index: number;
  moveQueue: (fromIndex: number, toIndex: number) => void;
}

const QueueComponent: React.FC<QueueComponentProps> = ({ queueName, count, index, moveQueue }) => {
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
    hover: (draggedItem: any) => {
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
      className={`col-span-6 sm:col-span-6 md:col-span-3 xl:col-span-2 bg-ghBlack2 hover:bg-ghBlack3 h-auto p-3`}
      style={{
        border: isDragging ? "1px solid white" : "",
        opacity: isDragging ? 0.5 : 1,
      }}
    >
      <div className="text-sm uppercase text-white justify-center flex">{queueName}</div>
      <Tooltip title={`Open ${queueName} messages in new Tab.`} placement="top" arrow>
        <div>
          <a href={`http://localhost:5001/api/queues/${queueName}`} className="hover:underline hover:text-kxBlue" target="_blank">
            <div className="flex justify-center mt-3 text-2xl">
              {count}
            </div>
          </a>
          <div className="flex justify-center text-xs text-gray-500">Messages</div>
        </div>
      </Tooltip>
    </div>
  );
};

const Dashboard: React.FC = () => {
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
  const [healthCheckData, setHealthCheckData] = useState([]);
  const [applicationData, setApplicationData] = useState([]);
  const [isHealthCheckDataLoading, setIsHealthCheckDataLoading] = useState(true);


  const fetchApplicationData = () => {
    axios.get("http://localhost:5001/api/applications").then((response) => {
      setApplicationData(response.data);
    });
  };

  const fetchQueueData = async () => {
    try {
      const responses = await Promise.all(
        queueList.map((queue) =>
          axios.get(`http://localhost:5001/api/queues/${queue}`)
        )
      );

      const allQueueData: any = responses.flatMap((response) => response.data);
      setQueueData(allQueueData);
    } catch (error) {
      console.error("Error fetching queue data:", error);
    }
  };

  const moveQueue = (fromIndex: number, toIndex: number) => {
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
      setIsHealthCheckDataLoading(false);
    } catch (error) {
      console.error("Error fetching health check data:", error);
      setIsHealthCheckDataLoading(false);
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
    }, 10000); // 60000 milliseconds = 1 minute

    // Cleanup function to clear the interval when the component unmounts
    return () => clearInterval(intervalId);

  }, [healthCheckData]);

  return (
    <div className="py-8 w-full bg-ghBlack text-white">
      <div className="text-white pb-10 px-20">
        <div className="text-white text-xl font-bold">DASHBOARD</div>
        <div className="pt-4 pb-6 text-base text-gray-400">
          Monitor application metrics & etc.
        </div>
      </div>

      {isHealthCheckDataLoading ? (
        <div>Loading Health Check Data...</div>
      ) : (
        <HealthcheckDashboard healthCheckData={healthCheckData} />
      )}


      {/* Dashboard Section Queue Monitoring */}
      <div className={`mb-5 bg-ghBlack px-20 bg-ghBlack4 ${isOpenQueueDashboardSection ? "py-5" : "pt-5"} `}>

        {/* Dashboard section header */}
        <div className="flex justify-between items-center pb-5">
          {/* Dashboard section title */}
          <div className="text-base items-center text-gray-400">
            RabbitMQ Queues Monitoring
          </div>
          <div className=''>
            <div className=''>
              <Button
                variant="text"
                size="small"
                className="h-full text-white bg-ghBlack3 hover:bg-ghBlack3"
                onClick={() => {
                  setIsOpenQueueDashboardSection(!isOpenQueueDashboardSection);
                }}
              >
                {isOpenQueueDashboardSection ? (
                  <ExpandLessIcon fontSize="small" className="text-white" />
                ) : (
                  <ExpandMoreIcon fontSize="small" className="text-white" />
                )}
              </Button>
            </div>
          </div>
        </div>

        <DndProvider backend={HTML5Backend}>
          <div className={`grid grid-cols-12 gap-2 hover:border-gray-400 ${isOpenQueueDashboardSection ? "visible" : "hidden"} hover:cursor-pointer`}>
            {queueList.map((queueName, index) => (
              <QueueComponent
                key={index}
                queueName={queueName}
                count={queueData.filter((app: any) => app.routing_key === queueName).length}
                index={index}
                moveQueue={moveQueue}
              />
            ))}
          </div>
        </DndProvider>

      </div>
    </div>
  );
};

export default Dashboard;
