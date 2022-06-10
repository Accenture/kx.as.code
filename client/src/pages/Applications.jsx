import { React } from "react";
import ApplicationCard from "../partials/applications/ApplicationCard.jsx";
import axios from "axios";
import { FaThList } from "react-icons/fa";
import { BsGrid3X3GapFill } from "react-icons/bs";
import MultipleSelectCheckmarks from "../partials/MultipleSelectCheckmarks";
import { useState, useEffect } from "react";
import _ from "lodash";

import PaginationRounded from "../partials/PaginationRounded.jsx";
import usePagination from "../utils/Pagination";
import noResultsFace from "../media/svg/no_results_face.svg";
import FilterSelectedOptions from "../partials/FilterSelectedOptions";
import Button from "@mui/material/Button";
import AddIcon from "@mui/icons-material/Add";
import RemoveIcon from "@mui/icons-material/Remove";
//import { display } from "@mui/system";
import { list } from "postcss";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import FormControl from "@mui/material/FormControl";
import Select from "@mui/material/Select";
import Box from "@mui/material/Box";
import DeleteIcon from "@mui/icons-material/Delete";
import { IconButton } from "@material-ui/core";
import { FormatListBulleted } from "@mui/icons-material";
import AppsIcon from "@mui/icons-material/Apps";

const getArrayOfObjArray = (objArray) => {
  let list = [];
  if (Array.isArray(objArray)) {
    objArray.map((obj) => {
      list.push(obj.name);
    });
  }
  return list;
};

const filterAppsBySearchTermAndInstallationStatus = (
  data,
  searchTerm,
  filterTags
) => {
  try {
    var filteredData = data
      .filter((app) => {
        // console.log("filtertags: ", filterTags);
        let intersect = [];
        if (app.categories) {
          intersect = getArrayOfObjArray(filterTags).filter((value) =>
            app.categories.includes(value)
          );
        }
        if (Array.isArray(filterTags)) {
          if (filterTags.length == 0) {
            return app;
          } else if (intersect.length > 0) {
            return app;
          }
        }
      })
      .filter((app) => {
        if (searchTerm == "") {
          return app;
        } else if (
          app.name.toLowerCase().includes(searchTerm.toLowerCase().trim())
        ) {
          return app;
        }
      });
  } catch (error) {
    console.log(error);
  } finally {
    // console.log("len filtered: ", filteredData.length);
    localStorage.setItem("appsCount", filteredData.length);
    return filteredData;
  }
};

