import React, { useState, useEffect } from 'react';
import usersJSON from './assets/config/users.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import JSONConfigTabContent from './JSONConfigTabContent';

const UserProvisioning = () => {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState(JSON.stringify(usersJSON, null, 2));

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    useEffect(() => {

    }, [activeConfigTab, jsonData]);

    return (
        <div className='text-left mt-[90px]'>
            <div className='relative'>
                {/* Config View Tabs */}
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
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"users.json"} />}
            </div>
        </div>)

};

export default UserProvisioning;


const UIConfigTabContent = ({ activeTab, handleTabClick, setJsonData }) => (
    <div id='config-ui-container' className=''>
        <div className='px-5 py-3 dark:bg-ghBlack2'>
            <h2 className='text-3xl font-semibold'>User Provisioning</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>Define additional users to provision in the KX.AS.CODE environment. This is optional. If you do not specify additional users, then only the base user will be available for logging into the desktop and all provisioned tools.</p>
        </div>

        <div className="flex dark:bg-ghBlack3 bg-gray-300 text-sm text-black dark:text-white">
            <button
                onClick={() => handleTabClick('tab1')}
                className={` ${activeTab === 'tab1' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Owner
            </button>
            <button
                onClick={() => handleTabClick('tab2')}
                className={` ${activeTab === 'tab2' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Additional Users
            </button>
        </div>

        <div className="tab-content dark:text-white text-black">
            {activeTab === 'tab1' && <TabContent1 setJsonData={setJsonData}/>}
            {activeTab === 'tab2' && <TabContent2 />}

        </div>
    </div>
);


const TabContent1 = ({ setJsonData }) => {

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

        let parsedData = { ...usersJSON };

        setNestedValue(parsedData, key, selectedValue);

        const updatedJsonString = JSON.stringify(parsedData, null, 2);

        setJsonData(updatedJsonString);
        UpdateJsonFile(updatedJsonString, "users");
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
        const jsonString = JSON.stringify(usersJSON, null, 2);
        setJsonData(jsonString);
    }

    useEffect(() => {
        formatJSONData();
    }, []);


    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Owner</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 grid grid-cols-12'>
                <div className='col-span-6'>
                    <TextField
                        label="E-Mail"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={usersJSON.config.owner["email"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.owner.email") }}
                    >
                    </TextField>

                    <TextField
                        label="Firstname"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={usersJSON.config.owner["firstname"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.owner.firstname") }}
                    >
                    </TextField>

                    <TextField
                        label="Surname"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={usersJSON.config.owner["surname"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.owner.surname") }}
                    >
                    </TextField>

                    <TextField
                            required
                            label="Keyboard Layout"
                            select
                            fullWidth
                            variant="outlined"
                            size="small"
                            margin="normal"
                            value={usersJSON.config.owner["keyboard_language"]}
                            onChange={(e) => { handleConfigChange(e.target.value, "config.owner.keyboard_language")}}
                        >
                            <MenuItem value="de">German</MenuItem>
                            <MenuItem value="us">English (US)</MenuItem>
                            <MenuItem value="gb">English (GB)</MenuItem>
                            <MenuItem value="french">French</MenuItem>
                            <MenuItem value="spanish">Spanish</MenuItem>

                        </TextField>

                    {/* <TextField
                        label="Role"
                        fullWidth
                        variant="outlined"
                        size="small"
                        margin="normal"
                        value={usersJSON.config.owner["role"]}
                        onChange={(e) => { handleConfigChange(e.target.value, "config.owner.role") }}
                    >
                    </TextField> */}

                </div>
            </div>
        </div>
    )
};

const TabContent2 = ({ }) => {
    const [rows, setRows] = React.useState([]);
    const [firstName, setFirstName] = React.useState("");
    const [surname, setSurname] = React.useState("");
    const [email, setEmail] = React.useState("");
    const [layout, setLayout] = React.useState("");
    const [role, setRole] = React.useState("");
    const [usersData, setUsersData] = useState(usersJSON);

    const [firstNameError, setFirstNameError] = React.useState("");
    const [surnameError, setSurnameError] = React.useState("");
    const [emailError, setEmailError] = React.useState("");
    const [layoutError, setLayoutError] = React.useState("");
    const [roleError, setRoleError] = React.useState("");

    const removeUser = (userIdArrayToRemove) => {
        console.log("id param List: ", userIdArrayToRemove);

        setUsersData((prevData) => {
            const updatedUsers = {
                ...prevData,
                config: {
                    ...prevData.config,
                    additionalUsers: prevData.config.additionalUsers.filter(
                        (user) => !userIdArrayToRemove.includes(user.user_id)
                    ),
                },
            };
            const updatedUsersJsonString = JSON.stringify(updatedUsers, null, 2);
            console.log("updatedUsersJsonString: ", updatedUsersJsonString);
            UpdateJsonFile(updatedUsersJsonString, "users");

            return updatedUsers;
        });
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
                <h2 className='text-3xl font-semibold'>Additional Users</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
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
                            <MenuItem value="de">German</MenuItem>
                            <MenuItem value="us">English (US)</MenuItem>
                            <MenuItem value="gb">English (GB)</MenuItem>
                            <MenuItem value="fr">French</MenuItem>
                            <MenuItem value="sp">Spanish</MenuItem>

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
            <UserTable rows={usersData.config.additionalUsers} removeUser={removeUser} />


        </div>
    )
};



const AdditionalUsersViewTabs = () => {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    const handleConfigTabClick = (configTab) => {
        setActiveConfigTab(configTab);
    };

    useEffect(() => {
        formatJSONData();
    }, [activeConfigTab, jsonData]);

    return (
        <div className='relative'>
            <div className='flex grid-cols-12 items-center relative bg-gray-200 dark:bg-ghBlack2 sticky top-[90px] z-10 h-[40px]'>
                <button onClick={() => handleConfigTabClick('config-tab1')} className={`${activeConfigTab === "config-tab1" ? "bg-kxBlue2 text-white" : ""} dark:text-white text-black h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Users  Config UI
                </button>

                {/* Centered icon */}
                <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                    <div className="w-10 h-10 dark:bg-ghBlack4 bg-gray-300 items-center flex justify-center text-xl">
                        <SettingsEthernetIcon fontSize='inherit' />
                    </div>
                </div>

                <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2 text-white" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Users Config JSON
                </button>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"profile-config.json"} />}
            </div>
        </div>
    );
}