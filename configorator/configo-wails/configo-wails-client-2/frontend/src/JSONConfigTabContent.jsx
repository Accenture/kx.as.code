import React, { useState, useEffect, useRef } from 'react';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';
import fs from 'fs';
import { UpdateJsonFile } from "../wailsjs/go/main/App";
import WarningIcon from '@mui/icons-material/Warning';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import { basicDark } from '@uiw/codemirror-theme-basic';
import { langs } from '@uiw/codemirror-extensions-langs';

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
            <div id="codemirror-container" className='w-auto overflow-y-scroll h-auto text-base bg-ghBlack2 custom-scrollbar'>
                <CodeMirror
                    height='400px'
                    extensions={[langs.tsx()]}
                    theme={"dark"}
                    value={props.jsonData}
                    options={{
                        mode: 'json',
                        lineNumbers: true,
                        lineWrapping: true,
                    }}
                    onChange={(value, viewUpdate) => {
                        setIsFileChanged(true)
                        setUpdatedJson(value)
                    }}
                />
            </div>

            {/* Save file changes */}
            {isfileChanged && props.jsonData !== updatedJson && (
                <>
                    <div className='text-white p-3 px-5 flex justify-between items-center text-sm sticky top-[130px] z-10 bg-ghBlack2'>
                        <div className='text-base'>{`Change on ${props.fileName} file detected.`}</div>
                        <div className='flex'>
                            {isValidJson(updatedJson) ? (
                                <div className='flex'>
                                    <div className='text-green-500 rounded p-3 py-1 border-statusGreen border mr-4 items-center flex'>
                                        <CheckCircleOutlineIcon fontSize='inherit' />
                                        <span className='ml-1'>Valid JSON format!</span>
                                    </div>
                                    <button onClick={() => { handleSaveClick() }} className='bg-kxBlue p-2 px-3.5 rounded text-white mr-2'>Save</button>
                                </div>
                            ) : (<div className='text-red-500 rounded p-3 py-1 border-statusRed border text-sm mr-4 items-center flex'>
                                <WarningIcon fontSize='inherit' />
                                <span className='ml-1'>Invalid JSON format!</span>
                            </div>)}
                            <button onClick={() => { handleDiscardChangesClick() }} className='bg-ghBlack4 p-2 px-3.5 text-white rounded'>Discard changes</button>
                        </div>
                    </div>
                    <div className='h-1 bg-ghBlack2'></div>
                </>
            )}
        </div>
    );
}

export default JSONConfigTabContent;