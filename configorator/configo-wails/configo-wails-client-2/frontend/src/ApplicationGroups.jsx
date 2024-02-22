import React, { useState, useEffect } from 'react';
import applicationGroupJson from './assets/templates/applicationGroups.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import EditIcon from '@mui/icons-material/Edit';
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
                        <div className="relative w-full h-[40px] p-1 bg-ghBlack2 rounded-md">
                            <div className="relative w-full h-full flex items-center">
                                <div
                                    onClick={() => setActiveConfigTab('config-tab1')}
                                    className="w-full flex justify-center text-gray-300 cursor-pointer"
                                >
                                    <button className='text-sm'>
                                        Config UI
                                    </button>
                                </div>
                                <div
                                    onClick={() => setActiveConfigTab('config-tab2')}
                                    className="w-full flex justify-center text-gray-300 cursor-pointer"
                                >
                                    <button className='text-sm'>
                                        JSON
                                    </button>
                                </div>
                            </div>

                            <span
                                className={`${activeConfigTab === 'config-tab1'
                                    ? 'left-1 ml-0'
                                    : 'left-1/2 -ml-1'
                                    } py-1 text-white bg-ghBlack4 text-sm flex items-center justify-center w-1/2 rounded transition-all duration-150 ease-linear top-[5px] absolute`}
                            >
                                {activeConfigTab === 'config-tab1'
                                    ? "Config UI"
                                    : "JSON"}
                            </span>
                        </div>
                    </div>

                </div>
            </div>
            <div className='bg-ghBlack2 h-1'></div>
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
    const [detailsObject, setDetailsObject] = useState({});


    const handleDivClick = (id) => {
        setSelectedId(id === selectedId ? null : id);
        setDetailsObject(getObjectById(id))
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

    const getObjectById = (id) => {
        return applicationGroupJson.find(item => item.id === id);
    }

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
                <ApplicationGroupCard appGroup={appGroup} id={appGroup.id} isListLayout={isListLayout} handleDivClick={handleDivClick} selectedId={selectedId} />
            ));
    };

    return (
        <div id='config-ui-container' className='bg-ghBlack3'>
            <div className="tab-content dark:text-white text-black grid grid-cols-12">

                <div className='col-span-4'>
                    <div className='relative top-0 sticky bg-ghBlack2 py-2 shadow-lg px-3'>
                        <div className="items-center">
                            <div className='flex justify-center'>
                                {/* Search Input Field */}
                                <div className="group relative w-full">
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
                                        placeholder="Search..."
                                        className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack4 px-3 py-1 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none pl-10 rounded w-full"
                                        onChange={(e) => {
                                            setSearchTerm(e.target.value);
                                        }}
                                    />
                                </div>

                            </div>
                            <div className='text-gray-400 flex justify-between pt-1'>
                                <span>Application Groups</span>
                                {applicationGroupJson.length}
                            </div>
                        </div>
                    </div>
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack2 h-[500px] overflow-y-scroll px-3 py-2 custom-scrollbar">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawApplicationGroupCards()}
                    </div>
                </div>
                <div className="col-span-8 bg-ghBlack2 p-3">

                    {selectedId !== null && (
                        <>
                            <div className="grid grid-cols-12 rounded-md">
                                <div className="col-span-12">
                                    <div className="relative">
                                        <input type="text" value={detailsObject.title} className='w-full focus:outline-none rounded text-2xl font-semibold mb-2 p-1 pr-10 bg-transparent border-dashed hover:border-gray-500 focus:border-kxBlue border border-transparent text-white' />
                                        <div className="absolute right-4 top-2">
                                            <EditIcon fontSize='small'/>
                                        </div>
                                    </div>
                                    <div className="relative">
                                        <textarea type="text" value={detailsObject.description} className='w-full focus:outline-none rounded mb-2 p-1 pr-10 bg-transparent border-dashed hover:border-gray-500 focus:border-kxBlue border border-transparent text-gray-400' />
                                        <div className="absolute right-4 top-2">
                                            <EditIcon fontSize='small'/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="grid gap-2 grid-cols-12">
                                {detailsObject.action_queues.install.map((app) => {
                                    return <div className='cursor-pointer border border-dashed border-gray-500 hover:bg-ghBlack3 p-3 rounded col-span-6'>
                                        <div className='text-base'>{app.name}</div>
                                        <div className='text-gray-400'>{app.install_folder}</div>
                                    </div>
                                })}
                            </div>

                            <div className="grid gap-1 grid-cols-12">
                                <div className="col-span-12">
                                    <button className='bg-kxBlue p-2 py-3 mt-5 rounded w-full'>Add Application</button>
                                </div>
                            </div>

                        </>)}
                </div>
            </div>
            <div className='bg-ghBlack2 h-1'></div>
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