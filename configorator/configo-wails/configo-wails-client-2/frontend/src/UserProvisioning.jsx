import React, { useState, useEffect } from 'react';
import usersJSON from './assets/config/users.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import JSONConfigTabContent from './JSONConfigTabContent';
import { ConfigSectionHeader } from './ConfigSectionHeader';

const UserProvisioning = () => {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState(JSON.stringify(usersJSON, null, 2));

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    useEffect(() => {

    }, [activeConfigTab, jsonData]);

    return (
        <div className='text-left'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky top-[67px] z-10 p-1'>
                    <div className='col-span-9'>
                        <ConfigSectionHeader sectionTitle={"User Provisioning"} SectionDescription={"Define additional users to provision in the KX.AS.CODE environment."} />
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
            </div>
            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"users.json"} />}
            </div>
        </div>)

};

export default UserProvisioning;


const UIConfigTabContent = ({ activeTab, handleTabClick, setJsonData }) => (
    <div id='config-ui-container' className=''>
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
            {activeTab === 'tab1' && <TabContent1 setJsonData={setJsonData} />}
            {activeTab === 'tab2' && <TabContent2 />}
        </div>
    </div>
);


const TabContent1 = ({ setJsonData }) => {

    const [firstName, setFirstName] = React.useState("");
    const [surname, setSurname] = React.useState("");

    const generateUsername = (firstname, surname) => {
        firstname = firstname || '';
        surname = surname || '';

        let firstnameSubstringLength = 8 - surname.length;

        if (firstnameSubstringLength <= 0) {
            firstnameSubstringLength = 1;
        }

        const userId = `${surname.toLowerCase().substring(0, 7)}${firstname.toLowerCase().substring(0, firstnameSubstringLength)}`;

        return userId;
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
        setFirstName(usersJSON.config.owner["firstname"])
        setSurname(usersJSON.config.owner["surname"])
    }, [firstName, surname]);


    return (
        <div className='text-left'>
            <div className='px-5 py-3'>
                <h2 className='text-3xl font-semibold'>Owner</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
            </div>
            <div className='px-5 py-3 dark:bg-ghBlack3 bg-gray-300 grid grid-cols-12'>
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
                        onChange={(e) => { handleConfigChange(e.target.value, "config.owner.keyboard_language") }}
                    >
                        <MenuItem value="de">German</MenuItem>
                        <MenuItem value="us">English (US)</MenuItem>
                        <MenuItem value="gb">English (GB)</MenuItem>
                        <MenuItem value="french">French</MenuItem>
                        <MenuItem value="spanish">Spanish</MenuItem>
                    </TextField>
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

    const generateUsername = (firstname, surname) => {
        firstname = firstname || '';
        surname = surname || '';

        let firstnameSubstringLength = 8 - surname.length;

        if (firstnameSubstringLength <= 0) {
            firstnameSubstringLength = 1;
        }

        const userId = `${surname.toLowerCase().substring(0, 7)}${firstname.toLowerCase().substring(0, firstnameSubstringLength)}`;

        return userId;
    };

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
            "user_id": generateUsername(firstName, surname),
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


            <div className='px-5 py-3 dark:bg-ghBlack3 bg-gray-300 gap-2'>
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