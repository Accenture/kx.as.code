import React, { useState, useEffect, useCallback, useRef } from 'react';
import Add from "@mui/icons-material/Add";
import Close from "@mui/icons-material/Close";
import { Prec } from '@uiw/react-codemirror';


export function WorkspaceTabs() {

    const [activeTab, setActiveTab] = useState("Workspace 1")


    return (
        <div className="flex bg-ghBlack3 border-b-[1px] border-b-white/15">
            <WorkspaceTab wsName={"Workspace 1"} setActiveTab={setActiveTab} activeTab={activeTab} />
            <WorkspaceTab wsName={"Workspace 2"} setActiveTab={setActiveTab} activeTab={activeTab} />
            <WorkspaceTab wsName={"Workspace 3"} setActiveTab={setActiveTab} activeTab={activeTab} />

            <button className="text-[18px] flex justify-center items-center text-white p-1 border-x-[1px] border-x-kxBlue2/50 bg-kxBlue2/50">
                <Add fontSize="inherit" />
            </button>
        </div>
    )
}


const WorkspaceTab = ({ wsName, activeTab, setActiveTab }) => {
    const [isEditable, setIsEditable] = useState(false)
    const inputRef = useRef(null);

    const handleDoubleClick = () => {
        setIsEditable(true)
    }

    const handleClick = () => {
        setActiveTab(wsName)
    }

    return (
        <div onDoubleClick={handleDoubleClick} onClick={handleClick} className={`${activeTab === wsName ? "bg-ghBlack4 p-1 pl-3 hover:bg-ghBlack4 text-sm flex items-center justify-center border-t-[1px] border-kxBlue hover:cursor-pointer border-l-[1px] border-l-white/15" : "bg-ghBlack3 p-1 pl-3 hover:bg-ghBlack4 text-sm flex items-center justify-center border-t-[1px] border-ghBlack3 border-l-[1px] border-l-white/15 hover:cursor-pointer"} `}>
            <div className="flex">
                <input readOnly={!isEditable} onDoubleClick={handleDoubleClick} onBlur={() => { setIsEditable(false) }} ref={inputRef} type="text" value={wsName} className={`pl-1 w-[120px] bg-transparent flex focus:outline-none border border-dotted ${isEditable ? 'border-white/50' : "border-transparent"}`} />
            </div>
            <button className="p-1 text-[16px] text-gray-400 hover:text-white rounded-sm flex items-center justify-center">
                <Close fontSize="inherit" />
            </button>
        </div>
    )
}
