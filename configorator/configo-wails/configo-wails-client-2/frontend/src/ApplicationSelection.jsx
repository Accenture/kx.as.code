import React, { useState, useEffect, useRef } from 'react';
import CloseIcon from '@mui/icons-material/Close';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import applicationsJson from './assets/templates/applications.json';
import { SearchInput } from './SearchInput';
import { InfoBox } from './InfoBox';

export default function ApplicationSelection({ applicationGroup, addApplicationToApplicationGroupById, handleAddApplication, handleRemoveApplication }) {
    const [name, setName] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [matchedApplications, setMatchedApplications] = useState([]);

    const handleInputChange = (event) => {
        const term = event.target.value;
        setSearchTerm(term);
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

    const findApplicationByName = (appName) => {
        try {
            const foundApp = applicationsJson.find(obj => obj.name === appName);
            return foundApp || {} ;
        } catch (error) {
            console.error("Error while finding application by name:", error);
            return {}; 
        }
    };

    useEffect(() => {
        const filteredApplications = applicationsJson
            .filter((app) => (app.name.toLowerCase() + findApplicationByName(app.name).environment_variables?.imageTag).includes(searchTerm.toLowerCase()))
        setMatchedApplications(filteredApplications);
    }, [matchedApplications]);

    return (

        <div className="text-center text-white flex justify-center w-full rounded border-2 border-ghBlack4">

            <div className='p-2 p pr-0 rounded-md w-full bg-ghBlack2'>
                <div className="bg-ghBlack2 grid grid-cols-12">
                    <div className="col-span-6">
                        {/* Input Search  */}
                        <SearchInput setSearchTerm={setSearchTerm} searchTerm={searchTerm} />
                        <div className='h-[300px] overflow-y-scroll custom-scrollbar mt-3 pr-2'>
                            <ul>
                                {
                                    (searchTerm !== "" ? matchedApplications : applicationsJson).length > 0 ? (
                                        (searchTerm !== "" ? matchedApplications : applicationsJson).map((app, i) => (
                                            <li className='p-2 py-1 bg-ghBlack2 hover:bg-ghBlack3 rounded cursor-pointer flex justify-between items-center' key={i}>
                                                <div className='text-left'>
                                                    <div className='flex'>
                                                        <span className='capitalize mr-1'>
                                                            {app.name}
                                                        </span>
                                                        <span className='lowercase'>
                                                            {app.environment_variables?.imageTag}
                                                        </span>
                                                    </div>
                                                    <div className='text-gray-400 uppercase text-sm'>{app.installation_group_folder}</div>
                                                </div>
                                                <div>
                                                    {doesObjectExist(app.name, applicationGroup.action_queues.install) ? (
                                                        <button
                                                            className='p-1 bg-ghBlack4 text-white rounded items-center'
                                                            onClick={() => {
                                                                handleRemoveApplication(app)
                                                            }}
                                                        >
                                                            <RemoveIcon fontSize='small' />
                                                        </button>
                                                    ) : (
                                                        <button
                                                            className='p-1 bg-kxBlue text-white rounded items-center'
                                                            onClick={() => {
                                                                console.log("app-2: ", app)
                                                                handleAddApplication(app);
                                                            }}
                                                        >
                                                            <AddIcon fontSize='small' />
                                                        </button>
                                                    )}
                                                </div>
                                            </li>
                                        ))
                                    ) : (
                                        <InfoBox>
                                            <div className='ml-1'>
                                                {searchTerm !== ""
                                                    ? `No results found for "${searchTerm}".`
                                                    : "No available Application Groups."}
                                            </div>
                                        </InfoBox>
                                    )
                                }

                            </ul>

                        </div>
                    </div>
                    <div className="col-span-6 p-2">
                        <div className='text-left text-gray-400 mb-3 font-semibold uppercase text-sm'>Added Applications to Group: </div>
                        <div className='h-[300px] overflow-y-scroll custom-scrollbar pr-2'>
                            {applicationGroup.action_queues.install.map((app) => {
                                return <div className='cursor-pointer bg-kxBlue2 p-2 py-1 rounded mb-1 text-left'>
                                    <div className='flex'>
                                        <span className='capitalize mr-1'>
                                            {app.name}
                                        </span>
                                        <span className='lowercase'>
                                            {findApplicationByName(app.name).environment_variables?.imageTag}
                                        </span>
                                    </div>
                                    {/* Set first install folder value as Category  */}
                                    <div className='text-sm uppercase text-gray-400'>{app.install_folder}</div>
                                </div>
                            })}
                        </div>
                    </div>
                </div>

            </div>

        </div>
    );
};