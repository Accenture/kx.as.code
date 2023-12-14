import React, { useState, useEffect } from 'react';
import CodeMirror from '@uiw/react-codemirror';
import { historyField } from '@codemirror/commands';

const JSONConfigTabContent = (props) => {
    const serializedState = localStorage.getItem('myEditorState');
    const value = localStorage.getItem('myValue') || '';
    const stateFields = { history: historyField };

    const [updatedJson, setUpdatedJson] = useState("");
    const [isfileChanged, setIsFileChanged] = useState(false);

    useEffect(() => {

    }, []);

    return (
        <div className='text-left text-black'>

            {/* Save file changes */}
            {isfileChanged && props.jsonData !== updatedJson && (<div className='text-white p-3 bg-ghBlack4 flex justify-between items-center'>
                <div className=''>Change on profile-config.json file detected.</div>
                <div className='flex'>
                    <button className='bg-kxBlue text-white p-3 py-1 mr-2'>Save</button>
                    <button className='bg-white text-black p-3 py-1'>Discard</button>
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