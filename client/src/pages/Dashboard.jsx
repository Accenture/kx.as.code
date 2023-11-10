import React, { useState, useEffect } from "react";
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";

const QueueComponent = ({ queueName, count, isSpecial, index, moveQueue }) => {
  const [{ isDragging }, drag] = useDrag({
    type: "QUEUE_COMPONENT",
    item: { queueName, index },
    collect: (monitor) => ({
      isDragging: !!monitor.isDragging(),
    }),
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
      ref={(node) => drag(drop(node))}
      className={`col-span-3 bg-ghBlack rounded-lg h-60 p-6 border-2 ${
        isSpecial ? "border-dashed border-gray-700" : "border-ghBlack hover:border-gray-700"
      } ${isDragging ? "opacity-50" : ""}`}
    >
      <div className="text-[16px] uppercase font-bold text-gray-600">{queueName}</div>
      <div className="flex justify-center mt-8 text-[50px]">{count}</div>
      <div className="flex justify-center text-[14px]">Application count</div>
    </div>
  );
};

export default function Dashboard() {
  const [queueList, setQueueList] = useState([
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
    "notification_queue",
  ]);

  const [queueData, setQueueData] = useState([]);

  const onDragEnd = (result) => {
    if (!result.destination) return;

    const updatedQueueList = Array.from(queueList);
    const [movedQueue] = updatedQueueList.splice(result.source.index, 1);
    updatedQueueList.splice(result.destination.index, 0, movedQueue);

    setQueueList(updatedQueueList);
  };

  const getApplicationCountByQueue = (queueName) =>
    queueData.filter((app) => app.routing_key === queueName).length;

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
    const updatedQueueList = Array.from(queueList);
    const [movedQueue] = updatedQueueList.splice(fromIndex, 1);
    updatedQueueList.splice(toIndex, 0, movedQueue);

    setQueueList(updatedQueueList);
  };

  useEffect(() => {
    fetchQueueData();
  }, []);

  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      <div className="text-white text-xl font-bold py-5 italic">MY DASHBOARD</div>

      <DndProvider backend={HTML5Backend}>
        <div className="grid grid-cols-12 gap-2">
          {queueList.map((queueName, index) => (
            <QueueComponent
              key={index}
              queueName={queueName}
              count={getApplicationCountByQueue(queueName)}
              isSpecial={index === 3}
              index={index}
              moveQueue={moveQueue}
            />
          ))}
          <div className="col-span-3 text-gray-700 bg-inv1 rounded-lg h-60 p-6 border-2 border-dashed border-gray-700 hover:border-gray-600">
            <div className="flex justify-center mt-16 text-[50px]">
              <AddIcon fontSize="inherit" color="inherit" className="hover:text-600" />
            </div>
          </div>
        </div>
      </DndProvider>
    </div>
  );
}