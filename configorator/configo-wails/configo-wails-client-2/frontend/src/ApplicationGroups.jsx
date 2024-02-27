import React, { useState, useEffect, useRef } from 'react';
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
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import DeleteForever from '@mui/icons-material/DeleteForever';

import {
    getPanelElement,
    getPanelGroupElement,
    getResizeHandleElement,
    Panel,
    PanelGroup,
    PanelResizeHandle,
} from "react-resizable-panels";
import Select from 'react-select';
import ApplicationGroupsModal from './ApplicationGroupsModal';


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
                    <div className='col-span-3 pr-10 mx-3'>
                        <div className="relative w-full h-[40px] p-1 bg-ghBlack rounded-md">
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
            <div className='bg-ghBlack h-1'></div>
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
    const [isEditable, setIsEditable] = useState(false);
    const [data, setData] = useState(applicationGroupJson);
    const [modalIsOpen, setModalIsOpen] = useState(false);

    const openModal = () => {
        setModalIsOpen(true);
    };

    const closeModal = () => {
        setModalIsOpen(false);
    };


    const refs = useRef();

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
        console.log("details obj: ", data.find(item => item.id === id))
        return data.find(item => item.id === id);
    }

    const getLastId = (dataParam) => {
        if (dataParam.length > 0) {
            const maxId = dataParam.reduce((max, obj) => (obj.id > max ? obj.id : max), dataParam[0].id);
            return maxId;
        } else {
            return null;
        }
    };

    const removeApplicationGroupById = (id) => {
        const updatedData = data.filter((item) => item.id !== id);
        setData(updatedData)
        const updatedJsonString = JSON.stringify(updatedData, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    useEffect(() => {
        // Initial select last element of data array (by id)
        console.log("last id: ", getLastId(data))
        handleDivClick(getLastId(data))

        const groupElement = getPanelGroupElement("group");
        const leftPanelElement = getPanelElement("left-panel");
        const rightPanelElement = getPanelElement("right-panel");
        const resizeHandleElement = getResizeHandleElement("resize-handle");

        refs.current = {
            groupElement,
            leftPanelElement,
            rightPanelElement,
            resizeHandleElement,
        };
        return () => { };
    }, [data, applicationGroupJson]);

    const drawApplicationGroupCards = () => {
        return data
            .filter((appGroup) => {
                const lowerCaseName = (appGroup.title || "").toLowerCase();
                return searchTerm === "" || lowerCaseName.includes(searchTerm.toLowerCase().trim());
            })
            .sort((a, b) => b.id - a.id)
            .map((appGroup, i) => (
                <ApplicationGroupCard removeApplicationGroupById={removeApplicationGroupById} appGroup={appGroup} id={appGroup.id} isListLayout={isListLayout} handleDivClick={handleDivClick} selectedId={selectedId} />
            ));
    };

    const toggleIsEditable = () => {
        setIsEditable((prevIsEditable) => !prevIsEditable);
    }

    const addNewApplicationToApplicationGroup = (appName) => {

    }

    const addNewApplicationGroup = () => {
        const maxId = data.reduce((max, obj) => (obj.id > max ? obj.id : max), -1);

        const existingGroups = data.filter((obj) => obj.title.startsWith('New Group'));

        let nextNumber = 1;
        const existingNumbers = existingGroups.map((obj) => {
            const match = obj.title.match(/\d+$/);
            return match ? parseInt(match[0]) : 0;
        });
        while (existingNumbers.includes(nextNumber)) {
            nextNumber++;
        }

        const newObject = {
            id: maxId + 1,
            title: `New Group ${nextNumber}`,
            description: 'New Group Description',
            action_queues: {
                install: [
                ],
            },
        };

        const updatedData = [newObject, ...data];
        setData(updatedData)
        const updatedJsonString = JSON.stringify(updatedData, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
        handleDivClick(getLastId(data))
    }

    const options = [
        { value: 'option1', label: 'Option 1' },
        { value: 'option2', label: 'Option 2' },
        { value: 'option3', label: 'Option 3' },
    ];

    const customSelectStyles = {
        control: (provided) => ({
            ...provided,
            backgroundColor: '#2f3640',
            color: 'white',
            padding: '3px',
            border: 'none'
        }),
        option: (provided, state) => ({
            ...provided,
            backgroundColor: "#2f3640",
            backgroundColor: state.isSelected ? '#2f3640' : '#2f3640',
            color: 'white',
        }),
    };

    const addSelectedApplicationsToApplicationGroupById = (id, selectedApplicationGroups) => {
        console.log("id ", id)
        console.log("selected Array: ", selectedApplicationGroups)
        setJsonData((prevArray) => {
            return prevArray.map((item) => {
              if (item.id === id) {
                if (!item.action_queues.install) {
                  item.action_queues.install = [];
                }
                item.action_queues.install.push(...selectedApplicationGroups);
              }
              return item;
            });
          });

        setData(jsonData)
        const updatedJsonString = JSON.stringify(updatedData, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
        // handleDivClick(getLastId(data))
    }

    return (
        <div id='config-ui-container' className='bg-ghBlack3'>
            <PanelGroup direction="horizontal" id="group" className="tab-content dark:text-white text-black">
                <Panel id="left-panel" className='min-w-[300px]'>
                    <div className='relative top-0 sticky bg-ghBlack p-3 shadow-lg flex'>
                        <div className="items-center w-full pr-2">
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
                            <div className='text-gray-400 flex justify-between pt-1 items-center'>
                                <span>Application Groups</span>
                                <span className='p-1.5 py-0 bg-ghBlack4 text-gray-400 rounded'>{data.length}</span>
                            </div>
                        </div>

                        <div className='flex justify-end'>
                            <button
                                className='p-2 bg-kxBlue hover:text-white rounded items-center'
                                onClick={() => {
                                    addNewApplicationGroup()
                                }}>
                                <AddIcon fontSize='medium' />
                            </button>
                        </div>

                    </div>
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack h-[500px] overflow-y-scroll px-3 py-3 custom-scrollbar">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawApplicationGroupCards()}
                    </div>
                </Panel>
                <PanelResizeHandle id="resize-handle" className='w-1 hover:bg-kxBlue bg-ghBlack' />
                <Panel id="right-panel" className="min-w-[370px]">
                    <ApplicationGroupsModal isOpen={modalIsOpen} onRequestClose={closeModal} applicationGroupTitle={detailsObject.title} applicationGroup={detailsObject} addSelectedApplicationsToApplicationGroupById={addSelectedApplicationsToApplicationGroupById} />
                    <div className='bg-ghBlack h-[584px] overflow-y-scroll custom-scrollbar p-3'>

                        {selectedId !== null && (
                            <>
                                <div className="grid grid-cols-12">
                                    <div className="col-span-12">
                                        {/* <div className="relative">
                                        <input type="text" value={detailsObject.title} className='w-full focus:outline-none rounded text-2xl font-semibold mb-2 p-1 pr-10 bg-transparent border-dashed hover:border-gray-500 focus:border-kxBlue border border-transparent text-white' />
                                        <div className="absolute right-4 top-2">
                                            <EditIcon fontSize='small' />
                                        </div>
                                    </div>
                                    <div className="relative">
                                        <textarea type="text" value={detailsObject.description} className='w-full min-h-[100px] focus:outline-none rounded mb-2 p-1 pr-10 bg-transparent border-dashed hover:border-gray-500 focus:border-kxBlue border border-transparent text-gray-400' />
                                        <div className="absolute right-4 top-2">
                                            <EditIcon fontSize='small' />
                                        </div>  
                                    </div> */}

                                        {/* Details Actions Header */}
                                        <div className='flex justify-end'>



                                        </div>

                                        <div className="items-center mb-3" >
                                            <div className='text-gray-400 text-sm'>Group Title: </div>
                                            <input type="text" value={detailsObject.title} className={`w-full focus:outline-none rounded p-2 pr-10 bg-ghBlack4 focus:border-kxBlue ${isEditable ? "border-kxBlue" : "border-ghBlack4"} border text-white`} />
                                        </div>

                                        {/* <div className="items-center mb-2">
                                            <div className='text-gray-400 text-sm'>Installation Group: </div>
                                            <div className="relative">
                                                <select
                                                    className="appearance-none bg-ghBlack4 text-white p-2 pr-10 rounded focus:outline-none w-full focus:border-kxBlue border border-transparent"
                                                >
                                                    <option>Option 1</option>
                                                    <option>Option 2</option>
                                                    <option>Option 3</option>
                                                </select>
                                                <svg
                                                    className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-white pointer-events-none"
                                                    xmlns="http://www.w3.org/2000/svg"
                                                    fill="none"
                                                    viewBox="0 0 24 24"
                                                    stroke="currentColor"
                                                >
                                                    <path
                                                        stroke-linecap="round"
                                                        stroke-linejoin="round"
                                                        stroke-width="2"
                                                        d="M19 9l-7 7-7-7"
                                                    />
                                                </svg>
                                            </div>
                                        </div> */}

                                        <div className="items-center mb-3">
                                            <div className='text-gray-400 text-sm'>Group Description: </div>
                                            <textarea type="text" value={detailsObject.description} className='w-full focus:outline-none rounded p-2 pr-10 bg-ghBlack4 focus:border-kxBlue border border-transparent text-white custom-scrollbar h-[150px] resize-none' />
                                        </div>
                                    </div>
                                </div>

                                {/* <div className="flex mb-5">
                                    <button onClick={() => {
                                        const newInstallObject = {
                                            install_folder: 'Install Folder',
                                            name: 'Application Name',
                                        };
                                        setDetailsObject((prevDetailsObject) => ({
                                            ...prevDetailsObject,
                                            action_queues: {
                                                ...prevDetailsObject.action_queues,
                                                install: [...prevDetailsObject.action_queues.install, newInstallObject],
                                            },
                                        }));
                                    }} className='bg-kxBlue p-2 py-2 rounded w-full'>Add Application</button>
                                </div> */}

                                <div className="items-center mb-3">
                                    <div className='text-gray-400 text-sm'>Applications: </div>
                                    <div className="grid gap-2 grid-cols-12 rounded">
                                        {detailsObject.action_queues.install.map((app) => {
                                            return <div className='cursor-pointer border border-dashed border-gray-500 hover:bg-ghBlack3 p-3 rounded col-span-6'>
                                                <div className='text-base'>{app.name}</div>
                                                {/* Set first install folder value as Category  */}
                                                <div className='text-gray-400'>{app.install_folder}</div>
                                            </div>
                                        })}
                                        <button className='border border-dashed border-gray-500 hover:bg-ghBlack3 text-gray-400 hover:text-white p-3 rounded col-span-6 min-h-[60px]'
                                            onClick={openModal}>
                                            <AddIcon fontSize='large' />
                                        </button>
                                    </div>
                                </div>

                            </>)}
                    </div>
                </Panel>

            </PanelGroup>
            <div className='bg-ghBlack h-1'></div>
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