import React from "react";
import { useState, useEffect, useRef } from "react";
import { ToastContainer, toast } from "react-toastify";
import axios from "axios";

export default function KXASCodeNotifications() {
  const [queueData, setQueueData] = useState([]);
  // const [notificationData, setNotificationData] = useState([]);

  const queueList = ["notification_queue"];

  const deleteLastNotificationMessage = () => {
    axios.get("http://localhost:5001/api/consume/notification_queue")
      .then((response) => {
        console.log("Pending Queue Data: ", response.data);
      })
      .catch((error) => {
        console.error("Error fetching pending queue data: ", error);
      });
  };


  useEffect(() => {

    // disable setIntervall function for Notifications:
    // const interval = setInterval(() => {
    //   fetchQueueDataAndNotify();
    // }, 5000);
    // return () => clearInterval(interval);
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
          setQueueData(queueData);
          // console.log(
          //   "payload debug: ",
          //   JSON.parse(response.data[0].payload).message
          // );
          // console.log(
          //   "payload type: ",
          //   typeof JSON.parse(response.data[0].payload).message
          // );

          try {
            if (response.data.length >= 1) {
              let message = JSON.parse(response.data[0].payload).message;
              let logLevel = JSON.parse(response.data[0].payload).log_level;

              notify(message, logLevel);  
            }
          } catch (err) {
            // axios.get("http://localhost:5001/api/queues/notification_queue");
            console.log("Error: ", err);
          }
        })
        .then(() => {

        });
    });

    Promise.all(requests)
      .then(() => {
        // console.log("queue data messages: ", queueData);
        if (queueData.length >= 1) {
          notify(JSON.parse(queueData[0].payload).message);
        }
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

  const notify = (message, logLevel) => {
    // const notificationMessage = `${
    //   action === "install" ? "Installation" : "Uninstallation"
    // } Action added to Queue for ${appName}.`;
    const notificationMessage = message;

    if (logLevel === "info") {
      toast.info(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel} className="bg-green-500"
        />,
        { 
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
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "success") {
      toast.success(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
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
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "error") {
      toast.error(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
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
            borderRadius: 0
          }
        }
      );
    } else if (logLevel === "warn") {
      toast.warn(
        <NotificationMessage
          notificationMessage={notificationMessage}
          logLevel={logLevel}
        />,
        {
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
            borderRadius: 0
          }
        }
      );
    }
    deleteLastNotificationMessage()
  };

  return <></>;
}
