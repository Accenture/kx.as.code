import React, { useState, useEffect, useRef } from 'react';
import CloseIcon from '@mui/icons-material/Close';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import applicationsJson from './assets/templates/applications.json';

export default function ApplicationSelection({ applicationGroupTitle, applicationGroup, addApplicationToApplicationGroupById, windowHeight }) {
    const [name, setName] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [matchedApplications, setMatchedApplications] = useState([]);

    const handleInputChange = (event) => {
        const term = event.target.value;
        setSearchTerm(term);

        const filteredApplications = applicationsJson
            .filter((app) => app.name.toLowerCase().includes(term.toLowerCase()))
        // .slice(0, 5);
        setMatchedApplications(filteredApplications);
    };

    const doesObjectExist = (appName, includedAppsInGroupList) => {
        return includedAppsInGroupList.some((obj) => obj.name === appName);
    };

    const handleAddApplicationClick = (appName, installFolder) => {
        const maxId = applicationGroup.action_queues.install.reduce((max, obj) => (obj.id > max ? obj.id : max), -1);

        const newApplicationObject = {
            id: maxId + 1,
            name: appName,
            install_folder: installFolder
        };

        addApplicationToApplicationGroupById(applicationGroup.id, newApplicationObject)
    }

    useEffect(() => {

    }, []);

    return (

        <div className="text-center text-white flex justify-center w-full bg-ghBlack4 rounded-lg p-1">

            <div className='p-2 rounded-lg w-full bg-ghBlack rounded-md'>
                <div className="bg-ghBlack grid grid-cols-12">
                    <div className="col-span-6">
                        {/* Input Search  */}
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
                                onChange={handleInputChange}
                                type="text"
                                placeholder="Search..."
                                className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack4 px-3 py-1 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none pl-10 rounded w-full"
                            />
                        </div>

                        <div className='h-[300px] overflow-y-scroll custom-scrollbar mt-3'>
                            <ul>
                                {(searchTerm !== "" ? matchedApplications : applicationsJson).map((app, i) => (
                                    <li className='p-2 mt-1 bg-ghBlack hover:bg-ghBlack3 rounded cursor-pointer mr-2 flex justify-between items-center' key={i}>
                                        <div className='text-left'>
                                            <div className='capitalize'>{app.name}</div>
                                            <div className='text-gray-400 uppercase text-sm'>{app.installation_group_folder}</div>
                                        </div>
                                        <div>
                                            {doesObjectExist(app.name, applicationGroup.action_queues.install) ? (
                                                <button
                                                    className='p-1 bg-ghBlack4 text-white rounded items-center'
                                                    onClick={() => {

                                                    }}>
                                                    <RemoveIcon />
                                                </button>
                                            ) : (
                                                <button
                                                    className='p-1 bg-kxBlue text-white rounded items-center'
                                                    onClick={() => {
                                                        handleAddApplicationClick(app.name, app.installation_group_folder)
                                                        console.log("DEBUG - ID div select", applicationGroup.id)
                                                    }}>
                                                    <AddIcon />
                                                </button>
                                            )}
                                        </div>
                                    </li>
                                ))}
                            </ul>

                        </div>
                    </div>
                    <div className="col-span-6 p-2">
                        <div className='text-left text-gray-400 mb-3'>Added Applications to Group: </div>
                        <div className='h-[300px] overflow-y-scroll custom-scrollbar'>
                            {applicationGroup.action_queues.install.map((app) => {
                                return <div className='cursor-pointer bg-kxBlue p-2 rounded mb-1 text-left'>
                                    <div className='text-base capitalize'>{app.name}</div>
                                    {/* Set first install folder value as Category  */}
                                    <div className='text-sm uppercase'>{app.install_folder}</div>
                                </div>
                            })}
                        </div>
                    </div>
                </div>

            </div>

        </div>
    );
};