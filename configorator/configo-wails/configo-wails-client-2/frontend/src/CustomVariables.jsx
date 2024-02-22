import React, { useState, useEffect } from 'react';
import TextField from '@mui/material/TextField';
import customVariablesJSON from './assets/config/customVariables.json';
import GlobalVariablesTable from './GlobalVariablesTable';
import AddIcon from '@mui/icons-material/Add';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import { ConfigSectionHeader } from './ConfigSectionHeader';
import JSONConfigTabContent from './JSONConfigTabContent';

const CustomVariables = () => {
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState('');

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
                parsedData = { ...customVariablesJSON };
            } else {
                console.error("nodeType not defined.")
            }
        } else {
            console.error("os not defined.")
        }

        setNestedValue(parsedData, key, selectedValue)

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
        const jsonString = JSON.stringify(customVariablesJSON, null, 2);
        setJsonData(jsonString);
    }

    useEffect(() => {
        formatJSONData();
    }, [activeConfigTab, jsonData]);


    return (
        <div className='text-left mt-[67px]'>
            <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 sticky top-[67px] z-10 p-1'>
                <div className='col-span-9'>
                    <ConfigSectionHeader sectionTitle={"Custom Global Variables"} SectionDescription={"Set key/value pairs that can be used by solutions when they are being installed."} />
                </div>
                <div className='col-span-3 pr-10'>
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
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent handleConfigChange={handleConfigChange} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"customVariables.json"} />}
            </div>

        </div>)
}

export default CustomVariables;


const UIConfigTabContent = ({ setJsonData }) => {
    const [key, setKey] = React.useState("");
    const [value, setValue] = React.useState("");
    const [keyError, setKeyError] = useState('');
    const [valueError, setValueError] = useState('');
    const [rows, setRows] = React.useState([]);
    const [customVariablesData, setCustomVariablesData] = useState(customVariablesJSON);

    const removeCustomVariable = (customVariableIdArrayToRemove) => {

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
            UpdateJsonFile(updatedCustomVariablesJsonString, "customVariables");

            return updatedCustomVariables;
        });
    };

    useEffect(() => {
    }, [key, value]);


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
            setKeyError('Key is required');
        } else {
            setKeyError('');
        }

        if (!value.trim()) {
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

    return (
        <>
            <form>
                <div className='dark:bg-ghBlack3 bg-gray-300 px-5 py-5'>
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
        </>
    )
};