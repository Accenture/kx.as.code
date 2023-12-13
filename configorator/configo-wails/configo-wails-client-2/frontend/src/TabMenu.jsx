import React, { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import FormControlLabel from '@mui/material/FormControlLabel';
import Switch from '@mui/material/Switch';
import MenuItem from '@mui/material/MenuItem';
import Slider from '@mui/material/Slider';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';
import configJSON from './assets/profile-config-template.json';
import { oneDark } from '@codemirror/theme-one-dark';
import { useNavigate } from 'react-router-dom';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import CloudDownloadIcon from '@mui/icons-material/CloudDownload';


const TabMenu = () => {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');

    const serializedState = localStorage.getItem('myEditorState');
    const value = localStorage.getItem('myValue') || '';
    const stateFields = { history: historyField };

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    const formatJSONData = () => {
        const jsonString = JSON.stringify(configJSON, null, 2);
        setJsonData(jsonString);
    }

    useEffect(() => {
        formatJSONData();
    }, [activeConfigTab]);

    return (
        <div className=''>
            <div className='flex grid-cols-12 items-center'>
                <button onClick={() => handleConfigTabClick('config-tab1')} className={`${activeConfigTab === "config-tab1" ? "bg-kxBlue2" : ""} flex col-span-6 w-full text-center justify-center py-2`}>Config UI</button>
                <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2" : ""} flex col-span-6 w-full text-center justify-center py-2`}>Config JSON</button>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} />}
            </div>
            <BuildExecuteButton />
        </div>
    );
};

const BuildExecuteButton = () => {
    const navigate = useNavigate();

    const handleBuildClick = () => {
        console.log('Build KX.AS.COde Image clicked!');
        navigate('/console-output');
    };

    return (
        <div>
            <button onClick={() => { handleBuildClick() }} className='bg-kxBlue p-3 w-full flex justify-center items-center'>
                <PlayCircleIcon className='mr-1' /> Build KX.AS.Code Image</button>
            <button className='p-1 w-full font-normal hover:text-gray-400 px-3 my-2 w-auto flex justify-center items-center'>
                <CloudDownloadIcon className='mr-1.5' /> Download Image from Vagrant Cloud</button>
        </div>
    )
}

const JSONConfigTabContent = (props) => {
    const serializedState = localStorage.getItem('myEditorState');
    const value = localStorage.getItem('myValue') || '';
    const stateFields = { history: historyField };

    return (
        <div className='text-left text-black'>
            <CodeMirror
                value={props.jsonData}
                options={{
                    mode: 'json',
                    theme: 'oneDark',
                    lineNumbers: true,
                }}
                onChange={(value, viewUpdate) => {

                }}
            />
        </div>
    );
}

const UIConfigTabContent = ({ activeTab, handleTabClick }) => (
    <div id='config-ui-container' className=''>
        <div className="flex bg-ghBlack4 text-sm">
            <button
                onClick={() => handleTabClick('tab1')}
                className={` ${activeTab === 'tab1' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                Profile
            </button>
            <button
                onClick={() => handleTabClick('tab2')}
                className={` ${activeTab === 'tab2' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                Parameters & Mode
            </button>
            <button
                onClick={() => handleTabClick('tab3')}
                className={` ${activeTab === 'tab3' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                Resources
            </button>
            <button
                onClick={() => handleTabClick('tab4')}
                className={` ${activeTab === 'tab4' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                Template
            </button>
            <button
                onClick={() => handleTabClick('tab5')}
                className={` ${activeTab === 'tab5' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                User Provisioning
            </button>
        </div>

        <div className="tab-content">
            {activeTab === 'tab1' && <TabContent1 />}
            {activeTab === 'tab2' && <TabContent2 />}
            {activeTab === 'tab3' && <TabContent3 />}
            {activeTab === 'tab4' && <TabContent4 />}
            {activeTab === 'tab5' && <TabContent5 />}
        </div>
    </div>
);

const TabContent1 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>Profile</h2>
            <p className='text-sm text-gray-400 text-justify'>Select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, as well as availability of built Vagrant boxes.</p>
        </div>
        <div className='px-5 py-3 bg-ghBlack grid grid-cols-12'>
            <div className='col-span-6'>
                <TextField
                    label="Profiles"
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
                    label="Start Mode"
                    select
                    fullWidth
                    variant="outlined"
                    size="small"
                    margin="normal"
                    defaultValue="normal"
                >
                    <MenuItem value="normal">Normal</MenuItem>
                    <MenuItem value="lite">Lite</MenuItem>
                    <MenuItem value="minimal">Minimal</MenuItem>
                </TextField>

                <TextField
                    label="Orchestrator"
                    select
                    fullWidth
                    variant="outlined"
                    size="small"
                    margin="normal"
                    defaultValue="k3s"
                >
                    <MenuItem value="k8s">K8s</MenuItem>
                    <MenuItem value="k3s">K3s</MenuItem>
                </TextField>
            </div>
        </div>
    </div>
);

const TabContent2 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>General Parameters & Mode Selection</h2>
            <p className='text-sm text-gray-400 text-justify'> Set the parameters to define the internal DNS of KX.AS.CODE.
                {/* Set the parameters to define the internal DNS of KX.AS.CODE. Each new service that is provisioned in KX.AS.CODE will have the fully qualified domain name (FQDN) of &lt;service_name&gt;, &lt;team_name&gt;. &lt;base_domain&gt;. The username and password fields determine the base admin user password. It is possible to add additional users. In the last section, you determine if running in standalone or cluster mode. Standalone mode starts up one main node only. This is recommended for any physical environment with less than 16G ram. If enable worker nodes, then you can also choose to have workloads running on both main and worker nodes, or only on worker nodes. */}
            </p>
        </div>
        <div className='px-5 py-3 bg-ghBlack grid grid-cols-12'>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold text-gray-400'>General Profile Parameters</h2>

                <TextField
                    label="Base Domain"
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue="kx-as-code.local"
                >
                </TextField>
                <TextField
                    label="Team Name"
                    fullWidth
                    variant="outlined"
                    size="small"
                    margin="normal"
                    defaultValue='demo1'
                >
                </TextField>

                <TextField
                    label="Username"
                    fullWidth
                    variant="outlined"
                    size="small"
                    margin="normal"
                    defaultValue='kx.hero'
                >
                </TextField>
                <TextField
                    label="Password"
                    fullWidth
                    variant="outlined"
                    size="small"
                    margin="normal"
                    type='password'
                    defaultValue='L3arnandshare'
                >
                </TextField>

                <h2 className='text-xl font-semibold text-gray-400'>Additional Toggles</h2>
                <div className='px-1'>
                    <FormControlLabel control={<Switch size="small" defaultChecked />} label="Enable Standalone Mode" />
                    <FormControlLabel control={<Switch size="small" />} label="Allow Workloads on Kubernetes Master" />
                    <FormControlLabel control={<Switch size="small" />} label="Disable Linux Desktop" />
                </div>
            </div>
        </div>
    </div>
);

const TabContent3 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>Resources</h2>
            <p className='text-sm text-gray-400 text-justify'>Define how many physical resources you wish to allocate to the KX.AS.CODE virtual machines.</p>
        </div>
        <div className='px-5 py-3 bg-ghBlack grid grid-cols-12'>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold text-gray-400'>KX-Main Parameters</h2>
                {/* <p className='text-sm text-gray-400'>KX-Main nodes provide two core functions - Kubernetes master services as well as the desktop environment for easy access to deployed tools and documentation. Only the first KX-Main node hosts both the desktop environment, and the Kubernetes Master services. Subsequent KX-Main nodes host the Kubernetes Master services only.</p> */}
                <TextField
                    label="KX Main Nodes"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={1}
                    InputProps={{ inputProps: { min: 1, max: 10 } }}
                >
                </TextField>

                <TextField
                    label="KX Main Cores"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={8}
                    InputProps={{ inputProps: { min: 1, max: 30 } }}
                >
                </TextField>

                <TextField
                    label="KX Main RAM"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={19}
                    InputProps={{ inputProps: { min: 1, max: 50 } }}
                >
                </TextField>

            </div>
        </div>
    </div>
);

const TabContent4 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>Template</h2>
            <p className='text-sm text-gray-400 text-justify'></p>
        </div>
    </div>
);

const TabContent5 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>User Provisioning</h2>
            <p className='text-sm text-gray-400 text-justify'></p>
        </div>
    </div>
);

export default TabMenu;
