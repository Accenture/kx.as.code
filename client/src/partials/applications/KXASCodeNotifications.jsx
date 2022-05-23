import React from "react";
import { useState, useEffect, useRef } from "react";
import { ToastContainer, toast } from "react-toastify";
import axios from "axios";

export default function KXASCodeNotifications() {
  const [queueData, setQueueData] = useState([]);
  // const [notificationData, setNotificationData] = useState([]);

  const queueList = ["notification_queue"];

  useEffect(() => {
    const interval = setInterval(() => {
      fetchQueueDataAndNotify();
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  // const getNotificationMessageList = () => {
  //   console.log("fetchedData-debug-33: ", queueData);
  //   queueData
  //     .map((obj) => {
  //       let message = JSON.parse(obj.payload).message;
  //       notificationData.push(message);
  //     })
  //     .then(() => {
  //       setNotificationData(notificationData);
  //     });
  // };

  const fetchQueueDataAndNotify = () => {
    const requests = queueList.map((queue) => {
      return axios
        .get("http://localhost:5001/api/queues/" + queue)
        .then((response) => {
          console.log(
            "payload debug: ",
            JSON.parse(response.data[0].payload).message
          );
          // console.log(
          //   "payload type: ",
          //   typeof JSON.parse(response.data[0].payload).message
          // );
          notify(JSON.parse(response.data[0].payload).message);
        })
        .then(() => {
          axios.get("http://localhost:5001/api/consume/notification_queue");
        });
    });

    Promise.all(requests)
      .then(() => {
        // setQueueData(queueData);
        // console.log("queue data messages: ", queueData);
        // notify(JSON.parse(queueData[0].payload).message);
      })
      .then(() => {});
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

  const notify = (message) => {
    // const notificationMessage = `${
    //   action === "install" ? "Installation" : "Uninstallation"
    // } Action added to Queue for ${appName}.`;
    const notificationMessage = message;

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
