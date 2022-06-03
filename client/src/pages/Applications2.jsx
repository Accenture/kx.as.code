import { React, Component } from "react";
import ApplicationCard2 from "../partials/applications/ApplicationCard2.jsx";
import axios from "axios";
import { FaThList } from "react-icons/fa";
import { BsGrid3X3GapFill } from "react-icons/bs";
import MultipleSelectCheckmarks from "../partials/MultipleSelectCheckmarks";
import { useState, useEffect } from "react";
import _ from "lodash";
import { ThemeProvider, createTheme } from "@mui/material/styles";
import { PaginatedItems } from "../partials/PaginatedItems";
import PaginationRounded from "../partials/PaginationRounded.jsx";

export const Applications2 = () => {
  const [applicationData, setApplicationData] = useState([]);
  const [newAppList, setNewAppList] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [queueData, setQueueData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [appsSearchResultCount, setAppsSearchResultCount] = useState(0);
  const [isMqConnected, setIsMqConnected] = useState(true);
  const [isListLayout, setIsListLayout] = useState(true);
  const [sortSelect, setSortSelect] = useState("asc");
  const [filterStatusList, setFilterStatusList] = useState([
    "failed_queue",
    "completed_queue",
    "pending_queue",
  ]);

  const darkTheme = createTheme({
    palette: {
      mode: "dark",
    },
  });

  const [filterObj, setFilterObj] = useState({
    // isInstalled: false,
    // isFailed: false,
    // isInstalling: false,
    // isUninstalling: false,
    // isPending: false,
  });

  const [filterInstallationStatusList, setFilterInstallationStatusList] =
    useState([
      "isInstalled",
      "isFailed",
      "isInstalling",
      "isUninstalling",
      "isPending",
    ]);

  // const filterStatusList = ["failed_queue", "completed_queue"];

  const queueList = [
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
  ];

  const getQueueStatusByAppName = async (appName) => {
    return await queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === appName) {
        // setAppQueue(obj.routing_key);
        console.log("get status debug: ", obj.routing_key);
        return obj.routing_key;
      } else {
      }
    });
  };

  const toggleListLayout = (b) => {
    setIsListLayout(b);
    localStorage.setItem("isListLayout", b);
    console.log("isListLayout: ", b);
    console.log("isListLayout-local: ", localStorage.getItem("isListLayout"));
  };

  const getQueueStatusList = (appName) => {
    // fetchQueueData();
    let queueList = [];
    queueData.map((obj) => {
      if (JSON.parse(obj.payload).name === appName) {
        // console.log("in GetQueue queue Name: ", obj.routing_key);
        queueList.push(obj.routing_key);
        // console.log("list: ", queueList);
      } else {
      }
    });
    // console.log("Debug getQueSTatusList: ", queueList);
    return queueList;
  };

  const fetchData = () => {
    setIsLoading(true);
    axios.get("http://localhost:5001/api/applications").then((response) => {
      setApplicationData(response.data);
    });
  };
  const getInstallationFilterStatusObject = (appName) => {
    let obj = {
      isInstalled: false,
      isFailed: false,
      isInstalling: false,
      isUninstalling: false,
      isPending: false,
    };

    if (filterInstallationStatusList.includes("isCompleted")) {
      obj.isCompleted = true;
    } else if (filterInstallationStatusList.includes("isPending")) {
      obj.isPending = true;
    } else if (filterInstallationStatusList.includes("isFailed")) {
      obj.isFailed = true;
    }

    return obj;
  };

  const getInstallationStatusObject = (appName) => {
    let obj = {
      isInstalled: false,
      isFailed: false,
      isInstalling: false,
      isUninstalling: false,
      isPending: false,
    };

    let queueStatusList = getQueueStatusList(appName);

    if (queueStatusList.includes("completed_queue")) {
      obj.isInstalled = true;
    } else {
      obj.isInstalled = false;
    }

    if (queueStatusList.includes("failed_queue")) {
      obj.isFailed = true;
    } else {
      obj.isFailed = false;
    }

    if (queueStatusList.includes("pending_queue")) {
      obj.isPending = true;
    } else {
      obj.isPending = false;
    }

    return obj;
  };

  const syncFilter = () => {
    let obj = {
      isInstalled: false,
      isFailed: false,
      isInstalling: false,
      isUninstalling: false,
      isPending: false,
    };
    try {
      if (filterInstallationStatusList.includes("isInstalled")) {
        obj.isInstalled = true;
      } else if (filterInstallationStatusList.includes("IsPending")) {
        obj.isPending = true;
      } else if (filterInstallationStatusList.includes("IsFailed")) {
        obj.isFailed = true;
      }
    } catch (err) {
    } finally {
      setFilterObj(obj);
    }
  };

  const drawApplicationCards = () => {
    var apps = applicationData
      .filter((app) => {
        if (searchTerm == "") {
          // console.log("VAL TEST: ", app);
          return app;
        } else if (
          app.name.toLowerCase().includes(searchTerm.toLowerCase().trim())
        ) {
          return app;
        }
      })
      .map((app) => ({
        ...app,
        installation_status: getInstallationStatusObject(app.name),
      }))
      // .filter((app) => {
      //   console.log("OBJ-app: ", app.installation_status);
      //   console.log("OBJ-filter: ", filterObj);

      //   if (_.isEqual(app.installation_status, filterObj)) {
      //     return app;
      //   } else {
      //   }
      // })
      // .filter((app) => {
      //   console.log("APP DEBUG: ", app);
      //   let count = 0;
      //   let intersect = filterStatusList.filter((value) =>
      //     getQueueStatusList(app.name).includes(value)
      //   );
      //   filterStatusList.map((status) => {
      //     if (intersect.includes(status)) {
      //       count++;
      //     }
      //   });
      //   if (count > 0) {
      //     return app;
      //   } else if (
      //     !getQueueStatusList(app.name).includes("completed_queue") &&
      //     !filterStatusList.includes("completed_queue")
      //   ) {
      //     return app;
      //   }
      // })
      // .filter((app) => {
      //   console.log("List1: ", getQueueStatusList(app.name));
      //   console.log("List2: ", filterStatusList);

      //   let intersect = filterStatusList.filter((value) =>
      //     getQueueStatusList(app.name).includes(value)
      //   );

      //   filterStatusList.map((status) => {
      //     if (intersect.includes(status)) {
      //       return app;
      //     }
      //   });
      // })
      .sort(function (a, b) {
        const nameA = a.name.toUpperCase();
        const nameB = b.name.toUpperCase();
        if (sortSelect === "asc") {
          if (nameA < nameB) {
            return -1;
          }
          if (nameA > nameB) {
            return 1;
          }
        } else {
          if (nameB < nameA) {
            return -1;
          }
          if (nameB > nameA) {
            return 1;
          }
        }
        return 0;
      })
      // .filter((app) => {
      //   // console.log("val name: ", app.name);
      //   console.log("App debug in filter: ", app);
      //   return filterStatusList.map((statusA) => {
      //     let appQueueList = getQueueStatusList(app.name);

      //     console.log("Check app status: ", appQueueList);
      //     console.log("Check status: ", statusA);

      //     if (appQueueList.includes(statusA)) {
      //       console.error("includes");
      //       return app;
      //     } else {
      //       console.error("includes not ");
      //     }
      //   });
      // })
      .map((app, i) => {
        // console.log("APP status debug: ", app.installation_status);
        return (
          <ApplicationCard2
            app={app}
            key={i}
            queueData={queueData}
            fetchApplicationAndQueueData={fetchApplicationAndQueueData}
            isMqConnected={isMqConnected}
            getQueueStatusList={getQueueStatusList}
            isListLayout={isListLayout}
          />
        );
      });
    var appsCount = apps.length;
    localStorage.setItem("appsCount", appsCount);
    return apps;
  };

  const fetchApplicationAndQueueData = () => {
    fetchQueueData();
    fetchData();
  };

  // TODO get status by app name -> Return e.g. completed, pending, none
  const getInstallationStatusByAppName = () => {};

  const fetchQueueData = () => {
    const requests = queueList.map((queue) => {
      return axios
        .get("http://localhost:5001/api/queues/" + queue)
        .then((response) => {
          // console.log("debug-response: ", response);
          response.data.map((app) => {
            queueData.push(app);
            // console.log("Queue Data debug: ", queueData);
          });
        })
        .then(() => {
          // console.log("debug-all data: ", queueData);
        });
    });

    Promise.all(requests)
      .then(() => {
        setQueueData(queueData);
        setIsLoading(false);
      })
      .then(() => {
        // console.log("QueueData after fetch: ", queueData);
      });
  };

  const checkMqConnection = () => {
    axios.get("http://localhost:5001/api/checkRmqConn").then((response) => {
      setIsMqConnected(response.data);
    });
  };

  const addStatusToAppData = () => {
    let l = [];
    var promises = applicationData.map((app) => {
      // console.log("app: ", app);
      app["status"] = getQueueStatusList(app.name);
      console.log("l in map: ", l);
      return l.push(app);
    });
    Promise.all(promises).then(() => {
      // console.log("new app list: ", newAppList);
      setNewAppList(l);
    });
  };

  useEffect(() => {
    setAppsSearchResultCount(applicationData.length);
    setIsListLayout(localStorage.getItem("isListLayout"));

    // const id = setInterval(() => {
    //   fetchData();
    // }, 20000);

    checkMqConnection();

    try {
      fetchApplicationAndQueueData();
    } catch (err) {
      console.log(err);
    } finally {
      // addStatusToAppData();
    }

    return () => {
      // clearInterval(id);
    };
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
      <div className="flex mb-4 justify-between">
        {/* Left: Actions */}
        <div className="flex">
          <div className="flex ">
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
                className="h-[56px] focus:ring-2 focus:ring-kxBlue focus:outline-none bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring min-w-80 pl-10"
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
          <MultipleSelectCheckmarks
            setFilterStatusList={setFilterStatusList}
            filterStatusList={filterStatusList}
            filterInstallationStatusList={filterInstallationStatusList}
            setFilterInstallationStatusList={setFilterInstallationStatusList}
            setFilterObj={setFilterObj}
            drawApplicationCards={drawApplicationCards}
            syncFilter={syncFilter}
          />
        </div>

        {/* Right: Actions */}
        <div className="">
          <select
            onChange={(e) => {
              setSortSelect(e.target.value);
            }}
            name="sort-select"
            id="sort-select"
            className="h-[56px] bg-ghBlack2 py-3 border-none rounded-md cursor-pointer"
          >
            <option value="asc">Sort by name A-Z</option>
            <option value="desc">Sort by name Z-A</option>
          </select>
        </div>
      </div>
      {/* Results count and galery action buttons */}
      <div className="flex justify-between items-center">
        {/* left */}
        <div className="">
          {searchTerm != "" ? (
            <div className="text-lg text-gray-400 mb-4">
              {localStorage.getItem("appsCount")} results for "{searchTerm}"
            </div>
          ) : (
            <div className="text-lg text-gray-400 mb-4">
              {localStorage.getItem("appsCount")} available Applications
            </div>
          )}
        </div>
        {/* right */}
        <div className="mb-4 text-3xl">
          <button
            className={`mr-2 ${isListLayout ? "text-kxBlue" : "text-gray-500"}`}
            onClick={() => {
              toggleListLayout(true);
            }}
          >
            <FaThList />
          </button>
          <button
            className={`${!isListLayout ? "text-kxBlue" : "text-gray-500"}`}
            onClick={() => {
              toggleListLayout(false);
            }}
          >
            <BsGrid3X3GapFill />
          </button>
        </div>
      </div>

      <div className="grid grid-cols-12 gap-2">{drawApplicationCards()}</div>

      {/* Pagination */}
      <div className="flex justify-center pt-10">
        <ThemeProvider theme={darkTheme}>
          <PaginationRounded />
        </ThemeProvider>
      </div>
    </div>
  );
};
