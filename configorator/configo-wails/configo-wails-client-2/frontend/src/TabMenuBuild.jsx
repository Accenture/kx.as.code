import React, { useState, useEffect, useCallback } from 'react';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import configJSON from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import { useNavigate } from 'react-router-dom';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import CloudDownloadIcon from '@mui/icons-material/CloudDownload';
import JSONConfigTabContent from './JSONConfigTabContent';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import IconButton from '@mui/material/IconButton';
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import StopCircleIcon from '@mui/icons-material/StopCircle';
import Tooltip from '@mui/material/Tooltip';
import ProcessOutputView from './ProcessOutputView';
import LastProcessView from './LastProcessView';

const TabMenuBuild = ({ buildOutputFileContent, isBuildStarted, toggleBuildStart }) => {


    useEffect(() => {

    }, [buildOutputFileContent, isBuildStarted]);

    return (
        <div className='mt-[90px]'>
            {/* Build & Deploy Selection */}
            <div id="build-deploy-section" className='items-center px-5 bg-ghBlack3 p-1.5'>
                {/* Action Settings / Button */}
                <div className='mx-5 flex justify-end items-center'>
                    {/* <div className="flex">
                        <button className='bg-ghBlack4 hover:bg-gray-700 px-2 pt-1 mr-1 items-center'>
                            <MonitorHeartIcon className='mb-1 mr-1'/>
                            <span>Build Console Output</span>
                        </button>
                    </div> */}
                    {isBuildStarted ?
                        <Tooltip title="Stop Build Process" placement="left">
                            <IconButton onClick={() => { toggleBuildStart() }}>
                                <StopCircleIcon />
                            </IconButton>
                        </Tooltip> :
                        <Tooltip title="Start New Build" placement="left">
                            <IconButton onClick={() => { toggleBuildStart() }}>
                                <PlayCircleIcon />
                            </IconButton>
                        </Tooltip>
                    }
                </div>

            </div>

            {isBuildStarted ? <ProcessOutputView processType={"build"} logOutput={buildOutputFileContent} /> : <BuildTabContent />}

            {/* <BuildExecuteButton /> */}
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

        console.log("DEBUG: ", parsedData.config[key]);
        console.log("DEBUG: selectedValue", selectedValue);

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
            <div className='flex grid-cols-12 items-center relative dark:bg-ghBlack2 sticky top-[90px] z-10 h-[40px]'>
                <button onClick={() => handleConfigTabClick('config-tab1')} className={`${activeConfigTab === "config-tab1" ? "bg-kxBlue2" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Packer Config UI
                </button>

                {/* Centered Circle */}
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                    <div className="w-10 h-10 bg-ghBlack4 items-center flex justify-center text-xl">
                        <SettingsEthernetIcon fontSize='inherit' />
                    </div>
                </div>

                <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Packer Config JSON
                </button>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent isBuild={isBuild} handleTabClick={handleTabClick} handleConfigChange={handleConfigChange} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"kx-main-local-profiles.json"} />}
            </div>
        </div>
    );
}

const BuildExecuteButton = () => {
    const navigate = useNavigate();

    const [output, setOutput] = useState('');

    const handleExecuteClick = async () => {
        console.log('KX.AS.Code Image build process started!');
        navigate('/console-output');
    };


    return (
        <div className=''>
            <button onClick={() => { handleExecuteClick() }} className='bg-kxBlue p-3 w-full flex justify-center items-center'>
                <PlayCircleIcon className='mr-1' /> Build KX.AS.Code Image</button>
            <button className='p-3 w-full font-normal hover:text-gray-400 w-auto flex justify-center items-center'>
                <CloudDownloadIcon className='mr-1.5' /> Download Image from Vagrant Cloud</button>
            <div id="output">{output}</div>
        </div>
    )
}


const UIConfigTabContent = ({ activeTab, handleTabClick, handleConfigChange, isBuild }) => (

    isBuild ?
        <div>
            <BuildContent />
            <LastProcessView processType={"build"} />
        </div> : <></>
);

const TabButton = ({ buttonText, tabId }) => {
    return (
        <button
            onClick={() => handleTabClick(tabId)}
            className={` ${activeTab === tabId ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
        >
            {buttonText}
        </button>
    );
}

const BuildContent = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Build Config</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More Details about the Build process here.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="VM Profile"
                        select
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        defaultValue="virtualbox"
                    >
                        <MenuItem value="virtualbox">Virtualbox</MenuItem>
                        <MenuItem value="parallels">Parallels</MenuItem>
                        <MenuItem value="vmware-desktop">VMWare Desktop</MenuItem>
                    </TextField>

                    <TextField
                        label="Node Type"
                        select
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        defaultValue="main"
                        onChange={(e) => { }}
                    >
                        <MenuItem value="main">Main</MenuItem>
                        <MenuItem value="node">Node</MenuItem>
                    </TextField>
                </div>
            </div>
        </div>
    )
}

export default TabMenuBuild;
