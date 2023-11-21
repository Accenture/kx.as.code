'use client';
import { useEffect, useState } from "react";
import ApplicationCard from "./ApplicationCard";
import axios from "axios";
import PaginationRounded from "./PaginationRounded";
import usePagination from "../utils/Pagination";
import Tooltip from "@mui/material/Tooltip";
import { HiOutlineInformationCircle } from "react-icons/hi";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import AddIcon from "@mui/icons-material/Add";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import FormControl from "@mui/material/FormControl";
import FormGroup from "@mui/material/FormGroup";
import FormControlLabel from "@mui/material/FormControlLabel";
import Checkbox from "@mui/material/Checkbox";
import Select from "@mui/material/Select";
import Box from "@mui/material/Box";
import FilterSelectedOptions from "../components/FilterSelectedOptions.jsx";
import MultipleSelectCheckmarks from "../components/MultipleSelectCheckmarks";






const getArrayOfObjArray = (objArray: { name: string }[]) => {
  let list: string[] = [];
  objArray.map((obj) => {
    list.push(obj.name);
  });
  return list;
};

const filterAppsBySearchTermAndInstallationStatus = (
  data: any[],
  searchTerm: string,
  filterTags: any[],
  isCheckedCore: boolean
) => {
  let filteredData: any[] = [];

  try {
    filteredData = data
      .filter((app) => {
        if (isCheckedCore && app.installation_group_folder === "core") {
          return true;
        } else if (app.installation_group_folder !== "core") {
          return true;
        }
        return false;
      })
      .filter((app) => {
        let intersect: string[] = [];
        if (app.categories) {
          intersect = getArrayOfObjArray(filterTags).filter((value) =>
            app.categories.includes(value)
          );
        }
        if (Array.isArray(filterTags)) {
          if (filterTags.length === 0) {
            return true;
          } else if (intersect.length > 0) {
            return true;
          }
        }
        return false;
      })
      .filter((app) => {
        if (searchTerm === "") {
          return true;
        } else if (
          app.name.toLowerCase().includes(searchTerm.toLowerCase().trim())
        ) {
          return true;
        }
        return false;
      });
  } catch (error) {
    console.log(error);
  } finally {
    // localStorage.setItem("appsCount", filteredData.length.toString());
    return filteredData;
  }
};

