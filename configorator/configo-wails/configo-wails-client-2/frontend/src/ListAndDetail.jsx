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
import { FilterInput } from './FilterInput';
import { InfoBox } from './InfoBox';


export function ListAndDetail({ children }, { data, isDetailJsonTab, setIsDetailJsonTab, windowHeight, itemType,
    defaultLayout = [30, 70] }) {

    const initialData = [

    ];

    const [searchTerm, setSearchTerm] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isListLayout, setIsListLayout] = useState(true);

    const [data2, setData2] = useState(initialData);
    const [selectedItem, setSelectedItem] = useState(0);

    const refs = useRef();

    const handleItemClick = (index) => {
        setSelectedItem(index);
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

    const drawItemsCard = () => {

        if (itemType === "applicationGroup") {
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
        } else if (itemType === "application") {

        } else if (itemType === "customVariableGroup") {

        } else if (itemType === "customVariable") {

        } else if (itemType === "userGroups") {

        } else if (itemType === "user") {

        }else if (itemType === "buildHistory") {

        }else if (itemType === "workspace") {

        }

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
                    <div className="dark:bg-ghBlack2 overflow-y-scroll custom-scrollbar" style={{ height: `${windowHeight - 103 - 67 - 40 - 67}px` }} id="list">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full">
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
                                    onClick={() => { setIsDetailJsonTab(false) }}
                                    className={` ${!isDetailJsonTab ? 'border-kxBlue border-b-[2px] bg-ghBlack4 text-white' : 'border-ghBlack2 hover:border-ghBlack4 border-b-[2px] hover:bg-ghBlack2'} px-3 py-0 text-gray-400 hover:text-white`}
                                >
                                    Config UI
                                </button>
                                <button
                                    onClick={() => { setIsDetailJsonTab(true) }}
                                    className={` ${isDetailJsonTab ? 'border-kxBlue border-b-[2px] bg-ghBlack4 text-white' : 'border-ghBlack2 border-b-[2px] hover:border-ghBlack4 hover:bg-ghBlack2'} px-3 py-0 text-gray-400 hover:text-white`}
                                >
                                    JSON
                                </button>
                            </div>
                        </div>

                        {selectedItem !== null && data2[selectedItem] && (

                            applicationGroupDetailTab == "config-ui" ? (
                                { children }) : (
                                <JSONConfigTabContent jsonData={JSON.stringify(data2[selectedItem], null, 2)} fileName={data2[selectedItem].title} />
                            )
                        )}
                    </div>
                </Panel>
            </PanelGroup>
        </div>
    )
};