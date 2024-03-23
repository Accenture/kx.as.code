import React, { useState, useEffect } from 'react';
import { AiOutlineLayout } from "react-icons/ai";
import { VscJson } from "react-icons/vsc";

export default function ConfigUiJsonSwitch({ isJsonView, setIsJsonView }) {

    const handleCheckboxChange = () => {
        setIsJsonView(!isJsonView)
    }

    useEffect(() => {


    }, []);

    return (
        <label className='relative inline-flex cursor-pointer select-none items-center h-full'>
            <input
                type='checkbox'
                checked={isJsonView}
                onChange={handleCheckboxChange}
                className='sr-only'
            />
            <div className='shadow-card flex p-1 items-center justify-center h-full'>
                <span
                    className={`flex h-7 w-7 items-center justify-center rounded-sm ${!isJsonView ? 'bg-kxBlue2 ' : 'text-gray-400 hover:text-white'
                        }`}
                >
                    <AiOutlineLayout />
                </span>
                <span
                    className={`flex h-7 w-7 items-center justify-center rounded-sm ${isJsonView ? 'bg-kxBlue2' : 'text-gray-400 hover:text-white'
                        }`}
                >
                    <VscJson />
                </span>
            </div>
        </label>
    )

};