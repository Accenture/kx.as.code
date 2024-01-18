import React, { useState, useEffect } from 'react';
import usersJSON from './assets/templates/applicationGroups.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import SettingsEthernetIcon from '@mui/icons-material/SettingsEthernet';
import JSONConfigTabContent from './JSONConfigTabContent';

const ApplicationGroups = () => {

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
                        Application Groups UI
                    </button>

                    {/* Centered icon */}
                    <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2">
                        <div className="w-10 h-10 dark:bg-ghBlack4 bg-gray-300 items-center flex justify-center text-xl">
                            <SettingsEthernetIcon fontSize='inherit' />
                        </div>
                    </div>

                    <button onClick={() => handleConfigTabClick('config-tab2')} className={`${activeConfigTab === "config-tab2" ? "bg-kxBlue2 text-white" : ""} h-10 flex col-span-6 w-full text-center items-center justify-center`}>
                    Application Groups JSON
                    </button>
                </div>
            </div>

            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"applicationGroups.json"} />}
            </div>
        </div>)

};

export default ApplicationGroups;


const UIConfigTabContent = ({ activeTab, handleTabClick, setJsonData }) => (
    <div id='config-ui-container' className=''>
        <div className='px-5 py-3 dark:bg-ghBlack2'>
            <h2 className='text-3xl font-semibold'>Application Groups</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
        </div>

        <div className="flex dark:bg-ghBlack3 bg-gray-300 text-sm text-black dark:text-white">
            <button
                onClick={() => handleTabClick('tab1')}
                className={` ${activeTab === 'tab1' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Tab1
            </button>
            <button
                onClick={() => handleTabClick('tab2')}
                className={` ${activeTab === 'tab2' ? 'border-kxBlue border-b-3 dark:bg-ghBlack4 bg-gray-400' : 'broder dark:border-ghBlack3 border-gray-300 border-b-3'} p-3 py-1`}
            >
                Tab2
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
                <h2 className='text-3xl font-semibold'>Tab1</h2>
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
                        value={""}
                        onChange={(e) => { handleConfigChange(e.target.value, "") }}
                    >
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
                <h2 className='text-3xl font-semibold'>Tab2</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>More details about this section here.</p>
            </div>


            <div className='px-5 py-3 dark:bg-ghBlack2 bg-gray-300 gap-2'>
               
            </div>
        </div>
    )
};