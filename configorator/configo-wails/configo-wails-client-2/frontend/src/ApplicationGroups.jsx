import React, { useState, useEffect } from 'react';
import applicationGroupJson from './assets/templates/applicationGroups.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import JSONConfigTabContent from './JSONConfigTabContent';
import { ApplicationGroupCard } from './ApplicationGroupCard';


export function ApplicationGroups() {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState(JSON.stringify(applicationGroupJson, null, 2));

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    useEffect(() => {

    }, [activeConfigTab, jsonData]);

    return (
        <div className='text-left mt-[90px]'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='flex grid-cols-12 items-center relative bg-gray-200 dark:bg-ghBlack2 sticky top-[90px] z-10 h-[40px]'>
                    <button onClick={() => handleConfigTabClick('config-tab1')} className={`${activeConfigTab === "config-tab1" ? "bg-kxBlue2 text-white" : ""} dark:text-white text-black h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                        Application Groups UI
                    </button>

                    {/* Centered icon */}
                    <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                        <div className="w-10 h-10 dark:bg-ghBlack4 bg-gray-300 items-center flex justify-center text-xl">
                            <SettingsEthernetIcon fontSize='inherit' />
                        </div>
                    </div>

                    <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2 text-white" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                        Application Groups JSON
                    </button>
                </div>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"applicationGroups.json"} />}
            </div>
        </div>)

};


const UIConfigTabContent = ({ activeTab, handleTabClick, setJsonData }) => {
    const [searchTerm, setSearchTerm] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isListLayout, setIsListLayout] = useState(true);

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
                <ApplicationGroupCard appGroup={appGroup} key={i} isListLayout={isListLayout} />
            ));
    };

    return (
        <div id='config-ui-container' className=''>
            <div className='px-5 py-3 dark:bg-ghBlack2'>
                <h2 className='text-3xl font-semibold'>Application Groups</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
            </div>

            <div className="tab-content dark:text-white text-black">
                <div className='text-left'>
                    <div className="flex items-center mb-3">
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
                    <div className="grid grid-cols-12 gap-1 dark:bg-ghBlack4">
                            {isLoading ? (<div className="animate-pulse flex flex-col col-span-full">
                            </div>) : drawApplicationGroupCards()}
                        </div>
                </div>

            </div>
        </div>
    )
};


const TabContent1 = ({ setJsonData }) => {

    const handleConfigChange = (value, key) => {
        console.log("value: ", value);
        console.log("key: ", key);

        let selectedValue;

        if (typeof value === 'boolean' || typeof value === 'number') {
            selectedValue = value;
        } else if (typeof value === 'string') {
            selectedValue = value.trim();
        } else {
            console.error("Invalid data type for value parameter");
            return;
        }

        let parsedData = { ...usersJSON };

        setNestedValue(parsedData, key, selectedValue);

        const updatedJsonString = JSON.stringify(parsedData, null, 2);

        setJsonData(updatedJsonString);
        UpdateJsonFile(updatedJsonString, "users");
    };

    function setNestedValue(obj, key, value) {
        const keys = key.split('.');
        keys.reduce((acc, currentKey, index) => {
            if (index === keys.length - 1) {
                acc[currentKey] = value;
            } else {
                acc[currentKey] = acc[currentKey] || {};
            }
            return acc[currentKey];
        }, obj);
    }

    const formatJSONData = () => {
        const jsonString = JSON.stringify(usersJSON, null, 2);
        setJsonData(jsonString);
    }

    useEffect(() => {
        formatJSONData();
    }, []);


    return (
        <div></div>
    )
};