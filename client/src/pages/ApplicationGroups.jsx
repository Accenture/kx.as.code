import { React, Component } from "react";
import ApplicationGroupCard from "../partials/applicationGroups/ApplicationGroupCard";
import { Search24, Add24 } from "@carbon/icons-react";
import FilterButton from "../partials/actions/FilterButton";
import Modal from "../partials/applicationGroups/Modal";
import { useState, useEffect } from "react";

const applicationGroupJson = require("../../src/data/combined-application-group-files.json");

function ApplicationGroups() {
  const [searchTerm, setSearchTerm] = useState("");

  // constructor(props) {
  //   super(props);
  //   this.state = {
  //     applicationGroupsData: [],
  //     showModal: false,
  //     searchTerm: "",
  //   };
  //   this.modalHandler = this.modalHandler.bind(this);
  // }

  // const getQueueStatusList = (appName) => {
  //   // fetchQueueData();
  //   let queueList = [];
  //   queueData.map((obj) => {
  //     if (JSON.parse(obj.payload).name === appName) {
  //       // console.log("in GetQueue queue Name: ", obj.routing_key);
  //       queueList.push(obj.routing_key);
  //       // console.log("list: ", queueList);
  //     } else {
  //     }
  //   });
  //   // console.log("Debug getQueSTatusList: ", queueList);
  //   return queueList;
  // };

  // componentDidMount() {
  //   this.fetchApplicationGroupsData();
  //   this.setState({
  //     applicationGroupsData: applicationGroupJson,
  //   });
  // }

  // modalHandler(boolean) {
  //   this.setState({
  //     showModal: boolean,
  //   });
  // }

  useEffect(() => {
    return () => {};
  }, []);

  const drawApplicationGroupCards = () => {
    return applicationGroupJson
      .filter((val) => {
        if (searchTerm == "") {
          return val;
        } else if (
          val.name.toLowerCase().includes(searchTerm.toLowerCase().trim())
        ) {
          return val;
        }
      })
      .map((appGroup, i) => {
        return <ApplicationGroupCard appGroup={appGroup} key={i} />;
      });
  };

  // const fetchApplicationGroupsData = () => {
  //   this.setState({});
  // };

  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Application Groups Header */}
      <div className="text-white pb-10">
        <div className="text-xl font-bold italic text-gray-500">
          APPLICATION GROUPS
        </div>
        <div className="pt-4 pb-6 text-[16px]">
          Here you can select an application group from a list of available
          templates. An application group is a set of applications that are
          commonly deployed together, and in many cases they will also be
          integrated within KX.AS.CODE.
        </div>
        <div className="border-b-2 border-gray-700"></div>
      </div>

      {/* Application Groups actions */}
      <div className="sm:flex sm:justify-between mb-8">
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
              placeholder="Search Application Groups..."
              className="focus:ring-2 focus:ring-kxBlue focus:outline-none bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring min-w-80 pl-10"
              onChange={(e) => {
                setSearchTerm(e.target.value);
              }}
            />
          </div>
          {/* <FilterButton /> */}
        </div>
        {/* Right: Actions */}
        <div className="grid grid-flow-col sm:auto-cols-max justify-end sm:justify-end gap-2">
          {/* Add Template button */}
          {/* <button
            onClick={() => {}}
            className="btn h-12 px-4 bg-kxBlue hover:bg-kxBlue2 text-white rounded"
          >
            <Add24 />
            <span className="hidden xs:block capitalize">
              ADD APPLICATION GROUP
            </span>
          </button> */}
        </div>
      </div>

      <div className="grid grid-cols-12 gap-2">
        {drawApplicationGroupCards()}
      </div>

      {/* <Modal
        showModal={this.state.showModal}
        modalHandler={this.modalHandler}
      /> */}
    </div>
  );
}

export default ApplicationGroups;