export const Applications = (props) => {
  const [applicationData, setApplicationData] = useState([]);
  const [newAppList, setNewAppList] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [queueData, setQueueData] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [appsSearchResultCount, setAppsSearchResultCount] = useState(0);
  const [isMqConnected, setIsMqConnected] = useState(true);
  const [isListLayout, setIsListLayout] = useState(true);
  const [isShowMoreFilters, setIsShowMoreFilters] = useState(false);

  const [sortSelect, setSortSelect] = useState("asc");
  const [resultsPerPage, setResultsPerPage] = useState(10);
  const [filterTags, setFilterTags] = useState([]);

  let [page, setPage] = useState(1);
  // const PER_PAGE = resultsPerPage;
  let _DATA = usePagination(
    filterAppsBySearchTermAndInstallationStatus(
      applicationData,
      searchTerm,
      filterTags
    ),
    resultsPerPage
  );
  const count = Math.ceil(
    filterAppsBySearchTermAndInstallationStatus(
      applicationData,
      searchTerm,
      filterTags
    ).length / resultsPerPage
  );

  const [filterStatusList, setFilterStatusList] = useState([
    "failed_queue",
    "completed_queue",
    "pending_queue",
  ]);

  const setPageAndJumpData = (e, p) => {
    setPage(p);
    _DATA.jump(p);
  };

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

  const addCategoryTofilterTags = (newCategoryObj) => {
    setIsShowMoreFilters(true);
    var newList = filterTags;
    newList.push(newCategoryObj);
    setFilterTags(newList);
    console.log("filTags list: ", filterTags);
  };

  const setCategoriesFilterTags = (tagsList) => {
    setFilterTags(tagsList);
  };

  const getQueueStatusByAppName = async (appName) => {
    return await queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === appName) {
        // setAppQueue(obj.routing_key);
        // console.log("get status debug: ", obj.routing_key);
        return obj.routing_key;
      } else {
      }
    });
  };

  const toggleListLayout = (b) => {
    setIsListLayout(b);
    localStorage.setItem("isListLayout", b);
    // console.log("isListLayout: ", b);
    // console.log("isListLayout-local: ", localStorage.getItem("isListLayout"));
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

  const getArrayOfObjArray = (objArray) => {
    let list = [];
    objArray.map((obj) => {
      list.push(obj.name);
    });
    return list;
  };

  const drawApplicationCards = () => {
    var apps = _DATA
      .currentData()
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
          <ApplicationCard
            app={app}
            key={i}
            queueData={queueData}
            fetchApplicationAndQueueData={fetchApplicationAndQueueData}
            isMqConnected={isMqConnected}
            getQueueStatusList={getQueueStatusList}
            isListLayout={isListLayout}
            addCategoryTofilterTags={addCategoryTofilterTags}
          />
        );
      });

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
      // console.log("l in map: ", l);
      return l.push(app);
    });
    Promise.all(promises).then(() => {
      // console.log("new app list: ", newAppList);
      setNewAppList(l);
    });
  };

  useEffect(() => {
    // console.log("count: ", localStorage.getItem("appsCount"));
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
        <div className="pt-4 pb-6 text-[16px]">
          Which Applications you want to install into your KX.AS Code
          environemnt?
        </div>

        <div className="border-b-2 border-gray-700"></div>
      </div>

      {/* Filter Section */}
      <div className="bg-inv3 px-5 py-8 my-5 rounded border border-gray-600">
        {/* Applications actions */}
        <div className="flex justify-between">
          {/* Left: Actions */}
          <div className="flex items-center">
            <div className="flex ">
              {/* Search Input Field */}
              <div className="group relative">
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
                  className="h-[56px] focus:ring-2 focus:ring-kxBlue bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none w-[240px] pl-10"
                  onChange={(e) => {
                    setSearchTerm(e.target.value);
                    _DATA.jump(1); // reset page to 1
                  }}
                />
              </div>

              {/* <FilterButton filterHandler={this.filterHandler}
                            isCompleted={this.state.isCompleted}
                            isFailed={this.state.isFailed}
                            isPending={this.state.isPending} /> */}
            </div>

            <div className="ml-3">
              <Button
                variant="outlined"
                size="small"
                className="h-full"
                onClick={(e) => {
                  setIsShowMoreFilters(!isShowMoreFilters);
                }}
              >
                {isShowMoreFilters ? (
                  <RemoveIcon fontSize="small" />
                ) : (
                  <AddIcon fontSize="small" />
                )}
                {isShowMoreFilters ? "Hide" : "Show"} More filters
              </Button>
            </div>
          </div>

          {/* Right: Actions */}
          <div className="flex">
            <div className="mr-5">
              <Box sx={{ minWidth: 120 }}>
                <FormControl sx={{ minWidth: 120 }}>
                  <InputLabel id="demo-simple-select-label">
                    Results per Page
                  </InputLabel>
                  <Select
                    labelId="results-per-page-select"
                    id="results-per-page-select"
                    value={resultsPerPage}
                    label="Results per Page"
                    onChange={(e) => {
                      setResultsPerPage(e.target.value);
                      _DATA.jump(1); // reset page to 1
                    }}
                  >
                    <MenuItem value={10}>10</MenuItem>
                    <MenuItem value={20}>20</MenuItem>
                    <MenuItem value={30}>30</MenuItem>
                    <MenuItem value={40}>40</MenuItem>
                    <MenuItem value={50}>50</MenuItem>
                  </Select>
                </FormControl>
              </Box>
            </div>

            <div>
              <Box sx={{ minWidth: 120 }}>
                <FormControl sx={{ minWidth: 120 }}>
                  <InputLabel id="demo-simple-select-label">
                    Sort by Name
                  </InputLabel>
                  <Select
                    labelId="sort-select"
                    id="sort-select"
                    value={sortSelect}
                    label="Sort by Name"
                    onChange={(e) => {
                      setSortSelect(e.target.value);
                      _DATA.jump(1); // reset page to 1
                    }}
                  >
                    <MenuItem value={"asc"}>A-Z</MenuItem>
                    <MenuItem value={"desc"}>Z-A</MenuItem>
                  </Select>
                </FormControl>
              </Box>
            </div>
          </div>
        </div>

        {/* More Filters section */}
        <div className={` ${isShowMoreFilters ? "" : "hidden"} mt-5`}>
          <div className="flex">
            <FilterSelectedOptions
              applicationData={applicationData}
              setCategoriesFilterTags={setCategoriesFilterTags}
            />

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
        </div>
      </div>

      {/* Results count and galery action buttons */}
      <div className="flex justify-between items-center">
        {/* left */}
        <div className="">
          {searchTerm != "" ? (
            <div className="text-[16px] text-gray-400 mb-4">
              {localStorage.getItem("appsCount")} results for "{searchTerm}"
            </div>
          ) : (
            <div className="text-[16px] text-gray-400 mb-4">
              {localStorage.getItem("appsCount")} available Applications
            </div>
          )}
        </div>
        {/* right */}
        <div className="mb-4 text-3xl">
          {isListLayout ? (
            <div>
              <IconButton
                aria-label="list"
                color="primary"
                onClick={() => {
                  toggleListLayout(true);
                }}
              >
                <FormatListBulleted />
              </IconButton>
              <IconButton
                aria-label="galery"
                onClick={() => {
                  toggleListLayout(false);
                }}
              >
                <AppsIcon />
              </IconButton>
            </div>
          ) : (
            <div>
              <IconButton
                aria-label="list"
                onClick={() => {
                  toggleListLayout(true);
                }}
              >
                <FormatListBulleted />
              </IconButton>
              <IconButton
                aria-label="galery"
                color="primary"
                onClick={() => {
                  toggleListLayout(false);
                }}
              >
                <AppsIcon />
              </IconButton>
            </div>
          )}
        </div>
      </div>

      {/* Pagination Top */}
      <div className="flex justify-center pb-10">
        <PaginationRounded
          setPageAndJumpData={setPageAndJumpData}
          page={page}
          PER_PAGE={resultsPerPage}
          count={count}
        />
      </div>

      {localStorage.getItem("appsCount") <= 0 && (
        <div className="">
          <div className="flex justify-center">
            <img
              src={noResultsFace}
              height="100px"
              width="100px"
              alt="No results"
            ></img>
          </div>
          <div className="flex justify-center text-lg mt-3 text-gray-500">
            No results.
          </div>
        </div>
      )}
      <div className="grid grid-cols-12 gap-2">{drawApplicationCards()}</div>

      {/* Pagination bottom */}
      <div className="flex justify-center pt-10">
        <PaginationRounded
          setPageAndJumpData={setPageAndJumpData}
          page={page}
          PER_PAGE={resultsPerPage}
          count={count}
        />
      </div>
    </div>
  );
};
