import React, { useState, useEffect, useRef } from 'react';
import applicationGroupJson from './assets/templates/applicationGroups.json';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import JSONConfigTabContent from './JSONConfigTabContent';
import { ListItemCard } from './ListItemCard';

import {
    getPanelElement,
    getPanelGroupElement,
    getResizeHandleElement,
    Panel,
    PanelGroup,
    PanelResizeHandle,
} from "react-resizable-panels";
import ApplicationSelection from './ApplicationSelection';
import { FilterInput } from './FilterInput';
import { InfoBox } from './InfoBox';
import InputField from './InputField';


export function ApplicationGroupsListAndDetail({ setJsonData, applicationGroupDetailTab, setApplicationGroupDetailTab, windowHeight,
    defaultLayout = [30, 70] }) {

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

    const [data2, setData2] = useState(initialData);
    const [selectedItem, setSelectedItem] = useState(0);

    const refs = useRef();

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
            description: '',
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
                setSelectedItem(selectedItem - 1);
            }
            return newData;
        });
    };

    const generateUniqueTitle = (title, newData) => {
        let newTitle = "";
        newTitle = title !== "" ? newTitle = title + "-COPY" : "No Titel-COPY"
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
                <ListItemCard itemData={appGroup} isListLayout={isListLayout} index={index} selectedItem={selectedItem} handleItemClick={handleItemClick} handleDeleteItem={handleDeleteItem} handleDublicateItem={handleDublicateItem} />
            ));
    };


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
                <Panel defaultSize={defaultLayout[0]} id="left-panel" className='min-w-[250px]'>

                    {/* Search Input Field with filter button */}
                    <FilterInput setSearchTerm={setSearchTerm} searchTerm={searchTerm} itemsCount={data2.length} itemName={"Application Groups"} hasActionButton={true} actionFunction={handleAddNewItem} />
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack2 overflow-y-scroll px-2 py-3 custom-scrollbar" style={{ height: `${windowHeight - 103 - 67 - 40 - 67}px` }} id="list">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawApplicationGroupCards()}
                    </div>
                </Panel>
                <PanelResizeHandle id="resize-handle" className='w-1 hover:bg-kxBlue bg-ghBlack2' />
                <Panel defaultSize={defaultLayout[1]} id="right-panel" className="min-w-[300px]">
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

                                        <InputField inputType={"input"} type={"text"} value={data2[selectedItem].title} placeholder={'Add a group title'} handleInputChange={handleInputChange} dataKey={"title"} label={"Group Title"} />

                                        <InputField inputType={"textarea"} type={"text"} value={data2[selectedItem].description} placeholder={'Add a group description'} handleInputChange={handleInputChange} dataKey={"description"} label={"Group Description"} />

                                    </div>

                                    <div className="items-center">
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