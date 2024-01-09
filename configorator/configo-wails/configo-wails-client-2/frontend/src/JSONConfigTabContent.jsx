import React, { useState, useEffect, useRef } from 'react';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';
import fs from 'fs';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import WarningIcon from '@mui/icons-material/Warning';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';

const JSONConfigTabContent = (props) => {
    const editorRef = useRef(null);
    const serializedState = localStorage.getItem('myEditorState');
    const value = localStorage.getItem('myValue') || '';
    const stateFields = { history: historyField };

    const [updatedJson, setUpdatedJson] = useState("");
    const [isfileChanged, setIsFileChanged] = useState(false);

    const handleSaveClick = async () => {
        const updatedData = JSON.stringify(updatedJson, null, 2);
        try {
            UpdateJsonFile(updatedData)
            console.log('File updated successfully.');
        } catch (error) {
            console.error('Error updating file:', error);
        }
    }

    const handleDiscardChangesClick = () => {
        if (editorRef.current) {
            editorRef.current.editor.setValue(props.jsonData);
        }
        setIsFileChanged(false);
    }

    const isValidJson = (str) => {
        try {
            JSON.parse(str);
            return true;
        } catch (error) {
            return false;
        }
    };

    useEffect(() => {

    }, []);

    return (
        <div className='text-left text-black'>
            {/* Save file changes */}
            {isfileChanged && props.jsonData !== updatedJson && (
                <div className='text-white p-3 flex justify-between items-center text-xs'>
                    <div className='text-base'>{`Change on ${props.fileName} file detected.`}</div>
                    <div className='flex'>
                        {isValidJson(updatedJson) ? (
                            <div className='flex'>
                                <div className='text-statusGreen p-3 py-1 border-statusGreen border mr-2 items-center flex'>
                                    <CheckCircleOutlineIcon fontSize='small' />
                                    <span className='ml-1'>Valid JSON format!</span>
                                </div>
                                <button onClick={() => { handleSaveClick() }} className='bg-kxBlue text-white p-3 py-1 mr-2'>Save</button>
                            </div>
                        ) : (<div className='text-statusRed p-3 py-1 border-statusRed border text-xs mr-2 items-center flex'>
                            <WarningIcon fontSize='small' />
                            <span className='ml-1'>Invalid JSON format!</span>
                        </div>)}
                        <button onClick={() => { handleDiscardChangesClick() }} className='bg-white text-black p-3 py-1 text-xs'>Discard changes</button>
                    </div>

                </div>)}

            <CodeMirror
                value={props.jsonData}
                options={{
                    mode: 'json',
                    theme: 'oneDark',
                    lineNumbers: true,
                }}
                onChange={(value, viewUpdate) => {
                    setIsFileChanged(true)
                    setUpdatedJson(value)
                }}
            />
        </div>
    );
}

export default JSONConfigTabContent;