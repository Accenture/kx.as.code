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
import { UpdateJsonFile, IsVirtualizationToolInstalled } from "../wailsjs/go/main/App";
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import IconButton from '@mui/material/IconButton';
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import StopCircleIcon from '@mui/icons-material/StopCircle';
import Tooltip from '@mui/material/Tooltip';
import Checkbox from '@mui/material/Checkbox';
import ProcessOutputView from './ProcessOutputView';
import applicationGroupJson from './assets/templates/applicationGroups.json';
import { Button } from '@mui/material';
import Remove from '@mui/icons-material/Remove';
import ClearIcon from '@mui/icons-material/Clear';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import InputField from './InputField';
import { RocketLaunch } from '@mui/icons-material';
import { CircularProgressbar } from './CircularProgressBar';


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
        <div className=''>
            {isDeploymentStarted ? <ProcessOutputView processType={"deploy"} /> : <DeployTabContent />}
        </div>
    );
};

export default TabMenuDeploy;

const DeployTabContent = () => {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigChange = (value, key) => {
        console.log("value: ", value);
        console.log("key: ", key);

        let selectedValue;

        if (typeof value === 'boolean' || typeof value === 'number') {
            selectedValue = value;
        } else if (typeof value === 'string') {
            selectedValue = value.trim();
        } else {
            console.error("Invalid data type for value parameter");
            return;
        }

        let parsedData = { ...configJSON };

        setNestedValue(parsedData, key, selectedValue);

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
            <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 p-1'>
                <div className='col-span-9'>
                    <ConfigSectionHeader sectionTitle={"Deployment Configuration"} SectionDescription={"More Details about the Build process here."} />
                </div>
                <div className='col-span-3 pr-10 mx-3'>
                    <div className="relative w-full h-[40px] p-1 bg-ghBlack2 rounded-md">
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
                                } py-1 text-white bg-ghBlack4 text-sm flex items-center justify-center w-1/2 rounded transition-all duration-150 ease-linear top-[5px] absolute`}
                        >
                            {activeConfigTab === 'config-tab1'
                                ? "Config UI"
                                : "JSON"}
                        </span>
                    </div>
                </div>
            </div>

            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} handleConfigChange={handleConfigChange} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"profile-config.json"} />}
            </div>
            <div className='bg-ghBlack2 h-1'></div>
            {/* Review & Launch */}
            <div className='dark:bg-ghBlack2 p-2 pb-5'>
                <div className='flex justify-center text-gray-600 font-semibold mb-3'>Review & Launch Deployment</div>
                <div className='flex justify-center space-x-5 text-sm text-gray-400'>

                    <div className='flex items-center space-x-2'>

                        <div className='parent flex flex-col items-center'>
                            <div className='text-gray-400 text-left mb-2'>
                                <div className='font-semibold text-base'>Processor</div>
                                <div className='text-sm'>8/16 Cores</div>
                            </div>
                            <CircularProgressbar percentage={50} />
                        </div>

                        <div className='parent flex flex-col items-center'>
                            <div className='text-gray-400 text-left mb-2'>
                                <div className='font-semibold text-base'>Memory</div>
                                <div className='text-sm'>19/31</div>
                            </div>
                            <CircularProgressbar percentage={59} />
                        </div>

                        <div className='parent flex flex-col items-center'>
                            <div className='text-gray-400 text-left mb-2'>
                                <div className='font-semibold text-base'>Disk</div>
                                <div className='text-sm'>400/288</div>
                            </div>
                            <CircularProgressbar percentage={138} />
                        </div>


                    </div>

                </div>
                <div className='mt-5'>
                    <button className="p-2 px-4 bg-ghBlack4 text-white rounded-sm text-sm items-center space-x-1">
                        <PlayCircleIcon fontSize='small' />
                        <span>
                            Launch Deployment
                        </span>
                    </button>
                </div>
            </div>
        </div>
    );
}

const UIConfigTabContent = ({ activeTab, handleTabClick, handleConfigChange, isBuild }) => (
    <div id='config-ui-container' className=''>
        <div className="flex dark:bg-ghBlack3 bg-gray-300 text-sm text-black dark:text-white">
            <TabButton buttonText={"Profile"} tabId={"tab1"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Parameters & Mode"} tabId={"tab2"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Resources"} tabId={"tab3"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Storage"} tabId={"tab4"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Notification"} tabId={"tab5"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Docker"} tabId={"tab6"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Proxy"} tabId={"tab7"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"App Groups"} tabId={"tab8"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"User Groups"} tabId={"tab9"} activeTab={activeTab} handleTabClick={handleTabClick} />
            <TabButton buttonText={"Variable Groups"} tabId={"tab10"} activeTab={activeTab} handleTabClick={handleTabClick} />
        </div>

        <div className="tab-content dark:text-white text-black">
            {activeTab === 'tab1' && <TabContent1 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab2' && <TabContent2 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab3' && <TabContent3 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab4' && <TabContent4 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab5' && <TabContent5 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab6' && <TabContent6 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab7' && <TabContent7 handleConfigChange={handleConfigChange} />}
            {activeTab === 'tab8' && <TabContent8 handleConfigChange={handleConfigChange} />}

        </div>
    </div>
);

const TabButton = ({ buttonText, tabId, activeTab, handleTabClick }) => {
    return (
        <button
            onClick={() => handleTabClick(tabId)}
            className={` ${activeTab === tabId ? 'border-kxBlue border-b-3 bg-ghBlack4 text-white' : 'broder border-ghBlack3 border-b-3'} px-2 py-0.5 text-gray-400 hover:text-white`}
        >
            {buttonText}
        </button>
    );
}

const TabContent1 = ({ handleConfigChange }) => {
    const [installationStatus, setInstallationStatus] = useState({
        virtualbox: null,
        parallels: null,
        'vmware-desktop': null,
    });

    const [selectedVM, setSelectedVM] = useState("virtualbox");

    const getInstallationMark = (toolName) => (
        <div className='flex items-center mt-3.5 ml-2 text-sm capitalize bg-ghBlack4 p-2 rounded'>
            {
                installationStatus[toolName] !== null ? (
                    installationStatus[toolName] ? (
                        <span className='text-green-500 flex items-center px-1'>
                            <CheckCircleIcon fontSize='small' />
                            <span className='ml-1'>{toolName} installed.</span>
                        </span>
                    ) : (
                        <span className='text-red-500 flex items-center'>
                            <ErrorIcon fontSize='small' />
                            <span className='ml-1'>{toolName} not installed.</span>
                            {/* <button className='ml-2 p-1 px-3 bg-kxBlue rounded text-white font-semibold text-xs'>Install</button> */}
                        </span>
                    )) : (null)
            }
        </div>
    );

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

    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Profile</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>Select the profile. A check is made on the system to see if the necessary virtualization software and associated Vagrant plugins are installed, as well as availability of built Vagrant boxes.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack3 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="Profiles"
                        select
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        defaultValue="virtualbox"
                        onChange={(e) => setSelectedVM(e.target.value)}
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
                <div className='col-span-6'>
                    <div className='flex'>
                        {getInstallationMark(selectedVM)}
                    </div>
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
            <div className='px-5 py-3 dark:bg-ghBlack4'>
                <h2 className='text-3xl font-semibold'>General Parameters & Mode Selection</h2>
                <p className='text-sm dark:text-gray-400 text-justify'> Set the parameters to define the internal DNS of KX.AS.CODE.
                    {/* Set the parameters to define the internal DNS of KX.AS.CODE. Each new service that is provisioned in KX.AS.CODE will have the fully qualified domain name (FQDN) of &lt;service_name&gt;, &lt;team_name&gt;. &lt;base_domain&gt;. The username and password fields determine the base admin user password. It is possible to add additional users. In the last section, you determine if running in standalone or cluster mode. Standalone mode starts up one main node only. This is recommended for any physical environment with less than 16G ram. If enable worker nodes, then you can also choose to have workloads running on both main and worker nodes, or only on worker nodes. */}
                </p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12 gap-3'>
                <div className='col-span-6'>
                    <h2 className='text-xl font-semibold dark:text-gray-400'>General Profile Parameters</h2>

                    <InputField inputType={"input"} label={"Base Domain"} value={configJSON.config["baseDomain"]} onChange={(e) => { handleConfigChange(e.target.value, "config.baseDomain") }} />
                    <InputField inputType={"input"} label={"Team Name"} value={configJSON.config["environmentPrefix"]} onChange={(e) => { handleConfigChange(e.target.value, "config.environmentPrefix") }} />
                    <InputField inputType={"input"} label={"Username"} value={configJSON.config["baseUser"]} onChange={(e) => { handleConfigChange(e.target.value, "config.baseUser") }} />
                    <InputField inputType={"password"} label={"Password"} value={configJSON.config["basePassword"]} onChange={(e) => { handleConfigChange(e.target.value, "config.basePassword") }} />
                </div>
                <div className="col-span-6">
                    <h2 className='text-xl font-semibold dark:text-gray-400'>Additional Toggles</h2>
                    <div className='text-sm'>
                        <FormControlLabel
                            className=''
                            control={<Checkbox size="small"
                                defaultChecked={configJSON.config["standaloneMode"]}
                                onChange={(e) => {
                                    console.log("isChecked: ", e.target.checked)
                                    handleConfigChange(e.target.checked, "config.standaloneMode")
                                }}
                            />}
                            label={<span style={{ fontSize: '16px' }}>Enable Standalone Mode</span>}
                        />
                        <FormControlLabel
                            className=''
                            control={<Checkbox size="small"
                                defaultChecked={configJSON.config["allowWorkloadsOnMaster"]}
                                onChange={(e) => { handleConfigChange(e.target.checked, "config.allowWorkloadsOnMaster") }}
                            />}
                            label={<span style={{ fontSize: '16px' }}>Allow Workloads on Kubernetes Master</span>}
                        />
                        <FormControlLabel
                            className=''
                            control={<Checkbox size="small"
                                defaultChecked={configJSON.config["disableLinuxDesktop"]}
                                onChange={(e) => { handleConfigChange(e.target.checked, "config.disableLinuxDesktop") }}
                            />}
                            label={<span style={{ fontSize: '16px' }}>Disable Linux Desktop</span>}
                        />
                    </div>
                </div>
            </div>
        </div>)
};

const TabContent3 = ({ handleConfigChange }) => (
    <div className='text-left'>
        <div className='px-5 py-3 dark:bg-ghBlack4'>
            <h2 className='text-3xl font-semibold'>VM Properties</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>Define how many physical resources you wish to allocate to the KX.AS.CODE virtual machines.</p>
        </div>
        <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12 gap-3'>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold dark:text-gray-400'>KX-Main Parameters</h2>
                <InputField inputType={"input"} label={"KX Main Nodes"} value={configJSON.config.vm_properties["main_node_count"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_node_count") }} type={"number"} minLength={1} maxLength={10} />
                <InputField inputType={"input"} label={"KX Main Cores"} value={configJSON.config.vm_properties["main_admin_node_cpu_cores"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_admin_node_cpu_cores") }} type={"number"} minLength={1} maxLength={30} />
                <InputField inputType={"input"} label={"KX Main RAM"} value={configJSON.config.vm_properties["main_admin_node_memory"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.main_admin_node_memory") }} type={"number"} minLength={1} maxLength={3000} />
            </div>
            <div className='col-span-6'>
                <h2 className='text-xl font-semibold dark:text-gray-400'>KX-Worker Parameters</h2>
                <InputField inputType={"input"} label={"KX Node Nodes"} value={configJSON.config.vm_properties["worker_node_count"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_count") }} type={"number"} minLength={1} maxLength={10} />
                <InputField inputType={"input"} label={"KX Node Cores"} value={configJSON.config.vm_properties["worker_node_cpu_cores"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_cpu_cores") }} type={"number"} minLength={1} maxLength={30} />
                <InputField inputType={"input"} label={"KX Node RAM"} value={configJSON.config.vm_properties["worker_node_memory"]} onChange={(e) => { handleConfigChange(e.target.value, "config.vm_properties.worker_node_memory") }} type={"number"} minLength={1} maxLength={30} unit={"MB"} />
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
        <div className='px-5 py-3 dark:bg-ghBlack3 bg-gray-300 grid grid-cols-12'>
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

const TabContent5 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3 dark:bg-ghBlack4'>
                <h2 className='text-3xl font-semibold'>Notification Settings</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <InputField inputType={"input"} label={"E-Mail"} value={configJSON.notification_endpoints["email_address"]} onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.email_address") }} type={"text"} />

                    <InputField inputType={"input"} label={"MS Teams Webhook"} value={configJSON.notification_endpoints["ms_teams_webhook"]} onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.ms_teams_webhook") }} type={"text"} />

                    <InputField inputType={"input"} label={"Slack Webhook"} value={configJSON.notification_endpoints["slack_webhook"]} onChange={(e) => { handleConfigChange(e.target.value, "notification_endpoints.slack_webhook") }} type={"text"} />
                </div>
            </div>


        </div>)
}

const TabContent6 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3 dark:bg-ghBlack4'>
                <h2 className='text-3xl font-semibold'>Docker</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <InputField inputType={"input"} label={"Dockerhub E-Mail"} value={configJSON.config.docker["dockerhub_email"]} onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_email") }} type={"text"} />

                    <InputField inputType={"input"} label={"Dockerhub E-Mail"} value={configJSON.config.docker["dockerhub_email"]} onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_email") }} type={"text"} />

                    <InputField inputType={"input"} label={"Dockerhub Username"} value={configJSON.config.docker["dockerhub_username"]} onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_username") }} type={"text"} />

                    <InputField inputType={"password"} label={"Dockerhub Password"} value={configJSON.config.docker["dockerhub_password"]} onChange={(e) => { handleConfigChange(e.target.value, "config.docker.dockerhub_password") }} type={"password"} />

                </div>
            </div>

        </div>)
}

const TabContent7 = ({ handleConfigChange }) => {
    return (
        <div className='text-left'>
            <div className='px-5 py-3 dark:bg-ghBlack4'>
                <h2 className='text-3xl font-semibold'>Proxy Settings</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    More Details about this section here.
                </p>
            </div>

            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <InputField inputType={"input"} label={"HTTP Proxy"} value={configJSON.config.proxy_settings["http_proxy"]} onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.http_proxy") }} type={"input"} />

                    <InputField inputType={"input"} label={"HTTS Proxy"} value={configJSON.config.proxy_settings["https_proxy"]} onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.https_proxy") }} type={"input"} />

                    <InputField inputType={"input"} label={"No Proxy"} value={configJSON.config.proxy_settings["no_proxy"]} onChange={(e) => { handleConfigChange(e.target.value, "config.proxy_settings.no_proxy") }} type={"input"} />

                </div>
            </div>
        </div>)
}

const TabContent8 = ({ handleConfigChange }) => {
    const [searchTerm, setSearchTerm] = useState("");
    const [selectedApplicationGroups, setSelectedApplicationGroups] = useState([]);
    const [filteredGroupsCount, setFilteredGroupsCount] = useState(0);

    useEffect(() => {

    }, [selectedApplicationGroups, searchTerm]);

    const handleAddButtonClick = (e, appGroup) => {
        e.preventDefault();
        if (!selectedApplicationGroups.includes(appGroup.title)) {
            setSelectedApplicationGroups(prevSelected => [...prevSelected, appGroup.title]);
        }
        console.log("List: ", selectedApplicationGroups)
    };

    const handleRemoveButtonClick = (e, appGroupTitle) => {
        e.preventDefault();
        console.log('Removing:', appGroupTitle);
        setSelectedApplicationGroups(prevSelected => {
            const updatedSelectedGroups = prevSelected.filter(title => title !== appGroupTitle);
            return updatedSelectedGroups;
        });
    };

    const isInSelectedGroups = (item) => {
        return selectedApplicationGroups.includes(item);
    };

    const findGroupByTitle = (title) => {
        return applicationGroupJson.find(group => group.title.toLowerCase() === title.toLowerCase());
    };

    const drawApplicationGroupCards = () => {
        const lowerCaseSearchTerm = searchTerm.toLowerCase().trim();

        const filteredGroups = applicationGroupJson.filter((appGroup) => {
            const lowerCaseName = (appGroup.title || "").toLowerCase();
            return lowerCaseName.includes(lowerCaseSearchTerm) && !selectedApplicationGroups.includes(appGroup.title);
        });

        setFilteredGroupsCount(filteredGroups.length)

        return filteredGroups.map((appGroup, i) => (
            <ApplicationGroupListItem
                appGroup={appGroup}
                key={i}
                handleAddButtonClick={handleAddButtonClick}
                handleRemoveButtonClick={handleRemoveButtonClick}
                isInSelectedGroups={isInSelectedGroups}
            />
        ));
    };

    const handleClearSearch = () => {
        setSearchTerm('');
    };

    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Application Groups</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>
                    Choose the application groups that are to be integrated into the deployment process.
                </p>
            </div>

            <div className='dark:bg-ghBlack3 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6 pr-2'>

                    <div className="group relative mr-3 my-3 ml-3">
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
                            value={searchTerm}
                            type="text"
                            placeholder="Search Application Groups..."
                            className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack4 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none min-w-80 pl-10 rounded"
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />

                        {searchTerm !== "" && (
                            <IconButton
                                size="small"
                                onClick={handleClearSearch}
                                style={{ position: 'absolute', left: '280px', top: '50%', transform: 'translateY(-50%)' }}
                            >
                                <ClearIcon />
                            </IconButton>
                        )}
                    </div>

                    {/* Application Groups Container */}
                    <div className="h-[320px] overflow-y-auto bg-ghBlack2 p-5 custom-scrollbar">
                        {searchTerm !== "" && filteredGroupsCount === 0 ? (
                            <div className='text-gray-500 pr-5 font-semibold'>No results for "{searchTerm}".</div>
                        ) : null}
                        {filteredGroupsCount === 0 && searchTerm === "" ? (
                            <div className='text-gray-500 text-sm pr-5'>
                                All available application groups added to deployment. Remove groups by clicking on the remove button on each application group listed in the right section.
                            </div>
                        ) : null}
                        {drawApplicationGroupCards()}
                    </div>
                </div>
                <div className='col-span-6 p-5 pt-4 pb-0 bg-ghBlack3'>
                    <div className='text-gray-400 flex justify-start items-center py-2'>
                        <span className='h-5 w-5 text-sm text-ghBlack font-bold p-1 py-0 mr-1 flex justify-center items-center bg-gray-400 rounded'>{selectedApplicationGroups.length}</span>
                        <span className='text-2xl font-semibold'>Selected Application Groups:</span>
                    </div>
                    <div className='rounded py-2 overflow-y-auto h-[329px] custom-scrollbar'>
                        {
                            selectedApplicationGroups.length == 0 ? <div className='text-gray-500 text-sm pr-5'>No application groups selected. Search and select application groups listed in the left section.</div> :
                                selectedApplicationGroups.map((appGroup) => {
                                    return <div id="item" className='px-5 py-2 bg-ghBlack2 rounded mb-1 flex justify-between mr-2 items-center'>
                                        <div>
                                            <div className=''>{appGroup}</div>
                                            {/* <div className='text-sm uppercase text-gray-400'>{findGroupByTitle(appGroup).action_queues.install[0].install_folder !== undefined && findGroupByTitle(appGroup).action_queues.install[0].install_folder }</div> */}
                                        </div>
                                        <IconButton className='hover:bg-ghBlack4 hover:border-white rounded flex justify-center items-center'
                                            onClick={(e) => { handleRemoveButtonClick(e, appGroup) }}
                                            type="submit">
                                            <Remove color='inherit' />
                                        </IconButton>
                                    </div>
                                })
                        }
                    </div>
                </div>
            </div>


        </div >)
}


const ApplicationGroupListItem = ({ appGroup, key, handleAddButtonClick, handleRemoveButtonClick, isInSelectedGroups }) => {

    useEffect(() => {

    }, []);

    return (
        <div key={key} className={`w-full py-2 px-6 bg-ghBlack4 items-center flex justify-between mb-1`}>
            <div>
                <div className=''>{appGroup.title}</div>
                {/* <div className='text-sm uppercase text-gray-400'>{appGroup.action_queues.install[0].install_folder !== undefined && appGroup.action_queues.install[0].install_folder}</div> */}
            </div>
            {isInSelectedGroups(appGroup.title) ? (
                <IconButton className='hover:bg-ghBlack4 border border-gray-400 hover:border-white p-0.5 rounded flex justify-center items-center text-gray-400 hover:text-white'
                    onClick={(e) => { handleRemoveButtonClick(e, appGroup) }}
                    type="submit">
                    <Remove color='inherit' />
                </IconButton>
            ) : (
                <IconButton className='hover:bg-ghBlack4 border border-gray-400 hover:border-white p-0.5 rounded flex justify-center items-center text-gray-400 hover:text-white'
                    onClick={(e) => { handleAddButtonClick(e, appGroup) }}
                    type="submit">
                    <AddIcon color='inherit' />
                </IconButton>
            )}
        </div>)
}