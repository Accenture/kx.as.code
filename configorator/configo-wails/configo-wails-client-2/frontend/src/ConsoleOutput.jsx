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
        <div className="flex items-center">
            <button onClick={() => {handleBackClick()}} className="p-3 bg-ghBlack">
                <ArrowBackIosNewIcon />
                </button>
        </div>
    );
}
