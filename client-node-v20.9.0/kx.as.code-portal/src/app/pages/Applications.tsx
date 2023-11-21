import { useEffect, useState } from "react";
import ApplicationCard from "../applications/ApplicationCard";
import axios from "axios";
import PaginationRounded from "../applications/PaginationRounded";
import usePagination from "../utils/Pagination";

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
    localStorage.setItem("appsCount", filteredData.length.toString());
    return filteredData;
  }
};

const Applications = (props: any) => {
  const [applicationData, setApplicationData] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [queueData, setQueueData] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [appsSearchResultCount, setAppsSearchResultCount] =
    useState<number>(0);
  const [isMqConnected, setIsMqConnected] = useState<boolean>(true);
  const [isListLayout, setIsListLayout] = useState<boolean>(false);
  const [isShowMoreFilters, setIsShowMoreFilters] = useState<boolean>(false);

  const [sortSelect, setSortSelect] = useState<string>("asc");
  const [resultsPerPage, setResultsPerPage] = useState<number>(10);
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
    setIsLoading(true);
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
        {/* ... (rest of the header) */}
      </div>

      <div className="h-[40px]">
        {/* ... (rest of the content) */}
      </div>

      {/* Filter Section */}
      <div className="my-4 flex items-center justify-between">
        {/* ... (rest of the filter section) */}
      </div>

      {/* Applications Content */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
        {isLoading ? (
          <p>Loading...</p>
        ) : (
          _DATA.currentData().map((app, index) => (
            <ApplicationCard
              key={index}
              app={app}
              queueStatus={getQueueStatusByAppName(app.name)}
              queueList={queueList}
              layout={isListLayout}
              addCategoryTofilterTags={addCategoryTofilterTags}
              isMqConnected={isMqConnected}
              history={props.history}
              fetchApplicationAndQueueData={fetchApplicationAndQueueData}
              getQueueStatusList={getQueueStatusList}
              isListLayout={isListLayout}
              onCheck={handleTotalCheckedChange}
            />
          ))
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
