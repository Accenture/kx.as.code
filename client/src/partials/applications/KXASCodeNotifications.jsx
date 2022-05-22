import React from "react";
import { useState, useEffect, useRef } from "react";
import { ToastContainer, toast } from "react-toastify";
import axios from "axios";

export default function KXASCodeNotifications() {
  const [queueData, setQueueData] = useState([]);

  const queueList = ["notification_queue"];

  useEffect(() => {
    fetchQueueData();
  }, []);

  const fetchQueueData = () => {
    const requests = queueList.map((queue) => {
      axios
        .get("http://localhost:5001/api/queues/" + queue)
        .then((response) => {
          // console.log("debug-response: ", response);
          response.data.map((notificaiton) => {
            queueData.push(notificaiton);
          });
        })
        .then(() => {
          console.log("debug notificaitons data: ", queueData);
        });
    });

    Promise.all(requests)
      .then(() => {
        setQueueData(queueData);
      })
      .then(() => {
        // console.log("QueueData after fetch: ", queueData);
      });
  };

  const NotificationMessage = (notificationProps) => (
    // <div className="flex items-center">
    //   <AppLogo height={"40px"} width={"40px"} appName={props.app.name} />
    //   <div className="ml-2">{notificationProps.notificationMessage}</div>
    // </div>
    <div className="flex items-center">
      <div className="ml-2">{notificationProps.notificationMessage}</div>
    </div>
  );

  const notify = (action) => {
    // const notificationMessage = `${
    //   action === "install" ? "Installation" : "Uninstallation"
    // } Action added to Queue for ${appName}.`;
    const notificationMessage = "Notificaiton";

    toast.info(
      <NotificationMessage notificationMessage={notificationMessage} />,
      {
        position: "top-right",
        autoClose: 5000,
        hideProgressBar: false,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        theme: "dark",
      }
    );
  };

  return <></>;
}
