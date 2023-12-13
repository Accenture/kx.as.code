import React, { useState, useEffect } from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';
import configJSON from './assets/profile-config-template.json';
import { oneDark } from '@codemirror/theme-one-dark';
// import { json } from "@codemirror/lang-json";


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
        </div>
    );
};

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
        <div className="flex bg-ghBlack4">
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
                KX Main
            </button>
            <button
                onClick={() => handleTabClick('tab3')}
                className={` ${activeTab === 'tab3' ? 'bg-kxBlue' : ''} p-3 py-1`}
            >
                Storage
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
            <p className='text-sm text-gray-400 text-justify'>Select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, as well as availability of built Vagrant boxes. An attempt is made to automatically select the profile based on discovered pre-requisites.</p>
        </div>

        <div className='px-5 py-3 bg-ghBlack'>
            <TextField
                label="Profiles"
                select
                fullWidth
                variant="outlined"
                size="small"
                margin="normal"
            >
                <MenuItem value="parallels">Parallels</MenuItem>
                <MenuItem value="virtualbox">Virtualbox</MenuItem>
                <MenuItem value="vmware-desktop">VMWare Desktop</MenuItem>
            </TextField>

            <TextField
                label="Start Mode"
                select
                fullWidth
                variant="outlined"
                size="small"
                margin="normal"
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
            >
                <MenuItem value="k8s">K8s</MenuItem>
                <MenuItem value="k3s">K3s</MenuItem>
            </TextField>
        </div>
    </div>
);

const TabContent2 = () => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>KX Main</h2>
            <p className='text-sm text-gray-400 text-justify'></p>
        </div>
    </div>
);

const TabContent3 = () => (
    <div className='text-left'>
    <div className='px-5 py-3'>
        <h2 className='text-3xl font-semibold'>Storage</h2>
        <p className='text-sm text-gray-400 text-justify'></p>
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
