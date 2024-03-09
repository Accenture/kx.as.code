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
import { ListItemCard } from './ListItemCard';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import BuildHistoryItemCard from './BuildHistoryItemCard';

export default function BuildHistory() {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState(JSON.stringify(applicationGroupJson, null, 2));
    const [data, setData] = useState([
        {
            "id": 0,
            buildId: "1708687943044747000",
            timestamp: "2024-02-23T12:32:23+01:00",
            status: "failed",
            logs: "[2024-02-23T14:34:39+01:00] [stage-3] - Install Packer\n[2024-02-23T14:34:40+01:00] [stage-4] - Execute Packer\nError: Failed to initialize build \"kx-main-virtualbox\"\n\nThe builder virtualbox-iso is unknown by Packer, and is likely part of a plugin\nthat is not installed.\nYou may find the needed plugin along with installation instructions documented\non the Packer integrations page.\n\nhttps://developer.hashicorp.com/packer/integrations?filter=virtualbox"
        },
        {
            "id": 1,
            buildId: "1708687943044747001",
            timestamp: "2024-02-23T12:32:23+01:00",
            status: "failed",
            logs: "Logs 2"
           
        },
        {
            "id": 2,
            buildId: "1708687943044747002",
            timestamp: "2024-02-23T12:32:23+01:00",
            status: "failed",
            logs: "Logs 3"
        }

    ]);

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    useEffect(() => {


    }, [activeConfigTab, data]);

    return (
        <div className='text-left'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky top-[67px] z-10 p-1'>
                    <div className='col-span-9'>
                        <ConfigSectionHeader sectionTitle={"Build History"} SectionDescription={"More Details about this section here."} />
                    </div>
                </div>
            </div>
            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent data={data} />}
            </div>
        </div>)

};


const UIConfigTabContent = ({ data }) => {
    const [searchTerm, setSearchTerm] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isListLayout, setIsListLayout] = useState(true);
    const [selectedId, setSelectedId] = useState(null);
    const [detailsObject, setDetailsObject] = useState({});


    const handleDivClick = (id) => {
        setSelectedId(id === selectedId ? null : id);
        setDetailsObject(getObjectById(id))
    };

    const getObjectById = (id) => {
        return data.find(item => item.id === id);
    }

    useEffect(() => {
        return () => { };
    }, []);

    const drawBuildCards = () => {
        return data
            .filter((build) => {
                const lowerCaseName = (build.buildId || "").toLowerCase();
                return searchTerm === "" || lowerCaseName.includes(searchTerm.toLowerCase().trim());
            })
            .map((build, i) => (
                <BuildHistoryItemCard build={build} id={build.id} isListLayout={isListLayout} handleDivClick={handleDivClick} selectedId={selectedId} />
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
                            <div className='text-gray-400 flex justify-between pt-1 items-center'>
                                <span>Build History</span>
                                <span className='p-1.5 py-0 bg-ghBlack4 text-gray-400 rounded'>{data.length}</span>
                            </div>
                        </div>
                    </div>
                    {/* Application Groups actions */}
                    <div className="dark:bg-ghBlack2 h-[500px] overflow-y-scroll px-3 py-2 custom-scrollbar">
                        {isLoading ? (<div className="animate-pulse flex flex-col col-span-full px-3">
                        </div>) : drawBuildCards()}
                    </div>
                </div>
                <div className="col-span-8 bg-ghBlack2 p-3">
                    {/* Render Build Details */}
                    {selectedId !== null && (
                        <>
                            <div className="grid grid-cols-12 rounded-md">
                                <div className="col-span-12 text-2xl font-semibold mb-2">
                                    {detailsObject.buildId}
                                </div>
                                <div className="col-span-12">
                                    {detailsObject.logs}
                                </div>
                            </div>
                        </>)}
                </div>
            </div>
            <div className='bg-ghBlack2 h-1'></div>
        </div>
    )
};