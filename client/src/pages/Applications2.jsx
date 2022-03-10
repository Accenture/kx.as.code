import { React, Component } from "react";
import ApplicationCard2 from "../partials/applications/ApplicationCard2.jsx";
import axios from "axios";
// import FilterButton from "../partials/actions/FilterButton"

import { useState, useEffect } from "react";

export const Applications2 = () => {
  const [applicationData, setApplicationData] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [queueData, setQueueData] = useState([]);

  const queueList = [
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
  ];

  const fetchData = () => {
    axios
      .get("http://localhost:5001/api/applications")
      .then((response) => {
        setApplicationData(response.data);
      })
      .then(() => {});
  };

  const drawApplicationCards = () => {
    return applicationData
      .filter((val) => {
        if (searchTerm == "") {
          return val;
        } else if (
          val.name.toLowerCase().includes(searchTerm.toLowerCase().trim())
        ) {
          return val;
        }
      })
      .map((app, i) => {
        return <ApplicationCard2 app={app} key={i} queueData={queueData} />;
      });
  };

  const fetchQueueData2 = () => {
    queueList.map((queue) => {
      axios
        .get("http://localhost:5001/api/queues/" + queue)
        .then((response) => {
          response.data.map((app) => {
            queueData.push(app);
          });
        })
        .then(() => {
          setQueueData(queueData);
        });
    });
  };

  useEffect(() => {
    fetchQueueData2();
    fetchData();
    return () => {};
  }, []);

  return (
    <div className="px-6 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Applications Header */}
      <div className="text-white pb-10">
        <div className="text-xl font-bold italic text-gray-500">
          APPLICATIONS
        </div>
        <div className="pt-4 pb-6">
          Which Applications you want to install into your KX.AS Code
          environemnt?
        </div>
        <div className="border-b-2 border-gray-700"></div>
      </div>

      {/* Applications actions */}
      <div className="sm:flex sm:items-center mb-8">
        {/* Left: Actions */}
        <div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2">
          {/* Search Input Field */}
          <div className="group relative mb-3">
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
              placeholder="Search Applications..."
              className="focus:ring-2 focus:ring-kxBlue focus:outline-none bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring min-w-80 pl-10"
              onChange={(e) => {
                setSearchTerm(e.target.value);
              }}
            />
          </div>
          {/* <FilterButton filterHandler={this.filterHandler}
                            isCompleted={this.state.isCompleted}
                            isFailed={this.state.isFailed}
                            isPending={this.state.isPending} /> */}
        </div>
      </div>
      <div className="grid grid-cols-12 gap-8">{drawApplicationCards()}</div>
    </div>
  );
};