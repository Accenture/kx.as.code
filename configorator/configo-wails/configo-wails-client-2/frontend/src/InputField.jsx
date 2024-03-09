import React, { useState, useEffect } from 'react';


export default function InputField({ inputType, type, value, placeholder, handleInputChange, dataKey, label }) {

    useEffect(() => {

    }, []);

    return (
        <div className="mb-3 relative" >
            <div className="capitalize text-gray-400 text-xs absolute left-2 top-2">{label}</div>
            {inputType === "textarea" ? (
                <textarea type={type} placeholder={placeholder} value={value} rows={3}
                    className={`border-ghBlack3 w-full focus:bg-ghBlack4 focus:outline-none rounded-sm p-2 pt-7 pr-10 bg-ghBlack3 text-white custom-scrollbar resize-none`}
                    onChange={(e) => handleInputChange(dataKey, e.target.value)}
                />
            ) : (
                <input type={type} placeholder={placeholder} value={value}
                    className={`w-full focus:outline-none rounded-sm p-2 pt-7 bg-ghBlack3 focus:bg-ghBlack4 text-white`}
                    onChange={(e) => handleInputChange(dataKey, e.target.value)}
                />
            )}
        </div>
    );

};