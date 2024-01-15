import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import FormControlLabel from '@mui/material/FormControlLabel';
import InputAdornment from '@mui/material/InputAdornment';
import Switch from '@mui/material/Switch';
import MenuItem from '@mui/material/MenuItem';
import configJSON from './assets/config/config.json';
import usersJSON from './assets/config/users.json';
import customVariablesJSON from './assets/config/customVariables.json';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import UserTable from './UserTable';
import JSONConfigTabContent from './JSONConfigTabContent';
import GlobalVariablesTable from './GlobalVariablesTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import AddIcon from '@mui/icons-material/Add';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import IconButton from '@mui/material/IconButton';
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import StopCircleIcon from '@mui/icons-material/StopCircle';
import Tooltip from '@mui/material/Tooltip';

const TabMenuDeploy = () => {
    const [updatedJsonData, setUpdatedJsonData] = useState('');
    const [activeProcessTab, setActiveProcessTab] = useState('deploy');
    const serializedState = localStorage.getItem('myEditorState');
    const [isDeploymentStarted, setIsDeploymentStarted] = useState(false);

    const value = localStorage.getItem('myValue') || '';

    const handleProcessTabClick = (tab) => {
        setActiveProcessTab(tab);
    };

    const toggleDeploymentStart = () => {
        setIsDeploymentStarted((prevIsDeploymentStarted) => !prevIsDeploymentStarted);
    }
    return (
        <div className='mt-[90px]'>
            {/* Build & Deploy Selection */}
            <div id="build-deploy-section" className='items-center px-5 dark:bg-ghBlack3 bg-gray-400 py-1.5'>
                {/* Action Settings / Button */}
                <div className='mx-5 flex justify-end'>
                    {isDeploymentStarted ?
                        <Tooltip title="Stop Deployment" placement="left">
                            <IconButton onClick={() => { toggleDeploymentStart() }}>
                                <StopCircleIcon />
                            </IconButton>
                        </Tooltip> :
                        <Tooltip title="Start Deployment" placement="left">
                            <IconButton onClick={() => { toggleDeploymentStart() }}>
                                <PlayCircleIcon />
                            </IconButton>
                        </Tooltip>
                    }
                </div>
            </div>
            <DeployTabContent />
            {/* <BuildExecuteButton /> */}
        </div>
    );
};

