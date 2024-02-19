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
import { ConfigSectionHeader } from './ConfigSectionHeader';


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
        <div className='text-left mt-[67px]'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky top-[67px] z-10 p-1'>
                    <div className='col-span-9'>
                        <ConfigSectionHeader sectionTitle={"Application Groups"} SectionDescription={"More Details about this section here."} />
                    </div>
                    <div className='col-span-3 pr-10'>
                        <div className="relative w-full h-[40px] p-1 bg-ghBlack3 rounded-md">
                            <div className="relative w-full h-full flex items-center text-sm">
                                <div
                                    onClick={() => setActiveConfigTab('config-tab1')}
                                    className="w-full flex justify-center text-gray-300 cursor-pointer"
                                >
                                    <button>
                                        Config UI
                                    </button>
                                </div>
                                <div
                                    onClick={() => setActiveConfigTab('config-tab2')}
                                    className="w-full flex justify-center text-gray-300 cursor-pointer"
                                >
                                    <button>
                                        JSON
                                    </button>
                                </div>
                            </div>

                            <span
                                className={`${activeConfigTab === 'config-tab1'
                                    ? 'left-1 ml-0'
                                    : 'left-1/2 -ml-1'
                                    } py-1 text-white bg-ghBlack4 text-sm font-semibold flex items-center justify-center w-1/2 rounded transition-all duration-150 ease-linear top-[5px] absolute`}
                            >
                                {activeConfigTab === 'config-tab1'
                                    ? "Config UI"
                                    : "JSON"}
                            </span>
                        </div>
                    </div>

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

    const [selectedId, setSelectedId] = useState(null);

    const handleDivClick = (id) => {
        setSelectedId(id === selectedId ? null : id);
    };

    const handleKeyDown = (e) => {
        if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
            e.preventDefault();
            const currentIndex = jsonData.findIndex((item) => item.id === selectedId);
            const nextIndex =
                e.key === 'ArrowDown' ? (currentIndex + 1) % jsonData.length : (currentIndex - 1 + jsonData.length) % jsonData.length;
            setSelectedId(jsonData[nextIndex].id);
        }
    };

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
        <div id='config-ui-container' className='bg-ghBlack3 pt-5'>
            <div className="flex items-center m-5">
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
                        className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack4 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none min-w-80 pl-10 rounded"
                        onChange={(e) => {
                            setSearchTerm(e.target.value);
                        }}
                    />
                </div>
                <div className='text-gray-400 text-sm'>Available Application Groups: {applicationGroupJson.length}</div>
            </div>
            <div className="tab-content dark:text-white text-black grid grid-cols-12">
                {/* Application Groups actions */}
                <div className="dark:bg-ghBlack3 col-span-6 h-[400px] overflow-y-scroll pb-0">
                    {isLoading ? (<div className="animate-pulse flex flex-col col-span-full">
                    </div>) : drawApplicationGroupCards()}
                </div>

                <div className="col-span-6 bg-ghBlack3 ml-2">
                    <div className='bg-ghBlack4 w-full h-full'>

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