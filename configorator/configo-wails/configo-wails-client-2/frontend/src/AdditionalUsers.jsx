import React, { useState, useEffect } from 'react';
import usersJSON from './assets/config/users.json';
import TextField from '@mui/material/TextField';
import MenuItem from '@mui/material/MenuItem';
import UserTable from './UserTable';
import PersonAddAltIcon from '@mui/icons-material/PersonAddAlt';
import { UpdateJsonFile } from "../wailsjs/go/main/App";

const AdditionalUsers = () => {

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
        <div className='text-left mt-[90px]'>
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
            <UserTable rows={usersData.config.additionalUsers} removeUser={removeUser} />
        </div>)

};

export default AdditionalUsers;