const Applications = (props: any) => {
  const [applicationData, setApplicationData] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [queueData, setQueueData] = useState<any[]>([]);
  const [appsSearchResultCount, setAppsSearchResultCount] = useState<number>(0);
  const [isMqConnected, setIsMqConnected] = useState<boolean>(true);
  const [isListLayout, setIsListLayout] = useState<boolean>(false);
  const [isShowMoreFilters, setIsShowMoreFilters] = useState<boolean>(false);

  const [sortSelect, setSortSelect] = useState<string>("asc");
  const [resultsPerPage, setResultsPerPage] = useState<any>(10);
  const [filterTags, setFilterTags] = useState<any[]>([]);

  const [isCheckedCore, setIsCheckedCore] = useState<boolean>(false);
  const [totalChecked, setTotalChecked] = useState<number>(0);

  const [page, setPage] = useState<number>(1);
  let _DATA = usePagination({
    data: filterAppsBySearchTermAndInstallationStatus(
      applicationData,
      searchTerm,
      filterTags,
      isCheckedCore
    ),
    itemsPerPage: resultsPerPage,
  });
  const count: number = Math.ceil(
    filterAppsBySearchTermAndInstallationStatus(
      applicationData,
      searchTerm,
      filterTags,
      isCheckedCore
    ).length / resultsPerPage
  );

  const getInstallationStatusObject = (appName: string): InstallationStatus => {
    const obj: InstallationStatus = {
      isInstalled: false,
      isFailed: false,
      isInstalling: false,
      isUninstalling: false,
      isPending: false,
    };

    const queueStatusList: string[] = getQueueStatusList(appName);

    obj.isInstalled = queueStatusList.includes("completed_queue");
    obj.isFailed = queueStatusList.includes("failed_queue");
    obj.isPending = queueStatusList.includes("pending_queue");

    return obj;
  };

  // Define the InstallationStatus interface
  interface InstallationStatus {
    isInstalled: boolean;
    isFailed: boolean;
    isInstalling?: boolean;
    isUninstalling?: boolean;
    isPending: boolean;
  }

  const syncFilter = (): void => {
    const obj: InstallationStatus = {
      isInstalled: false,
      isFailed: false,
      isInstalling: false,
      isUninstalling: false,
      isPending: false,
    };
  
    try {
      if (filterInstallationStatusList.includes("isInstalled")) {
        obj.isInstalled = true;
      } else if (filterInstallationStatusList.includes("isPending")) {
        obj.isPending = true;
      } else if (filterInstallationStatusList.includes("isFailed")) {
        obj.isFailed = true;
      }
    } catch (err) {
      // Handle errors if necessary
    } finally {
      setFilterObj(obj);
    }
  };
  
  // Define the InstallationStatus interface
  interface InstallationStatus {
    isInstalled: boolean;
    isFailed: boolean;
    isInstalling?: boolean;
    isUninstalling?: boolean;
    isPending: boolean;
  }
  

  const drawApplicationCards = (): JSX.Element[] => {
    const apps: JSX.Element[] = _DATA
      .currentData()
      .map((app) => ({
        ...app,
        installation_status: getInstallationStatusObject(app.name),
      }))
      .sort((a, b) => {
        const nameA = a.name.toUpperCase();
        const nameB = b.name.toUpperCase();
        if (sortSelect === 'asc') {
          return nameA.localeCompare(nameB);
        } else {
          return nameB.localeCompare(nameA);
        }
      })
      .map((app, i) => (
        <ApplicationCard
          app={app}
          key={i}
          queueData={queueData}
          fetchApplicationAndQueueData={fetchApplicationAndQueueData}
          isMqConnected={isMqConnected}
          getQueueStatusList={getQueueStatusList}
          isListLayout={isListLayout}
          addCategoryTofilterTags={addCategoryTofilterTags}
          applicationSelectedCount={applicationSelectedCount}
          onCheck={handleTotalCheckedChange}
          queueStatus={getQueueStatusByAppName(app.name)}
          queueList={queueList}
          layout={isListLayout}
        />
      ));

    return apps;
  };

  const [filterStatusList, setFilterStatusList] = useState<string[]>([
    "failed_queue",
    "completed_queue",
    "pending_queue",
  ]);

  const setPageAndJumpData = (e: any, p: number) => {
    setPage(p);
    _DATA.jump(p);
  };

  const [filterObj, setFilterObj] = useState<any>({});

  const [filterInstallationStatusList, setFilterInstallationStatusList] =
    useState<string[]>([
      "isInstalled",
      "isFailed",
      "isInstalling",
      "isUninstalling",
      "isPending",
    ]);

  const queueList: string[] = [
    "pending_queue",
    "failed_queue",
    "completed_queue",
    "retry_queue",
    "wip_queue",
  ];

  const handleTotalCheckedChange = (isChecked: boolean): void => {
    setTotalChecked(isChecked ? totalChecked + 1 : totalChecked - 1);
  };

  const applicationSelectedCount = (action: string) => {
    if (action === "select") {
      setTotalChecked(totalChecked + 1);
    } else {
      setTotalChecked(totalChecked + 1);
    }
  };

  const addCategoryTofilterTags = (newCategoryObj: any) => {
    setIsShowMoreFilters(true);
    var newList = filterTags;
    newList.push(newCategoryObj);
    setFilterTags(newList);
  };

  const setCategoriesFilterTags = (tagsList: any[]) => {
    setFilterTags(tagsList);
  };

  const getQueueStatusByAppName = async (appName: string) => {
    return await queueData.filter(function (obj) {
      if (JSON.parse(obj.payload).name === appName) {
        return obj.routing_key;
      }
    });
  };

  const toggleListLayout = (b: boolean) => {
    setIsListLayout(b);
  };

  const getQueueStatusList = (appName: string) => {
    let queueList: string[] = [];
    queueData.map((obj) => {
      if (JSON.parse(obj.payload).name === appName) {
        queueList.push(obj.routing_key);
      }
    });
    return queueList;
  };

  const fetchData = () => {
    axios.get("http://localhost:5001/api/applications").then((response) => {
      setApplicationData(response.data);
    });
  };

  const checkMqConnection = async () => {
    try {
      const response = await axios.get("http://localhost:5001/api/checkRmqConn");
      setIsMqConnected(response.data);
    } catch (error) {
      console.error("Error checking MQ connection:", error);
    }
  };

  const fetchQueueData = async () => {
    try {
      const requests = queueList.map(async (queue) => {
        const response = await axios.get("http://localhost:5001/mock/api/queues/" + queue);
        response.data.forEach((app: any) => {
          queueData.push(app);
        });
      });

      // Wait for all requests to complete
      await Promise.all(requests);

      // Additional logic after all requests are completed
      // console.log("All requests completed");
    } catch (error) {
      console.error("Error fetching queue data:", error);
      // Handle the error based on your requirements
    }
  };

  const fetchApplicationAndQueueData = async () => {
    try {
      await fetchQueueData();
      await fetchData();
    } catch (error) {
      console.error("Error fetching application and queue data:", error);
      // Handle the error based on your requirements
    }
  };

  useEffect(() => {
    setAppsSearchResultCount(applicationData.length);

    checkMqConnection();

    try {
      fetchApplicationAndQueueData();
    } catch (err) {
      console.log(err);
    }
  }, []);

  return (
    <div className="px-6 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Applications Header */}
      <div className="text-white pb-10">
        <div className="text-xl font-bold italic text-gray-500">
          APPLICATIONS
          <Tooltip
            title="Install applications into your KX.AS.CODE
          environemnt."
            placement="top"
            arrow
          >
            <button className="inline">
              <HiOutlineInformationCircle className="ml-1" />
            </button>
          </Tooltip>
        </div>
        <div className="pt-4 pb-6 text-[16px]">
          Install applications into your KX.AS.CODE environemnt.
        </div>

        <div className="border-b-2 border-gray-700"></div>
      </div>

      <div className="h-[40px]">
        <div className={`flex justify-end ${totalChecked > 0 ? "visible" : "hidden"}`}>
          {totalChecked > 0 && (
            <button className="bg-kxBlue p-2 px-5 rounded items-center flex">
              Install Selected {totalChecked === 1 ? "Application" : "Applications"} ({totalChecked})
            </button>
          )}
        </div>
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
              disable
              setFilterStatusList={setFilterStatusList}
              filterStatusList={filterStatusList}
              filterInstallationStatusList={filterInstallationStatusList}
              setFilterInstallationStatusList={setFilterInstallationStatusList}
              setFilterObj={setFilterObj}
              drawApplicationCards={drawApplicationCards}
              syncFilter={syncFilter}
            />
          </div>

          {/* Checkbox for Core Applications Filter */}
          <FormGroup>
            <FormControlLabel
              control={
                <Checkbox
                  value={isCheckedCore}
                  id="checkbox-filter-core"
                  onClick={() => {
                    setIsCheckedCore(!isCheckedCore);
                    console.log("Checked: ", isCheckedCore);
                  }}
                />
              }
              label="Show Core Applications"
            />
          </FormGroup>
        </div>
      </div>

      {/* Applications Content */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {
          _DATA.currentData().map((app, index) => (
            <ApplicationCard
              key={index}
              app={app}
              queueStatus={getQueueStatusByAppName(app.name)}
              queueList={queueList}
              layout={isListLayout}
              addCategoryTofilterTags={addCategoryTofilterTags}
              isMqConnected={isMqConnected}
              fetchApplicationAndQueueData={fetchApplicationAndQueueData}
              getQueueStatusList={getQueueStatusList}
              isListLayout={isListLayout}
              onCheck={handleTotalCheckedChange}
              queueData={queueData}
              applicationSelectedCount={applicationSelectedCount}
            />
          )
          )}
      </div>

      {/* Pagination */}
      <PaginationRounded
        count={count}
        page={page}
        setPage={setPage}
        setPageAndJumpData={setPageAndJumpData}
      />
    </div>
  );
};

export default Applications;
