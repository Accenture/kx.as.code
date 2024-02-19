import React, { useState, useEffect, useCallback } from 'react';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import configJSON from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONmainVirtualbox from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONnodeVirtualbox from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONmainParallels from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONnodeParallels from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONmainVMWare from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configJSONnodeVMWare from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import { useNavigate } from 'react-router-dom';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import CloudDownloadIcon from '@mui/icons-material/CloudDownload';
import JSONConfigTabContent from './JSONConfigTabContent';
import { UpdateJsonFile, IsVirtualizationToolInstalled } from "../wailsjs/go/main/App";
import IconButton from '@mui/material/IconButton';
import StopCircleIcon from '@mui/icons-material/StopCircle';
import Tooltip from '@mui/material/Tooltip';
import ProcessOutputView from './ProcessOutputView';
import LastProcessView from './LastProcessView';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';

const TabMenuBuild = ({ buildOutputFileContent, isBuildStarted, toggleBuildStart }) => {


    useEffect(() => {
    }, [buildOutputFileContent, isBuildStarted]);

    return (
        <div className='mt-[67px]'>
            {isBuildStarted ? <ProcessOutputView processType={"build"} logOutput={buildOutputFileContent} /> : <BuildTabContent />}
        </div>
    );
};

const BuildTabContent = () => {

    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');
    const [isBuild, setIsBuild] = useState(true);
    const [os, setOS] = useState("darwin-linux");
    const [nodeType, setNodeType] = useState("main");


    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    const handleConfigChange = (value, key) => {
        let selectedValue;

        if (!isNaN(value)) {
            selectedValue = parseFloat(value);
        } else {
            selectedValue = value;
        }

        let parsedData;

        if (os == "darwin-linux") {
            if (nodeType == "main") {
                parsedData = { ...configJSON };
            } else {
                console.error("nodeType not defined.")
            }
        } else {
            console.error("os not defined.")
        }

        setNestedValue(parsedData, key, selectedValue)

        const updatedJsonString = JSON.stringify(parsedData, null, 2);

        setJsonData(updatedJsonString);
        UpdateJsonFile(updatedJsonString);
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
        const jsonString = JSON.stringify(configJSON, null, 2);
        setJsonData(jsonString);
    }

    useEffect(() => {
        formatJSONData();
    }, [activeConfigTab, jsonData]);

    return (
        <div className='relative'>
            <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky top-[67px] z-10 p-1'>
                <div className='col-span-9'>
                    <ConfigSectionHeader sectionTitle={"Build Configuration"} SectionDescription={"More Details about the Build process here."} />
                </div>
                <div className='col-span-3 pr-10'>
                    <div className="relative w-full h-[40px] p-1 bg-ghBlack3 rounded-md">
                        <div className="relative w-full h-full flex items-center text-sm">
                            <div
                                onClick={() => setActiveConfigTab('config-tab1')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button>
                                    Config UI
                                </button>
                            </div>
                            <div
                                onClick={() => setActiveConfigTab('config-tab2')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button>
                                    JSON
                                </button>
                            </div>
                        </div>

                        <span
                            className={`${activeConfigTab === 'config-tab1'
                                ? 'left-1 ml-0'
                                : 'left-1/2 -ml-1'
                                } py-1 text-white bg-ghBlack4 text-sm font-semibold flex items-center justify-center w-1/2 rounded transition-all duration-150 ease-linear top-[5px] absolute`}
                        >
                            {activeConfigTab === 'config-tab1'
                                ? "Config UI"
                                : "JSON"}
                        </span>
                    </div>
                </div>
            </div>
            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content bg-ghBlack2">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent isBuild={isBuild} handleTabClick={handleTabClick} handleConfigChange={handleConfigChange} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"kx-main-local-profiles.json"} />}
            </div>
        </div>
    );
}

const UIConfigTabContent = ({ activeTab, handleTabClick, handleConfigChange, isBuild }) => (
    isBuild ?
        <div>
            <BuildContent />
            <LastProcessView processType={"build"} />
        </div> : <></>
);

const BuildContent = () => {
    const [installationStatus, setInstallationStatus] = useState({
        virtualbox: false,
        parallels: false,
        'vmware-desktop': false,
    });

    const [selectedVM, setSelectedVM] = useState("virtualbox");

    useEffect(() => {
        const checkToolInstallation = async (toolName) => {
            try {
                const result = await IsVirtualizationToolInstalled(toolName);
                setInstallationStatus(prevStatus => ({
                    ...prevStatus,
                    [toolName]: result,
                }));
            } catch (error) {
                console.error('Error:', error);
            }
        };

        checkToolInstallation('virtualbox');
        checkToolInstallation('parallels');
        checkToolInstallation('vmware-desktop');
    }, []);

    const getInstallationMark = (toolName) => (
        <div className='flex items-center mt-3.5 ml-2 text-sm capitalize bg-ghBlack4 p-2 rounded'>
            {installationStatus[toolName] ? (
                <span className='text-green-500 flex items-center px-1'>
                    <CheckCircleIcon />
                    <span className='ml-1'>{toolName} installed.</span>
                </span>
            ) : (
                <span className='text-red-500 flex items-center'>
                    <ErrorIcon />
                    <span className='ml-1'>{toolName} not installed.</span>
                    {/* <button className='ml-2 p-1 px-3 bg-kxBlue rounded text-white font-semibold text-xs'>Install</button> */}
                </span>
            )}
        </div>
    );

    return (
        <div className='text-left'>
            <div className='px-5 py-3 dark:bg-ghBlack3 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="VM Profile"
                        select
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={selectedVM}
                        onChange={(e) => setSelectedVM(e.target.value)}
                    >
                        <MenuItem value="virtualbox">Virtualbox</MenuItem>
                        <MenuItem value="parallels">Parallels</MenuItem>
                        <MenuItem value="vmware-desktop">VMWare Desktop</MenuItem>
                    </TextField>

                    <div>
                        <select
                            value={selectedVM}
                            onChange={(e) => setSelectedVM(e.target.value)}
                            className="bg-blue-500 text-white border-none outline-none px-4 py-3 rounded-5 focus:ring focus:ring-blue-200"
                        >
                            <option value="" disabled>Select a value...</option>
                            <option value="virtualbox">Option 1</option>
                            <option value="vmware-desktop">Option 2</option>
                            <option value="option3">Option 3</option>
                        </select>
                    </div>

                    <TextField
                        label="Node Type"
                        select
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value="main"
                        onChange={(e) => { }}
                    >
                        <MenuItem value="main">Main</MenuItem>
                        <MenuItem value="node">Node</MenuItem>
                    </TextField>
                </div>
                <div className='col-span-6'>
                    <div className='flex'>
                        {getInstallationMark(selectedVM)}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default TabMenuBuild;
