import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import configJSON from './assets/config/config.json';
import customVariablesJSON from './assets/config/customVariables.json';
import GlobalVariablesTable from './GlobalVariablesTable';
import AddIcon from '@mui/icons-material/Add';
import { UpdateJsonFile } from "../wailsjs/go/main/App";

const CustomVariables = () => {
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
        <div className='text-left mt-[90px]'>
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

};

export default CustomVariables;
