import React, { useState, useEffect, useRef } from 'react';
import Modal from 'react-modal';
import CloseIcon from '@mui/icons-material/Close';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import applicationsJson from './assets/templates/applications.json';

Modal.setAppElement('#app');
Modal.defaultStyles.overlay.backgroundColor = 'transparent';

export default function ApplicationGroupsModal({ isOpen, onRequestClose, applicationGroupTitle, applicationGroup, addSelectedApplicationsToApplicationGroupById }) {
    const [name, setName] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [matchedApplications, setMatchedApplications] = useState([]);
    const [selectedApplicationsList, setSelectedApplicationsList] = useState([]);


    const handleInputChange = (event) => {
        const term = event.target.value;
        setSearchTerm(term);

        const filteredApplications = applicationsJson
            .filter((app) => app.name.toLowerCase().includes(term.toLowerCase()))
        // .slice(0, 5);
        setMatchedApplications(filteredApplications);
    };

    const handleSubmit = () => {
        console.log('Name submitted:', name);
        onRequestClose();
    };

    const handleAddApplicationClick = (appName, installFolder) => {
        const maxId = applicationGroup.action_queues.install.reduce((max, obj) => (obj.id > max ? obj.id : max), -1);

        const newApplicationObject = {
            id: maxId + 1,
            name: appName,
            install_folder : installFolder
        };

        setMatchedApplications((prevArray) => [...prevArray, newApplicationObject]);
        addSelectedApplicationsToApplicationGroupById(applicationGroup.id, matchedApplications)
    }

    const modalCustomStyles = {
        content: {
            top: '50%',
            left: '50%',
            right: 'auto',
            bottom: 'auto',
            marginRight: '-50%',
            transform: 'translate(-50%, -50%)',
            backgroundColor: "#1f262e",
            borderWidth: "1px",
            borderColor: "transparent",
            borderRadius: "8px",
            boxShadow: "0 3px 20px rgba(0, 0, 0, 0.5)",
            padding: "5px",
        },
    };

    return (
        <Modal
            isOpen={isOpen}
            onRequestClose={onRequestClose}
            contentLabel="Example Modal"
            style={modalCustomStyles}
        >
            <div className="relative text-center text-white">
                <div className='absolute top-0 right-0'>
                    <button className='bg-ghBlack text-gray-400 hover:text-white p-1 rounded' onClick={onRequestClose}>
                        <CloseIcon />
                    </button>
                </div>
                <div className='p-5 px-3'>
                    <div className='py-5 pt-8 px-3'>
                        <div>Add Applications to Group</div>
                        <div className='capitalize'>"{applicationGroupTitle}"</div>
                    </div>

                    <div className='p-2 bg-ghBlack rounded-lg w-[400px]'>
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
                        {matchedApplications.length > 0 && searchTerm !== "" && (
                            <div className='h-[300px] overflow-y-scroll custom-scrollbar mt-3'>
                                {matchedApplications.length > 0 && searchTerm !== "" && (
                                    <ul>
                                        {matchedApplications.map((app, i) => (
                                            <li className='p-2 mt-1 bg-ghBlack hover:bg-ghBlack3 rounded cursor-pointer mr-2 flex justify-between items-center' key={i}>
                                                <div className='capitalize'>{app.name}</div>
                                                <div>
                                                    <button
                                                        className='p-1 bg-ghBlack4 text-gray-400 hover:text-white rounded items-center'
                                                        onClick={() => {
                                                            handleAddApplicationClick(app.name, app.install_folder)
                                                        }}>
                                                        <AddIcon />
                                                    </button>
                                                </div>
                                            </li>
                                        ))}
                                    </ul>
                                )}
                            </div>
                        )}
                    </div>
                </div>

            </div>
        </Modal>
    );
};