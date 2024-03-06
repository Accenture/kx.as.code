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
import ApplicationSelection from './ApplicationSelection';
import FilterList from '@mui/icons-material/FilterList';
import { Clear, Info } from '@mui/icons-material';
import { IconButton } from '@mui/material';
import { SearchInput } from './SearchInput';
import { InfoBox } from './InfoBox';


export function ApplicationGroups({
    defaultLayout = [33, 67]
}) {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState([]);
    const [applicationGroupDetailTab, setApplicationGroupDetailTab] = useState("config-ui");
    const [windowHeight, setWindowHeight] = useState(window.innerHeight);

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    useEffect(() => {
        const handleResize = () => {
            setWindowHeight(window.innerHeight);
        };
        window.addEventListener('resize', handleResize);

        setJsonData(JSON.stringify(applicationGroupJson, null, 2))

        // Detach event listener on component unmount
        return () => {
            window.removeEventListener('resize', handleResize);
        };

    }, [activeConfigTab, jsonData, applicationGroupDetailTab]);

    return (
        <div className='text-left'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky z-10 p-1'>
                    <div className='col-span-9'>
                        <ConfigSectionHeader sectionTitle={"Application Groups"} SectionDescription={"More Details about this section here."} />
                    </div>
                    <div className='col-span-3 pr-10 mx-3'>
                        <div className="relative w-full h-[40px] p-1 bg-ghBlack3 rounded">
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
                                    } py-1 text-white bg-ghBlack4 text-sm flex items-center justify-center w-1/2 rounded-sm transition-all duration-150 ease-linear top-[5px] absolute`}
                            >
                                {activeConfigTab === 'config-tab1'
                                    ? "Config UI"
                                    : "JSON"}
                            </span>
                        </div>
                    </div>

                </div>
            </div>
            <div className="config-tab-content flexGrow">
                <div className='bg-ghBlack2 h-1'></div>

                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} applicationGroupDetailTab={applicationGroupDetailTab} setApplicationGroupDetailTab={setApplicationGroupDetailTab} windowHeight={windowHeight} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"applicationGroups.json"} windowHeight={windowHeight} />}
            </div>
        </div>)

};


const UIConfigTabContent = ({ activeTab, handleTabClick, setJsonData, applicationGroupDetailTab, setApplicationGroupDetailTab, windowHeight,
    defaultLayout = [30, 70] }) => {

    const initialData = [
        {
            "title": "Examples Group 1",
            "description": "Group used to show specific use cases and for debugging changes and enhancements to framework",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "examples",
                        "name": "hipster-shop"
                    }
                ]
            }
        },
        {
            "title": "CICD Group 1",
            "description": "CICD Group 1 for sites with a larger physical resources",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "storage",
                        "name": "minio-operator"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "gitlab"
                    },
                    {
                        "install_folder": "collaboration",
                        "name": "mattermost"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "harbor"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "argocd"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "artifactory"
                    }
                ]
            }
        },
        {
            "title": "CICD Group 2",
            "description": "CICD Group 1 for sites with a lower physical resources",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "cicd",
                        "name": "gitea"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "jenkins"
                    },
                    {
                        "install_folder": "collaboration",
                        "name": "rocketchat"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "nexus3"
                    }
                ]
            }
        },
        {
            "title": "QA Group 1",
            "description": "QA group comprising of SonarQube and Selenium",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "quality_assurance",
                        "name": "sonarqube"
                    },
                    {
                        "install_folder": "quality_assurance",
                        "name": "selenium4"
                    }
                ]
            }
        },
        {
            "title": "Prometheus/Grafana Stack",
            "description": "Monitoring group with the Prometheus/Grafana stack",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "monitoring",
                        "name": "prometheus"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "loki"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "graphite"
                    }
                ]
            }
        },
        {
            "title": "Elastic-Stack",
            "description": "Monitoring group with the Elastic-Stack",
            "action_queues": {
                "install": [
                    {
                        "install_folder": "monitoring",
                        "name": "elastic-elasticsearch"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "elastic-kibana"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "elastic-filebeat"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "elastic-metricbeat"
                    },
                    {
                        "install_folder": "monitoring",
                        "name": "elastic-heartbeat"
                    }
                ]
            }
        }
    ];

    const [searchTerm, setSearchTerm] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isListLayout, setIsListLayout] = useState(true);
    // const [selectedId, setSelectedId] = useState(null);
    // const [detailsObject, setDetailsObject] = useState({});
    // const [isEditable, setIsEditable] = useState(false);
    // const [data, setData] = useState(applicationGroupJson);
    const [modalIsOpen, setModalIsOpen] = useState(false);
    // const [currentId, setCurrentId] = useState(null);

    const [data2, setData2] = useState(initialData);
    const [selectedItem, setSelectedItem] = useState(0);

    // *********** New Functions START ***********
    const handleItemClick = (index) => {
        setSelectedItem(index);
    };

    const handleInputChange = (field, value) => {
        setData2((prevData) => {
            const newData = [...prevData];
            newData[selectedItem][field] = value;
            return newData;
        });
    };

    const handleAddNewItem = () => {
        const existingGroups = data2.filter((obj) => obj.title.startsWith('New Group'));

        let nextNumber = 1;
        const existingNumbers = existingGroups.map((obj) => {
            const match = obj.title.match(/\d+$/);
            return match ? parseInt(match[0]) : 0;
        });
        while (existingNumbers.includes(nextNumber)) {
            nextNumber++;
        }

        const newObject = {
            title: `New Group ${nextNumber}`,
            description: 'New Group Description',
            action_queues: {
                install: [
                ],
            },
        };

        setData2((prevData) => {
            const newData = [...prevData, newObject];
            setSelectedItem(newData.length - 1);
            return newData;
        });
    };

    const handleAddApplication = (app) => {
        console.log("app: ", app)
        setData2((prevData) => {
            const newData = [...prevData];
            newData[selectedItem].action_queues.install.push({ install_folder: app.installation_group_folder, name: app.name });
            return newData;
        });
    };

    const handleRemoveApplication = (app) => {
        setData2((prevData) => {
            const newData = [...prevData];
            const indexToRemove = newData[selectedItem].action_queues.install.findIndex(item => item.name === app.name);

            if (indexToRemove !== -1) {
                newData[selectedItem].action_queues.install.splice(indexToRemove, 1);
            }

            return newData;
        });
    };

    const handleDeleteItem = (index) => {
        setData2((prevData) => {
            const newData = [...prevData];
            newData.splice(index, 1);
            if (selectedItem === index) {
                setSelectedItem(null);
            }
            return newData;
        });
    };

    const generateUniqueTitle = (title, newData) => {
        let newTitle = title + "-COPY";
        let count = 1;

        while (newData.some(item => item.title === newTitle || item.title.startsWith(newTitle + '-'))) {
            count++;
            newTitle = title + `-COPY (${count})`;
        }
        return newTitle;
    };

    const handleDublicateItem = (index) => {
        setData2((prevData) => {
            const newData = [...prevData];
            const itemToDuplicate = newData[index];

            const duplicatedItem = { ...itemToDuplicate };

            duplicatedItem.title = generateUniqueTitle(duplicatedItem.title, newData);

            newData.splice(index + 1, 0, duplicatedItem);

            return newData;
        });
    };

    // *********** New Functions END ***********



    const updateFieldInJsonObjectById = (id, fieldName, value) => {
        const updatedArray = JSON.parse(JSON.stringify(applicationGroupJson));
        const targetObject = updatedArray.find((obj) => obj.id === id);
        if (targetObject) {
            targetObject[fieldName] = value;
        }
        return updatedArray;
    };

    const handleAppGroupChange = (id, fieldName, value) => {
        console.log("id : ", id)
        console.log("fieldName : ", fieldName)
        console.log("value : ", value)

        const updatedJsonArray = updateFieldInJsonObjectById(id, fieldName, value)

        const updatedJsonString = JSON.stringify(updatedJsonArray, null, 2);
        setJsonData(updatedJsonString);
        UpdateJsonFile(updatedJsonString, "applicationGroups");
    }

    const openModal = () => {
        setModalIsOpen(true);
    };

    const closeModal = () => {
        setModalIsOpen(false);
    };

    const refs = useRef();

    const getObjectById = (id) => {
        console.log("details obj: ", data.find(item => item.id === id))
        return data.find(item => item.id === id);
    }

    const getLastId = (data) => {
        if (data.length === 0) {
            return null;
        }
        return data.reduce((maxId, item) => (item.id > maxId ? item.id : maxId), data[0].id);
    };

    const removeApplicationGroupById = (id) => {
        const updatedData = data.filter((item) => item.id !== id);
        setData(updatedData)
        const updatedJsonString = JSON.stringify(updatedData, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    const handleKeyDown = (e) => {
        if (e.key === 'ArrowUp' && selectedItem > 0) {
            handleItemClick(selectedItem - 1);
        } else if (e.key === 'ArrowDown' && selectedItem < data2.length - 1) {
            handleItemClick(selectedItem + 1);
        }
    };

    useEffect(() => {
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

        const listElement = document.getElementById('list');
        listElement.scrollTop = selectedItem * 50;

        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener('keydown', handleKeyDown);
        };
    }, [data2, applicationGroupJson, windowHeight, selectedItem]);

    const drawApplicationGroupCards = () => {
        const filteredData = data2.filter((appGroup) => {
            const lowerCaseName = (appGroup.title || "").toLowerCase();
            return searchTerm === "" || lowerCaseName.includes(searchTerm.toLowerCase().trim());
        });

        if (filteredData.length === 0) {
            if (searchTerm !== "") {
                return (
                    <InfoBox>
                        <div className='ml-1'>No results found for "{searchTerm}".</div>
                    </InfoBox>
                );
            }
            else {
                return (
                    <InfoBox>
                        <div className='ml-1'>No available Application Groups.</div>
                    </InfoBox>
                );
            }
        }

        return filteredData
            .map((appGroup, index) => (
                <ApplicationGroupCard appGroup={appGroup} isListLayout={isListLayout} index={index} selectedItem={selectedItem} handleItemClick={handleItemClick} handleDeleteItem={handleDeleteItem} handleDublicateItem={handleDublicateItem} />
            ));
    };

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

        // const updatedData = [newObject, ...data];
        // setData(updatedData)
        // const updatedJsonString = JSON.stringify(updatedData, null, 2);
        // UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    const addApplicationToApplicationGroupById = (id, newApplicationObject) => {
        setData((prevData) => {
            return prevData.map((group) => {
                if (group.id === id) {
                    const isExisting = group.action_queues.install.some((obj) => obj.name === newApplicationObject.name);

                    if (!isExisting) {
                        group.action_queues.install = [...group.action_queues.install, newApplicationObject];
                    }
                }
                return group;
            });
        });

        const updatedJsonString = JSON.stringify(data, null, 2);
        UpdateJsonFile(updatedJsonString, "applicationGroups")
    }

    return (
        <div id='config-ui-container' className='flex flex-col'>
            <PanelGroup direction="horizontal" id="group" className="tab-content dark:text-white text-black flex-1">
                <Panel defaultSize={defaultLayout[0]} id="left-panel" className='min-w-[290px]'>

                    {/* Search Input Field with filter button */}
                    <SearchInput setSearchTerm={setSearchTerm} searchTerm={searchTerm} itemsCount={data2.length} itemName={"Application Groups"} hasActionButton={true} actionFunction={handleAddNewItem} />
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack2 overflow-y-scroll px-2 py-3 custom-scrollbar" style={{ height: `${windowHeight - 103 - 67 - 40 - 67}px` }} id="list">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawApplicationGroupCards()}
                    </div>
                </Panel>
                <PanelResizeHandle id="resize-handle" className='w-1 hover:bg-kxBlue bg-ghBlack2' />
                <Panel defaultSize={defaultLayout[1]} id="right-panel" className="min-w-[500px]">
                    {/* <ApplicationGroupsModal isOpen={modalIsOpen} onRequestClose={closeModal} applicationGroupTitle={detailsObject.title} applicationGroup={detailsObject} addApplicationToApplicationGroupById={addApplicationToApplicationGroupById} /> */}

                    <div className={` ${applicationGroupDetailTab == "config-ui" ? "bg-ghBlack2" : "bg-ghBlack2"} overflow-y-scroll custom-scrollbar pt-0`} style={{ height: `${windowHeight - 103 - 40 - 53}px` }}>

                        {/* Application Group Details JSON View Toggle */}
                        <div className="sticky top-0 dark:bg-ghBlack2" style={{ zIndex: "10" }}>
                            <div className='flex itmes-center text-sm '>
                                <button
                                    onClick={() => { setApplicationGroupDetailTab("config-ui") }}
                                    className={` ${applicationGroupDetailTab == "config-ui" ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'border-ghBlack2 hover:border-ghBlack4 border-b-3 hover:bg-ghBlack3'} px-3 py-0`}
                                >
                                    Config UI
                                </button>
                                <button
                                    onClick={() => { setApplicationGroupDetailTab("json") }}
                                    className={` ${applicationGroupDetailTab == "json" ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'border-ghBlack2 border-b-3 hover:border-ghBlack4 hover:bg-ghBlack3'} px-3 py-0`}
                                >
                                    JSON
                                </button>
                            </div>
                        </div>

                        {selectedItem !== null && data2[selectedItem] && (

                            applicationGroupDetailTab == "config-ui" ? (
                                <div className='px-3'>

                                    <div className="pt-3">

                                        {/* Details Actions Header */}
                                        <div className='flex justify-end'>

                                        </div>

                                        <div className="items-center mb-3" >
                                            <div className='text-gray-600 text-sm font-semibold uppercase'>Group Title: </div>
                                            <input type="text" value={data2[selectedItem].title}
                                                s className={`w-full focus:outline-none rounded-sm p-2 bg-ghBlack3 focus:bg-ghBlack4 text-white`}
                                                onChange={(e) => handleInputChange('title', e.target.value)}
                                            />
                                        </div>

                                        <div className="items-center mb-1.5">
                                            <div className='text-gray-600 text-sm font-semibold uppercase'>Group Description: </div>
                                            <textarea type="text" value={data2[selectedItem].description} onChange={(e) => handleInputChange('description', e.target.value)} className='border-ghBlack3 w-full focus:bg-ghBlack4 focus:outline-none rounded-sm p-2 pr-10 bg-ghBlack3 text-white custom-scrollbar h-[120px] resize-none' />
                                        </div>
                                    </div>

                                    <div className="items-center">
                                        <div className='text-gray-600 text-sm font-semibold uppercase'>Applications: </div>
                                        <ApplicationSelection applicationGroupTitle={data2[selectedItem].title} applicationGroup={data2[selectedItem]} addApplicationToApplicationGroupById={addApplicationToApplicationGroupById} handleAddApplication={handleAddApplication} handleRemoveApplication={handleRemoveApplication} />
                                    </div>

                                </div>) : (
                                <JSONConfigTabContent jsonData={JSON.stringify(data2[selectedItem], null, 2)} fileName={data2[selectedItem].title} />
                            )

                        )}
                    </div>
                </Panel>
            </PanelGroup>
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