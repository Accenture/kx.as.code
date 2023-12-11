'use client';
import React, { useState, useEffect } from "react";
import ApplicationGroupCard from "../application-groups/ApplicationGroupCard";

interface ApplicationGroup {
  title: string;
}

const applicationGroupJson: ApplicationGroup[] = require("../../data/combined-application-group-files.json");

const ApplicationGroups: React.FC = () => {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [isListLayout, setIsListLayout] = useState<boolean>(true);

  useEffect(() => {

    return () => { };
  }, []);

  const drawApplicationGroupCards = () => {
    return applicationGroupJson
      .filter((appGroup) => {
        const lowerCaseName = (appGroup.title || "").toLowerCase();
        return searchTerm === "" || lowerCaseName.includes(searchTerm.toLowerCase().trim());
      })
      .map((appGroup, i) => (
        <ApplicationGroupCard appGroup={appGroup} key={i} isListLayout={isListLayout}/>
      ));
  };

  return (
    <div className="py-8 w-full bg-ghBlack text-white">
      {/* Application Groups Header */}
      <div className="text-white pb-10 px-20">
        <div className="text-white text-4xl uppercase font-extrabold">APPLICATION GROUPS</div>
        <div className="">
          <div className="pt-4 pb-6 text-base text-gray-400">
            Here you can select an application group from a list of available templates.
            An application group is a set of applications that are commonly deployed together,
            and in many cases, they will also be integrated within KX.AS.CODE.
          </div>
        </div>
      </div>

      <div className="p-10 px-20 bg-ghBlack4">

        <div className="flex items-center mb-10">
          {/* Search Input Field */}
          <div className="group relative mr-3">
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
              className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack px-3 py-2 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none min-w-80 pl-10"
              onChange={(e) => {
                setSearchTerm(e.target.value);
              }}
            />
          </div>
          <div className='text-gray-400 text-base'>Available Application Groups: {applicationGroupJson.length}</div>
        </div>

        {/* Application Groups actions */}
        <div className="grid grid-cols-12 gap-1">
          {isLoading ? (<div className="animate-pulse flex flex-col col-span-full">
          </div>): drawApplicationGroupCards()}
        </div>
      </div>

      {/* <Modal showModal={this.state.showModal} modalHandler={this.modalHandler} /> */}
    </div>
  );
};

export default ApplicationGroups;