const DeployTabContent = () => {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };


    const handleUsersChange = (value, key) => {
        let selectedValue;

        if (!isNaN(value)) {
            selectedValue = parseFloat(value);
        } else {
            selectedValue = value;
        }

        let parsedData = { ...usersJSON };

        setNestedValue(parsedData, key, selectedValue)

        const updatedJsonString = JSON.stringify(parsedData, null, 2);

        setJsonData(updatedJsonString);
    }


    const handleConfigChange = (value, key) => {
        let selectedValue;

        if (!isNaN(value)) {
            selectedValue = parseFloat(value);
        } else {
            selectedValue = value;
        }

        let parsedData = { ...configJSON };

        setNestedValue(parsedData, key, selectedValue)

        const updatedJsonString = JSON.stringify(parsedData, null, 2);

        setJsonData(updatedJsonString);
        UpdateJsonFile(updatedJsonString, "profile");
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
            <div className='flex grid-cols-12 items-center relative bg-gray-200 dark:bg-ghBlack2 sticky top-[90px] z-10 h-[40px]'>
                <button onClick={() => handleConfigTabClick('config-tab1')} className={`${activeConfigTab === "config-tab1" ? "bg-kxBlue2 text-white" : ""} dark:text-white text-black h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Profile  Config UI
                </button>

                {/* Centered icon */}
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                    <div className="w-10 h-10 dark:bg-ghBlack4 bg-gray-300 items-center flex justify-center text-xl">
                        <SettingsEthernetIcon fontSize='inherit' />
                    </div>
                </div>

                <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2 text-white" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Profile Config JSON
                </button>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} handleConfigChange={handleConfigChange} handleUsersChange={handleUsersChange} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"profile-config.json"} />}
            </div>
        </div>
    );
}

const UIConfigTabContent = ({ activeTab, handleTabClick, handleConfigChange, handleUsersChange, isBuild }) => (
    <div id='config-ui-container' className=''>
        <div className="flex dark:bg-ghBlack3 bg-gray-300 text-sm text-black dark:text-white">
            <button
                onClick={() => handleTabClick('tab1')}
                className={` ${activeTab === 'tab1' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Profile
            </button>
            <button
                onClick={() => handleTabClick('tab2')}
                className={` ${activeTab === 'tab2' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Parameters & Mode
            </button>
            <button
                onClick={() => handleTabClick('tab3')}
                className={` ${activeTab === 'tab3' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Resources
            </button>
            <button
                onClick={() => handleTabClick('tab4')}
                className={` ${activeTab === 'tab4' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Storage
            </button>
            <button
                onClick={() => handleTabClick('tab5')}
                className={` ${activeTab === 'tab5' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                User Provisioning
            </button>
            <button
                onClick={() => handleTabClick('tab6')}
                className={` ${activeTab === 'tab6' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Custom Variables
            </button>
            <button
                onClick={() => handleTabClick('tab7')}
                className={` ${activeTab === 'tab7' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Notification
            </button>
            <button
                onClick={() => handleTabClick('tab8')}
                className={` ${activeTab === 'tab8' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Docker
            </button>
            <button
                onClick={() => handleTabClick('tab9')}
                className={` ${activeTab === 'tab9' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Proxy
            </button>
        </div>

        <div className="tab-content dark:text-white text-black">
            {activeTab === 'tab1' && <TabContent1 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab2' && <TabContent2 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab3' && <TabContent3 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab4' && <TabContent4 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab5' && <TabContent5 handleUsersChange={handleUsersChange} />}
            {activeTab === 'tab6' && <TabContent6 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab7' && <TabContent7 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab8' && <TabContent8 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab9' && <TabContent9 handleConfigChange={handleConfigChange} />}

        </div>
    </div>
);


const TabContent1 = ({ handleConfigChange }) => {

    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Profile</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>Select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, as well as availability of built Vagrant boxes.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
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
                        onChange={(e) => { handleConfigChange(e.target.value, "startupMode") }}
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
                        defaultValue={configJSON.config["kubeOrchestrator"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.kubeOrchestrator") }}
                    >
                        <MenuItem value="k8s">K8s</MenuItem>
                        <MenuItem value="k3s">K3s</MenuItem>
                    </TextField>
                </div>
            </div>
        </div>
    )
};

const TabContent2 = ({ handleConfigChange }) => {
    const [showPassword, setShowPassword] = React.useState(false);

    const handleClickShowPassword = () => setShowPassword((show) => !show);

    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };

    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>General Parameters & Mode Selection</h2>
                <p className='text-sm dark:text-gray-400 text-justify'> Set the parameters to define the internal DNS of KX.AS.CODE.
                    {/* Set the parameters to define the internal DNS of KX.AS.CODE. Each new service that is provisioned in KX.AS.CODE will have the fully qualified domain name (FQDN) of &lt;service_name&gt;, &lt;team_name&gt;. &lt;base_domain&gt;. The username and password fields determine the base admin user password. It is possible to add additional users. In the last section, you determine if running in standalone or cluster mode. Standalone mode starts up one main node only. This is recommended for any physical environment with less than 16G ram. If enable worker nodes, then you can also choose to have workloads running on both main and worker nodes, or only on worker nodes. */}
                </p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <h2 className='text-xl font-semibold dark:text-gray-400'>General Profile Parameters</h2>

                    <TextField
                        label="Base Domain"
                        fullWidth
                        size="small"
                        margin="normal"
                        value={configJSON.config["baseDomain"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.baseDomain") }}
                    >
                    </TextField>
                    <TextField
                        label="Team Name"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        defaultValue={configJSON.config["environmentPrefix"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.environmentPrefix") }}
                    >
                    </TextField>

                    <TextField
                        label="Username"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config["baseUser"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.baseUser") }}
                    >
                    </TextField>

                    <TextField
                        fullWidth
                        type={showPassword ? 'text' : 'password'}
                        margin="normal"
                        size='small'
                        InputProps={{
                            endAdornment: (
                                <InputAdornment position="end">
                                    <IconButton
                                        aria-label="toggle password visibility"
                                        onClick={handleClickShowPassword}
                                        onMouseDown={handleMouseDownPassword}
                                    >
                                        {showPassword ? <Visibility /> : <VisibilityOff />}
                                    </IconButton>
                                </InputAdornment>
                            )
                        }}
                        label="Password"
                        value={configJSON.config["basePassword"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.basePassword") }}
                    />

                    <h2 className='text-xl font-semibold dark:text-gray-400'>Additional Toggles</h2>
                    <div className='px-5 text-sm'>
                        <FormControlLabel
                            className='my-1'
                            control={<Switch size="small"
                                defaultChecked={configJSON.config["standaloneMode"]}
                                onChange={(e) => { handleConfigChange(e.target.checked, "standaloneMode") }}
                            />}
                            label={<span style={{ fontSize: '16px', marginLeft: "20px" }}>Enable Standalone Mode</span>}
                        />
                        <FormControlLabel
                            className='my-1'
                            control={<Switch size="small"
                                defaultChecked={configJSON.config["allowWorkloadsOnMaster"]}
                                onChange={(e) => { handleConfigChange(e.target.checked, "allowWorkloadsOnMaster") }}
                            />}
                            label={<span style={{ fontSize: '16px', marginLeft: "20px" }}>Allow Workloads on Kubernetes Master</span>}
                        />
                        <FormControlLabel
                            className='my-1'
                            control={<Switch size="small"
                                defaultChecked={configJSON.config["disableLinuxDesktop"]}
                                onChange={(e) => { handleConfigChange(e.target.checked, "disableLinuxDesktop") }}
                            />}
                            label={<span style={{ fontSize: '16px', marginLeft: "20px" }}>Disable Linux Desktop</span>}
                        />
                    </div>
                </div>
            </div>
        </div>)
};

const TabContent3 = ({ handleConfigChange }) => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>VM Properties</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>Define how many physical resources you wish to allocate to the KX.AS.CODE virtual machines.</p>
        </div>
        <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold dark:text-gray-400'>KX-Main Parameters</h2>
                {/* <p className='text-sm text-gray-400'>KX-Main nodes provide two core functions - Kubernetes master services as well as the desktop environment for easy access to deployed tools and documentation. Only the first KX-Main node hosts both the desktop environment, and the Kubernetes Master services. Subsequent KX-Main nodes host the Kubernetes Master services only.</p> */}
                <TextField
                    label="KX Main Nodes"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    InputProps={{ inputProps: { min: 1, max: 10 } }}
                    defaultValue={configJSON.config.vm_properties["main_node_count"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_node_count") }}
                >
                </TextField>

                <TextField
                    label="KX Main Cores"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    InputProps={{ inputProps: { min: 1, max: 30 } }}
                    defaultValue={configJSON.config.vm_properties["main_admin_node_cpu_cores"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_admin_node_cpu_cores") }}
                >
                </TextField>

                <TextField
                    label="KX Main RAM"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.vm_properties["main_admin_node_memory"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_admin_node_memory") }}
                    InputProps={{
                        startAdornment: <InputAdornment position="start">MB</InputAdornment>,
                        inputProps: { min: 0, max: 30000 }
                    }}
                >
                </TextField>

                <h2 className='text-xl font-semibold dark:text-gray-400'>KX-Worker Parameters</h2>
                <TextField
                    label="KX Node Nodes"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    InputProps={{ inputProps: { min: 0, max: 10 } }}
                    defaultValue={configJSON.config.vm_properties["worker_node_count"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_count") }}
                >
                </TextField>

                <TextField
                    label="KX Node Cores"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    InputProps={{ inputProps: { min: 1, max: 30 } }}
                    defaultValue={configJSON.config.vm_properties["worker_node_cpu_cores"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_cpu_cores") }}
                >
                </TextField>

                <TextField
                    label="KX Node RAM"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.vm_properties["worker_node_memory"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_memory") }}
                    InputProps={{
                        startAdornment: <InputAdornment position="start">MB</InputAdornment>,
                        inputProps: { min: 0, max: 30000 }
                    }}
                >
                </TextField>

            </div>
        </div>
    </div>
);

const TabContent4 = ({ handleConfigChange }) => (
    <div className='text-left'>
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold'>Storage Parameters</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>Define the amount of storage allocated to KX.AS.CODE. There are two types - (1) fast local, but not portable storage, eg. tied to a host, and (2) slower, but portable network storage.</p>

        </div>
        <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold dark:text-gray-400'>Local Volumes</h2>
                {/* <p className='text-sm text-gray-400 text-justify'>Provision network storage with the set amount. The storage volume will be provisioned as a dedicated virtual drive in the virtual machine.</p> */}
                <TextField
                    InputProps={{
                        startAdornment: <InputAdornment position="start">GB</InputAdornment>,
                        inputProps: { min: 0, max: 1000 }
                    }}
                    label="Network Storage"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config["glusterFsDiskSize"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.glusterFsDiskSize") }}
                >
                </TextField>

                <h2 className='text-xl font-semibold dark:text-gray-400'>Local Storage Volumes</h2>
                {/* <p className='text-sm text-gray-400 text-justify'>Define the number of volumes of a given size will be "pre-provisioned" for consumption by Kubernetes workloads.</p> */}
                <TextField
                    InputProps={{
                        inputProps: { min: 0, max: 50 }
                    }}
                    label="1 GB"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.local_volumes["one_gb"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.local_volumes.one_gb") }}
                />
                <TextField
                    InputProps={{
                        inputProps: { min: 0, max: 50 }
                    }}
                    label="5 GB"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.local_volumes["five_gb"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.local_volumes.five_gb") }}
                />
                <TextField
                    InputProps={{
                        inputProps: { min: 0, max: 50 }
                    }}
                    label="10 GB"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.local_volumes["ten_gb"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.local_volumes.ten_gb") }}
                />
                <TextField
                    InputProps={{
                        inputProps: { min: 0, max: 50 }
                    }}
                    label="30 GB"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.local_volumes["thirty_gb"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.local_volumes.thirty_gb") }}
                />
                <TextField
                    InputProps={{
                        inputProps: { min: 0, max: 50 }
                    }}
                    label="50 GB"
                    type='number'
                    fullWidth
                    size="small"
                    margin="normal"
                    defaultValue={configJSON.config.local_volumes["fifty_gb"]}
                    onChange={(e) => { handleConfigChange(e.target.value, "config.local_volumes.fifty_gb") }}
                />

            </div>
        </div>
    </div>
);

const TabContent5 = ({ handleUsersChange }) => {

    const [rows, setRows] = React.useState([]);

    const [firstName, setFirstName] = React.useState("");
    const [surname, setSurname] = React.useState("");
    const [email, setEmail] = React.useState("");
    const [layout, setLayout] = React.useState("");
    const [role, setRole] = React.useState("");

    const [firstNameError, setFirstNameError] = React.useState("");
    const [surnameError, setSurnameError] = React.useState("");
    const [emailError, setEmailError] = React.useState("");
    const [layoutError, setLayoutError] = React.useState("");
    const [roleError, setRoleError] = React.useState("");

    const [usersData, setUsersData] = useState(usersJSON);

    const removeUser = (userIdToRemove) => {
        setUsersData((prevData) => ({
            ...prevData,
            config: {
                ...prevData.config,
                additionalUsers: prevData.config.additionalUsers.filter(
                    (user) => user.user_id !== userIdToRemove
                ),
            },
        }));
    };

    function createData(id, firstName, surname, email, layout, role) {
        return {
            id,
            firstName,
            surname,
            email,
            layout,
            role
        };
    }

    const handleAddUserClick = () => {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!firstName.trim()) {
            setFirstNameError('First name is required');
        } else {
            setFirstNameError('');
        }

        if (!surname.trim()) {
            setSurnameError('Surname is required');
        } else {
            setSurnameError('');
        }

        if (!email.trim()) {
            setEmailError('Email is required');
        } else if (!emailRegex.test(email.trim())) {
            setEmailError('Invalid email format');
        } else {
            setEmailError('');
        }

        if (!layout.trim()) {
            setLayoutError('Layout is required');
        } else {
            setLayoutError('');
        }

        if (!role.trim()) {
            setRoleError('Role is required');
        } else {
            setRoleError('');
        }

        if (!firstName.trim() || !surname.trim() || !email.trim() || !layout.trim() || !role.trim()) {
            return;
        }

        handleAddRow(firstName, surname, email, layout, role);
        setFirstName("")
        setSurname("");
        setEmail("");
        setLayout("");
        setRole("");
    }

    const handleAddRow = (firstName, surname, email, layout, role) => {
        const newId = rows.length + 1;
        const newRow = createData(newId, firstName, surname, email, layout, role);
        setRows([...rows, newRow]);

        const newAdditionalUser = {
            "user_id": getNextUserId(usersData),
            "firstname": firstName,
            "surname": surname,
            "email": email,
            "keyboard_language": layout,
            "role": role
        }

        addNewAdditionalUser(newAdditionalUser, "users");
    };

    const getNextUserId = (data) => {
        const additionalUsers = data?.config?.additionalUsers || [];
        const maxUserId = additionalUsers.reduce((max, user) => (user.user_id > max ? user.user_id : max), -1);
        return maxUserId + 1;
    };

    const addNewAdditionalUser = (user) => {
        const updatedUsers = {
            ...usersData,
            config: {
                ...usersData.config,
                additionalUsers: [...usersData.config.additionalUsers, user]
            }
        };

        setUsersData(updatedUsers);
        const updatedUsersJsonString = JSON.stringify(updatedUsers, null, 2);
        UpdateJsonFile(updatedUsersJsonString, "users")
    }

    useEffect(() => {
    }, [firstName, surname, email, layout, role, usersData]);


    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>User Provisioning</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>Define additional users to provision in the KX.AS.CODE environment. This is optional. If you do not specify additional users, then only the base user will be available for logging into the desktop and all provisioned tools.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 gap-2'>
                <h2 className='text-md font-semibold dark:text-gray-400'>Create additional user</h2>
                <form>
                    <div className='flex gap-2'>
                        <TextField
                            required
                            InputProps={{
                            }}
                            label="First Name"
                            type='text'
                            fullWidth
                            size="small"
                            margin="normal"
                            value={firstName}
                            onChange={(e) => { setFirstName(e.target.value); setFirstNameError(''); }}
                            error={Boolean(firstNameError)}
                            helperText={firstNameError}
                        />
                        <TextField
                            required
                            InputProps={{
                            }}
                            label="Surname"
                            type='text'
                            fullWidth
                            size="small"
                            margin="normal"
                            value={surname}
                            onChange={(e) => { setSurname(e.target.value); setSurnameError(''); }}
                            error={Boolean(surnameError)}
                            helperText={surnameError}
                        />
                        <TextField
                            required
                            InputProps={{
                            }}
                            label="E-Mail"
                            type='email'
                            fullWidth
                            size="small"
                            margin="normal"
                            value={email}
                            onChange={(e) => { setEmail(e.target.value); setEmailError(''); }}
                            error={Boolean(emailError)}
                            helperText={emailError}
                        />
                    </div>

                    <div className='flex gap-2'>
                        <TextField
                            required
                            label="Keyboard Layout"
                            select
                            fullWidth
                            variant="outlined"
                            size="small"
                            margin="normal"
                            value={layout}
                            onChange={(e) => { setLayout(e.target.value); setLayoutError(''); }}
                            error={Boolean(layoutError)}
                            helperText={layoutError}
                        >
                            <MenuItem value="german">German</MenuItem>
                            <MenuItem value="en-us">English (US)</MenuItem>
                            <MenuItem value="en-gb">English (GB)</MenuItem>
                            <MenuItem value="french">French</MenuItem>
                            <MenuItem value="spanish">Spanish</MenuItem>

                        </TextField>

                        <TextField
                            required
                            label="Role"
                            select
                            fullWidth
                            variant="outlined"
                            size="small"
                            margin="normal"
                            value={role}
                            onChange={(e) => { setRole(e.target.value); setRoleError(''); }}
                            error={Boolean(roleError)}
                            helperText={roleError}
                        >
                            <MenuItem value="admin">Admin</MenuItem>
                            <MenuItem value="normal">Normal</MenuItem>

                        </TextField>

                        <button type="submit"
                            className='border border-white mt-4 h-10 px-3 items-center flex justify-center'
                            onClick={(e) => { e.preventDefault(); handleAddUserClick() }}>
                            <PersonAddAltIcon />
                        </button>

                    </div>
                </form>

            </div>
            <UserTable rows={usersData.config.additionalUsers} />
        </div>)
};

const TabContent6 = ({ handleConfigChange }) => {

    const [rows, setRows] = React.useState([]);
    const [key, setKey] = React.useState("");
    const [value, setValue] = React.useState("");
    const [keyError, setKeyError] = useState('');
    const [valueError, setValueError] = useState('');
    const [customVariablesData, setCustomVariablesData] = useState(customVariablesJSON);


    function createData(id, key, value) {
        return {
            id,
            key,
            value
        };
    }

    const handleAddKeyValuePairClick = () => {
        // Check if either key or value is empty
        if (!key.trim()) {
            console.log("key: ", key);
            setKeyError('Key is required');
        } else {
            setKeyError('');
        }

        if (!value.trim()) {
            console.log("value: ", value);
            setValueError('Value is required');
        } else {
            setValueError('');
        }

        // If either key or value is empty, return without adding the key-value pair
        if (!key.trim() || !value.trim()) {
            return;
        }

        // Add new key-value pair
        handleAddRow(key, value);
        setKey("");
        setValue("");
    };

    const handleAddRow = (key, value) => {
        const newId = getNextVariableId(customVariablesData);
        const newRow = createData(newId, key, value);
        setRows([...rows, newRow]);

        const newCustomVariable = {
            "variable_id": getNextVariableId(customVariablesData),
            "key": key,
            "value": value,
        }

        addNewCustomVariable(newCustomVariable)
    };

    const removeCustomVariable = (customVariableIdArrayToRemove) => {
        console.log("id param List: ", customVariableIdArrayToRemove);
    
        setCustomVariablesData((prevData) => {
            const updatedCustomVariables = {
                ...prevData,
                config: {
                    ...prevData.config,
                    customVariables: prevData.config.customVariables.filter(
                        (customVariable) => !customVariableIdArrayToRemove.includes(customVariable.variable_id)
                    ),
                },
            };
            const updatedCustomVariablesJsonString = JSON.stringify(updatedCustomVariables, null, 2);
            console.log("updatedCustomVariablesJsonString: ", updatedCustomVariablesJsonString);
            UpdateJsonFile(updatedCustomVariablesJsonString, "customVariables");
    
            return updatedCustomVariables;
        });
    };

    const getNextVariableId = (data) => {
        const customVariables = data?.config?.customVariables || [];
        const maxCustomVariableId = customVariables.reduce((max, customVariable) => (customVariable.variable_id > max ? customVariable.variable_id : max), -1);
        return maxCustomVariableId + 1;
    };

    const addNewCustomVariable = (customVariable) => {
        const updatedCustomVariables = {
            ...customVariablesData,
            config: {
                ...customVariablesData.config,
                customVariables: [...customVariablesData.config.customVariables, customVariable]
            }
        };

        setCustomVariablesData(updatedCustomVariables);
        const updatedCustomVariablesJsonString = JSON.stringify(updatedCustomVariables, null, 2);
        UpdateJsonFile(updatedCustomVariablesJsonString, "customVariables")

    }

    useEffect(() => {
    }, [key, value, customVariablesData]);


    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Custom Global Variables</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>Set key/value pairs that can be used by solutions when they are being installed.</p>
            </div>

            <form>
                <div className='dark:bg-ghBlack2 bg-gray-300 px-5 py-5'>
                    <h2 className='text-md font-semibold dark:text-gray-400'>Create global variable</h2>
                    <div className='flex items-center'>
                        <TextField
                            required
                            InputProps={{
                            }}
                            label="Key"
                            type='text'
                            fullWidth
                            size="small"
                            margin="normal"
                            value={key}
                            onChange={(e) => { setKey(e.target.value); setKeyError(''); }}
                            error={Boolean(keyError)}
                            helperText={keyError}
                        />
                        <TextField
                            required
                            InputProps={{
                            }}
                            label="Value"
                            type='text'
                            fullWidth
                            size="small"
                            margin="normal"
                            value={value}
                            onChange={(e) => { setValue(e.target.value); setValueError(''); }}
                            error={Boolean(valueError)}
                            helperText={valueError}
                        />
                        <button className='border border-white mt-2 h-10 px-3 ml-2'
                            onClick={(e) => { e.preventDefault(); handleAddKeyValuePairClick(); }}
                            type="submit">
                            {/* <AddCircleOutlineIcon fontSize='medium' /> */}
                            <AddIcon />
                        </button>
                    </div>
                </div>

            </form>

            <div className='flex'>
                <GlobalVariablesTable rows={customVariablesData.config.customVariables} removeCustomVariable={removeCustomVariable} />
            </div>
        </div>)
}

const TabContent7 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Notification Settings</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="E-Mail"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.notification_endpoints["email_address"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.email_address") }}
                    >
                    </TextField>

                    <TextField
                        label="MS Teams Webhook"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.notification_endpoints["ms_teams_webhook"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.ms_teams_webhook") }}
                    >
                    </TextField>

                    <TextField
                        label="Slack Webhook"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.notification_endpoints["slack_webhook"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.slack_webhook") }}
                    >
                    </TextField>

                </div>
            </div>


        </div>)
}

const TabContent8 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Docker</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="Dockerhub E-Mail"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.docker["dockerhub_email"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_email") }}
                    >
                    </TextField>

                    <TextField
                        label="Dockerhub Username"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.docker["dockerhub_username"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_username") }}
                    >
                    </TextField>

                    <TextField
                        label="Dockerhub Password"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.docker["dockerhub_password"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_password") }}
                    >
                    </TextField>

                </div>
            </div>

        </div>)
}

const TabContent9 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Proxy Settings</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="HTTP Proxy"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.proxy_settings["http_proxy"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.http_proxy") }}
                    >
                    </TextField>

                    <TextField
                        label="HTTS Proxy"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.proxy_settings["https_proxy"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.https_proxy") }}
                    >
                    </TextField>

                    <TextField
                        label="No Proxy"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={configJSON.config.proxy_settings["no_proxy"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.no_proxy") }}
                    >
                    </TextField>
                </div>
            </div>
        </div>)
}


export default TabMenuDeploy;
