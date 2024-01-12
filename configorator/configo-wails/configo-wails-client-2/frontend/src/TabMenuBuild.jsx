import React, { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import FormControlLabel from '@mui/material/FormControlLabel';
import InputAdornment from '@mui/material/InputAdornment';
import Switch from '@mui/material/Switch';
import MenuItem from '@mui/material/MenuItem';
import Slider from '@mui/material/Slider';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';
import configJSON from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configDarwinLinuxMain from './assets/config/build/darwin-linux/kx-main-local-profiles.json';
import configDarwinLinuxNode from './assets/config/build/darwin-linux/kx-node-local-profiles.json';
import { oneDark } from '@codemirror/theme-one-dark';
import { useNavigate } from 'react-router-dom';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import CloudDownloadIcon from '@mui/icons-material/CloudDownload';
import UserTable from './UserTable';
import JSONConfigTabContent from './JSONConfigTabContent';
import GlobalVariablesTable from './GlobalVariablesTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import AddIcon from '@mui/icons-material/Add';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import FilledInput from '@mui/material/FilledInput';
import OutlinedInput from '@mui/material/OutlinedInput';
import InputLabel from '@mui/material/InputLabel';
import FormHelperText from '@mui/material/FormHelperText';
import FormControl from '@mui/material/FormControl';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import IconButton from '@mui/material/IconButton';
import PrecisionManufacturingIcon from '@mui/icons-material/PrecisionManufacturing';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import StopCircleIcon from '@mui/icons-material/StopCircle';
import DoneIcon from '@mui/icons-material/Done';
import Tooltip from '@mui/material/Tooltip';


const TabMenuBuild = () => {
    const [updatedJsonData, setUpdatedJsonData] = useState('');
    const [activeProcessTab, setActiveProcessTab] = useState('build');
    const serializedState = localStorage.getItem('myEditorState');
    const [isBuildStarted, setIsBuildStarted] = useState(false);

    const value = localStorage.getItem('myValue') || '';
    const stateFields = { history: historyField };

    const handleProcessTabClick = (tab) => {
        setActiveProcessTab(tab);
    };

    const toggleBuildStart = () => {
        setIsBuildStarted((prevIsBuildStarted) => !prevIsBuildStarted);
    }

    return (
        <div className='mt-[90px]'>
            {/* Build & Deploy Selection */}
            <div id="build-deploy-section" className='items-center px-5 bg-ghBlack3 py-1.5'>
                {/* Action Settings / Button */}
                <div className='mx-5 flex justify-end'>
                    {isBuildStarted ?
                        <Tooltip title="Stop Build" placement="left">
                            <IconButton onClick={() => { toggleBuildStart() }}>
                                <StopCircleIcon />
                            </IconButton>
                        </Tooltip> :
                        <Tooltip title="Start Build" placement="left">
                            <IconButton onClick={() => { toggleBuildStart() }}>
                                <PlayCircleIcon />
                            </IconButton>
                        </Tooltip>
                    }
                </div>

            </div>


            <BuildTabContent />


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
        ExecuteRealTimeCommand()
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
        </div> :
        <div id='config-ui-container' className=''>

            <div className="flex bg-ghBlack3 text-sm">
                <button
                    onClick={() => handleTabClick('tab1')}
                    className={` ${activeTab === 'tab1' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    Profile
                </button>
                <button
                    onClick={() => handleTabClick('tab2')}
                    className={` ${activeTab === 'tab2' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    Parameters & Mode
                </button>
                <button
                    onClick={() => handleTabClick('tab3')}
                    className={` ${activeTab === 'tab3' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    Resources
                </button>
                <button
                    onClick={() => handleTabClick('tab4')}
                    className={` ${activeTab === 'tab4' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    Storage
                </button>
                <button
                    onClick={() => handleTabClick('tab5')}
                    className={` ${activeTab === 'tab5' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    User Provisioning
                </button>
                <button
                    onClick={() => handleTabClick('tab6')}
                    className={` ${activeTab === 'tab6' ? 'border-kxBlue border-b-3 bg-ghBlack4' : 'broder border-ghBlack3 border-b-3'} p-3 py-1`}
                >
                    Custom Variables
                </button>
            </div>

            <div className="tab-content">
                {activeTab === 'tab1' && <TabContent1 handleConfigChange={handleConfigChange} />}
                {activeTab === 'tab2' && <TabContent2 handleConfigChange={handleConfigChange} />}
                {activeTab === 'tab3' && <TabContent3 handleConfigChange={handleConfigChange} />}
                {activeTab === 'tab4' && <TabContent4 handleConfigChange={handleConfigChange} />}
                {activeTab === 'tab5' && <TabContent5 handleConfigChange={handleConfigChange} />}
                {activeTab === 'tab6' && <TabContent6 handleConfigChange={handleConfigChange} />}
            </div>
        </div>
);

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
