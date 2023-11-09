import React from "react";
import AddIcon from "@mui/icons-material/Add";
import { useState, useEffect } from "react";
import axios from "axios";
import { DndProvider } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";

export default function Dashboard() {
  const [applicationCountCompleted, setApplicationCountCompleted] = useState(0);
  const [applicationCountFailed, setApplicationCountFailed] = useState(0);
  const [applicationCountPending, setApplicationCountPending] = useState(0);

  const [queueData, setQueueData] = useState([]);

  const queueList = [
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
  ];

  const onDragEnd = (result) => {
    // TODO: reorder our column
  };

  const getApplicationCountByQueue = (queueName) => {
    var count = 0;
    queueData.map((app, i) => {
      if (app.routing_key == queueName) {
        count = count + 1;
      }
    });
    return count;
  };

  const fetchQueueData = () => {
    const requests = queueList.map((queue) => {
      return axios
        .get("http://localhost:5001/mock/api/queues/" + queue)
        .then((response) => {
          response.data.map((app) => {
            queueData.push(app);
          });
        })
        .then(() => {});
    });
  };
  useEffect(() => {
    fetchQueueData();

    return () => {};
  }, []);

  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Applications Header */}
      <div className="text-white text-xl font-bold py-5 italic">
        MY DASHBOARD
      </div>

      <DndProvider backend={HTML5Backend}>
        {/* Dashboard Components */}
        <div className="grid grid-cols-12 gap-2">
          <div className="col-span-3 bg-ghBlack rounded-lg h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
            <div className="text-[16px] uppercase font-bold text-gray-600">
              Installed Applications
            </div>
            <div className="flex justify-center mt-8 text-[50px]">
              {getApplicationCountByQueue("completed_queue")}
            </div>
            <div className="flex justify-center text-[14px]">
              Application count
            </div>
          </div>

          <div className="col-span-3 bg-ghBlack rounded-lg h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
            <div className="text-[16px]  uppercase font-bold text-gray-600">
              Failed Applications
            </div>
            <div className="flex justify-center mt-8 text-[50px]">
              {getApplicationCountByQueue("failed_queue")}
            </div>
            <div className="flex justify-center text-[14px]">
              Application count
            </div>
          </div>

          <div className="col-span-3 bg-ghBlack rounded-lg h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
            <div className="text-[16px] uppercase font-bold text-gray-600">
              Pending Applications
            </div>
            <div className="flex justify-center mt-8 text-[50px]">
              {getApplicationCountByQueue("pending_queue")}
            </div>
            <div className="flex justify-center text-[14px]">
              Application count
            </div>
          </div>

          <div className="col-span-3 text-gray-700 bg-inv1 rounded-lg h-60 p-6  border-2 border-dashed border-gray-700 hover:border-gray-600">
            <div className="flex justify-center mt-16 text-[50px]">
              <AddIcon
                fontSize="inherit"
                color="inherit"
                className="hover:text-600"
              />
            </div>
          </div>
        </div>
      </DndProvider>
    </div>
  );
}
