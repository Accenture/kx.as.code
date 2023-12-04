import React, { useState, useEffect } from "react";
import { ToastContainer, toast } from "react-toastify";
import axios from "axios";

export default function KXASCodeNotifications() {

  const fetchPendingQueueMessage = async () => {
    try {
      const response = await axios.get(
        "http://localhost:5001/api/consume/notification_queue"
      );

      if (response.data.type === "success") {
        const payload = JSON.parse(response.data.content.payload);
        const message = payload.message;
        notify(message, "info");
      } else {
        console.error("Error consuming queue:", response.data.message);
      }
    } catch (error) {
      console.error("Error fetching pending queue data:", error);
    }
  };

  const NotificationMessage = ({ notificationMessage }) => (
    <div className="flex items-center">
      <div className="ml-2">{notificationMessage}</div>
    </div>
  );

  const notify = async (message, logLevel) => {
    const notificationMessage = message;

    const toastProps = {
      position: "top-right",
      autoClose: 6000,
      hideProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
      theme: "dark",
      style: {
        backgroundColor: "#161b22",
        borderRadius: 0,
      },
    };

    try {
      toast[logLevel](
        <NotificationMessage
          notificationMessage={notificationMessage}
        />,
        toastProps
      );
    } catch (error) {
      console.error("Error displaying notification:", error);
    }
  };

  useEffect(() => {
    const interval = setInterval(() => {
      fetchPendingQueueMessage();
    }, 5000);


    return () => clearInterval(interval);
  }, []);

  return <></>;
}
