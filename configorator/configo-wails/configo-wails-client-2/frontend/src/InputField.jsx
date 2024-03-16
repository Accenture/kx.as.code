import { Visibility, VisibilityOff } from '@mui/icons-material';
import { IconButton, InputAdornment } from '@mui/material';
import React, { useState, useEffect } from 'react';


export default function InputField({ inputType, type, value, placeholder, onChange, dataKey, label, minLength, maxLength, unit }) {

    const [showPassword, setShowPassword] = useState(false);

    const handleClickShowPassword = () => setShowPassword((show) => !show);

    const handleMouseDownPassword = (event) => {
        event.preventDefault();
    };

    useEffect(() => {

    }, []);

    return (
        <div className={` ${inputType === "input" ? "mb-3" : "mb-1.5"} relative`} >
            <div className="capitalize text-gray-400 text-xs absolute left-2 top-2">{label}</div>
            {inputType === "textarea" && (
                <textarea type={type} placeholder={placeholder} rows={3}
                    className={`border-ghBlack3 w-full focus:bg-ghBlack4 focus:outline-none rounded-sm p-2 pt-6 pr-10 bg-ghBlack3 text-white custom-scrollbar resize-none`}
                    onChange={onChange} value={value}
                />
            )}
            {inputType === "input" && (

                type === "number" ? (
                    <input type={type} placeholder={placeholder}
                        className={`w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white ${unit && "pl-9"}`}
                        onChange={onChange} value={value}
                    />
                ) :
                    (
                        <input type={type} placeholder={placeholder}
                            className={`w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white`}
                            onChange={onChange} value={value} minLength={minLength} maxLength={maxLength}
                        />
                    )
            )}

            {inputType === "password" && (
                <input
                    className={`w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white`}
                    type={showPassword ? 'text' : 'password'}
                    value={value}
                    onChange={onChange}
                />
            )}

            {inputType === "password" && (
                <div className='absolute top-1/2 right-5 transform -translate-y-1/2'>
                    <IconButton
                        aria-label="toggle password visibility"
                        onClick={handleClickShowPassword}
                        onMouseDown={handleMouseDownPassword}
                        edge="end"
                    >
                        {showPassword ? <Visibility fontSize='small'/> : <VisibilityOff fontSize='small'/>}
                    </IconButton>
                </div>
            )}

            {unit && (
                <div className='absolute top-[43%] left-2 bottom-5 text-gray-400 font-semibold'>
                    {unit}
                </div>
            )}
        </div>
    );

};