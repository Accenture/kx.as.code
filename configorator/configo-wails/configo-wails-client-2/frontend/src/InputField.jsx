import React, { useState, useEffect } from 'react';
import { IconButton } from '@mui/material';
import { CopyAll, Check, Visibility, VisibilityOff } from '@mui/icons-material';
import { toast } from 'sonner';

export default function InputField({ inputType, type, value, placeholder, onChange, label, minLength, maxLength, unit, options, selectTitle }) {
    const [showPassword, setShowPassword] = useState(false);
    const [showCopyToClipboardButton, setShowCopyToClipboardButton] = useState(false);
    const [showCheck, setShowCheck] = useState(false);

    const handleClickShowPassword = () => setShowPassword((show) => !show);

    const handleCopy = () => {
        toast(`${label} copied to clipboard.`, { icon: <CopyAll fontSize='small' /> });
        navigator.clipboard.writeText(value)
            .then(() => {
                console.log('Text copied to clipboard:', value);
                setShowCheck(true);
                setTimeout(() => {
                    setShowCheck(false);
                }, 2000);
            })
            .catch(error => {
                console.error('Error copying text to clipboard:', error);
            });
    };

    useEffect(() => {

    }, []);

    return (
        <div className={` ${inputType === "input" ? "mb-3" : "mb-1.5"} relative`} onMouseEnter={() => setShowCopyToClipboardButton(true)} onMouseLeave={() => setShowCopyToClipboardButton(false)}>
            <div className="capitalize text-gray-400 text-xs absolute left-2 top-2">{label}</div>
            {showCopyToClipboardButton && inputType === "input" && (
                <div className="capitalize text-gray-400 text-xs absolute right-2 top-3">
                    <button className='p-1.5 text-gray-400 hover:text-white rounded-sm hover:bg-white/10'
                        onClick={() => {
                            !showCheck && handleCopy();
                        }}
                    >
                        {showCheck ? <Check fontSize='small' /> : <CopyAll fontSize='small' />}
                    </button>
                </div>
            )}
            {inputType === "textarea" && (
                <textarea
                    type={type}
                    placeholder={placeholder}
                    rows={3}
                    className={`border-ghBlack3 w-full focus:bg-ghBlack4 focus:outline-none rounded-sm p-2 pt-6 pr-10 bg-ghBlack3 text-white custom-scrollbar resize-none`}
                    onChange={onChange}
                    value={value}
                />
            )}
            {inputType === "input" && (
                <input
                    type={type}
                    placeholder={placeholder}
                    className={`w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white ${unit && "pl-9"}`}
                    onChange={onChange}
                    value={value}
                    minLength={minLength}
                    maxLength={maxLength}
                />
            )}
            {inputType === "password" && (
                <>
                    <input
                        className={`w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white`}
                        type={showPassword ? 'text' : 'password'}
                        value={value}
                        onChange={onChange}
                    />
                    <div className='absolute top-1/2 right-5 transform -translate-y-1/2'>
                        <IconButton
                            aria-label="toggle password visibility"
                            onClick={handleClickShowPassword}
                            edge="end"
                        >
                            {showPassword ? <Visibility fontSize='small' /> : <VisibilityOff fontSize='small' />}
                        </IconButton>
                    </div>
                </>
            )}
            {
                inputType === "select" && (
                    <>
                        <select
                            className="w-full focus:outline-none rounded-sm p-2 pt-6 bg-ghBlack3 focus:bg-ghBlack4 text-white appearance-none cursor-pointer"
                            onChange={onChange}
                        >
                            <option value="" disabled hidden>{selectTitle}</option>
                            {options.map((option, index) => (
                                <option key={index} value={option.value}>{option.label}</option>
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
                    </>
                )
            }
            {unit && (
                <div className='absolute top-[43%] left-2 bottom-5 text-gray-400 font-semibold'>
                    {unit}
                </div>
            )}
        </div>
    );
};
