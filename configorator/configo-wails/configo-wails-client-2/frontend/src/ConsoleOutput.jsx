import { useState } from "preact/hooks";
import './app.css';
import { useNavigate } from 'react-router-dom';
import ArrowBackIosNewIcon from '@mui/icons-material/ArrowBackIosNew';

export function ConsoleOutput() {

    const navigate = useNavigate();

    const handleBackClick = () => {
        console.log('Build KX.AS.COde Image clicked!');
        navigate('/');
    };

    return (
        <div className="">
            <div className="flex items-center">
                <button onClick={() => { handleBackClick() }} className="p-3 bg-ghBlack">
                    <ArrowBackIosNewIcon sx={{ fontSize: 20 }} />
                </button>
            </div>
            <div className="text-xl font-semibold bg-ghBlack4 py-5">
                    Build Process Started!
                </div>
            <div className="">
                <div className="bg-ghBlack w-full p-5 h-80">
                    Console output 
                </div>
            </div>
        </div>
    );
}
