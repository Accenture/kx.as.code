import React, { useState, useEffect, useRef } from 'react';
import CloseIcon from '@mui/icons-material/Close';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import applicationsJson from './assets/templates/applications.json';
import { FilterInput } from './FilterInput';
import { InfoBox } from './InfoBox';
import AppLogo from './AppLogo';
import {
    getPanelElement,
    getPanelGroupElement,
    getResizeHandleElement,
    Panel,
    PanelGroup,
    PanelResizeHandle,
} from "react-resizable-panels";
import Modal from '@mui/material/Modal';
import Box from '@mui/material/Box';
import InputField from './InputField';

export default function ApplicationSelection({ applicationGroup, addApplicationToApplicationGroupById, handleAddApplication, handleRemoveApplication,
    defaultLayout = [50, 50]
}) {
    const [searchTerm, setSearchTerm] = useState('');
    const [matchedApplications, setMatchedApplications] = useState([]);

    const [open, setOpen] = React.useState(false);
    const handleOpen = () => setOpen(true);
    const handleClose = () => setOpen(false);


    const modalStyle = {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: 700,
        border: '0',
        boxShadow: 24,
        p: 4
    };


    const doesObjectExist = (appName, includedAppsInGroupList) => {
        return includedAppsInGroupList.some((obj) => obj.name === appName);
    };

    const findApplicationByName = (appName) => {
        try {
            const foundApp = applicationsJson.find(obj => obj.name === appName);
            return foundApp || {};
        } catch (error) {
            console.error("Error while finding application by name:", error);
            return {};
        }
    };

    const createNewApplication = () => {
        handleOpen()
    }

    useEffect(() => {
        const filteredApplications = applicationsJson
            .filter((app) => {
                const appName = app.name.toLowerCase();
                const imageTag = findApplicationByName(app.name).environment_variables?.imageTag?.toLowerCase();

                const formattedAppName = appName.replace(/\s/g, '');
                const formattedImageTag = imageTag?.replace(/\s/g, '');
                const formattedSearchTerm = searchTerm.toLowerCase().replace(/\s/g, '');

                return (formattedAppName + formattedImageTag).includes(formattedSearchTerm);
            });
        setMatchedApplications(filteredApplications);
    }, [matchedApplications]);

    return (

        <div className="text-center text-white flex justify-center w-full rounded border-2 border-ghBlack4">

            <div className='pr-0 rounded-md w-full bg-ghBlack2'>
                <PanelGroup direction="horizontal" id="group" className="tab-content dark:text-white text-black flex-1 bg-ghBlack2">
                    <Panel defaultSize={defaultLayout[0]} id="left-panel" className='min-w-[200px]'>
                        {/* Input Search  */}
                        <FilterInput setSearchTerm={setSearchTerm} searchTerm={searchTerm} itemsCount={applicationsJson.length} itemName={"Applications"} hasActionButton={true} actionFunction={createNewApplication} />
                        <div className='h-[300px] overflow-y-scroll custom-scrollbar mt-3 px-2'>
                            <ul>
                                {
                                    (searchTerm !== "" ? matchedApplications : applicationsJson).length > 0 ? (
                                        (searchTerm !== "" ? matchedApplications : applicationsJson).map((app, i) => (
                                            <li className='p-2 py-1 bg-ghBlack2 hover:bg-ghBlack3 rounded cursor-pointer flex justify-between items-center' key={i}>


                                                <div className='text-left items-center flex'>

                                                    <AppLogo appName={app.name} />

                                                    <div className='ml-2'>
                                                        <span className='capitalize mr-1'>
                                                            {app.name}
                                                        </span>
                                                        <span className='lowercase'>
                                                            {app.environment_variables?.imageTag}
                                                        </span>
                                                        <div className='text-gray-400 uppercase text-sm'>{app.installation_group_folder}</div>
                                                    </div>

                                                </div>
                                                <div>
                                                    {doesObjectExist(app.name, applicationGroup.action_queues.install) ? (
                                                        <button
                                                            className='flex items-center justify-center p-1 bg-ghBlack4 text-white rounded'
                                                            onClick={() => {
                                                                handleRemoveApplication(app)
                                                            }}
                                                        >
                                                            <RemoveIcon fontSize='small' />
                                                        </button>
                                                    ) : (
                                                        <button
                                                            className='flex items-center justify-center p-1 bg-kxBlue text-white rounded'
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
                    </Panel>
                    <PanelResizeHandle id="resize-handle" className='w-1 hover:bg-kxBlue bg-ghBlack2' />
                    <Panel defaultSize={defaultLayout[1]} id="right-panel" className="min-w-[200px] p-2">
                        <div className='text-left text-gray-600 mb-3 font-semibold uppercase text-sm'>Added Applications to Group ({applicationGroup.action_queues.install.length})</div>
                        <div className='h-[300px] overflow-y-scroll custom-scrollbar pr-2'>
                            {applicationGroup.action_queues.install.map((app) => {
                                return <div className='cursor-pointer bg-kxBlue2 p-2 py-1 rounded mb-1 text-left'>
                                    <div className='flex items-center'>
                                        <AppLogo appName={app.name} />
                                        <div className='ml-1'>
                                            <span className='capitalize mr-1'>
                                                {app.name}
                                            </span>
                                            <span className='lowercase'>
                                                {findApplicationByName(app.name).environment_variables?.imageTag}
                                            </span>
                                            <div className='text-sm uppercase text-gray-400'>{app.install_folder}</div>
                                        </div>
                                    </div>
                                </div>
                            })}
                        </div>
                    </Panel>
                    <Modal
                        open={open}
                        onClose={handleClose}
                        aria-labelledby="modal-modal-title"
                        aria-describedby="modal-modal-description"
                    >
                        <Box sx={modalStyle} className="text-white bg-ghBlack2 focus:outline-none rounded-sm">
                           <h2 className='mb-3'>Create a new Application</h2>

                           <div className="bg-ghBlack3 h-[100px] w-[100px] rounded-sm mb-3 mx-auto"></div>
                           <InputField inputType={"input"} type={"text"} placeholder={"Application name"} handleInputChange={null} dataKey={"application_name"} label={"Application Name"}/>

                           <InputField inputType={"textarea"} type={"text"} placeholder={"Application Description"} handleInputChange={null} dataKey={"application_desc"} label={"Application Description"}/>
                        </Box>
                    </Modal>
                </PanelGroup>
            </div>

        </div>
    );
};