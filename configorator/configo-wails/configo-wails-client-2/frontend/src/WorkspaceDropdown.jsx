import { Settings } from '@mui/icons-material';
import React, { useState } from 'react';
import { IoBriefcaseSharp } from "react-icons/io5";

export function WorkspaceDropdown({ workspaces }) {

    return (
        <div className="relative flex text-sm">
            <div className='p-1 bg-ghBlack3'>
                <button className="p-1 flex items-center justify-center hover:bg-ghBlack4 text-gray-400 hover:text-white rounded-sm ml-1 text-[16px]">
                    <IoBriefcaseSharp />
                </button>
            </div>

            <select
                className="bg-ghBlack3 text-white px-4 pl-0 py-1 rounded-sm appearance-none cursor-pointer w-[150px]"
            >
                <option value="" disabled hidden>Select a Workspace</option>
                {workspaces.map((option, index) => (
                    <option key={index} value={option.name}>{option.name}</option>
                ))}
            </select>
            <div className="absolute right-2 top-1/2 transform -translate-y-1/2 pointer-events-none">
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={2}
                        d="M19 9l-7 7-7-7"
                    />
                </svg>
            </div>
        </div>
    );
}
