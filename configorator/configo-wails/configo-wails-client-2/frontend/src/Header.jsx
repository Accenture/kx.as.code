import { useState } from "preact/hooks";
import './app.css';
import logo from "./assets/images/ks-logo-w.svg"
import Switch from '@mui/material/Switch';
import IconButton from '@mui/material/IconButton';
import Brightness3 from '@mui/icons-material/Brightness3';
import WbSunnyIcon from '@mui/icons-material/WbSunny';
import { ThemeProvider, createTheme } from '@mui/system';

export function Header() {

    const [darkMode, setDarkMode] = useState(false);

    const handleDarkModeToggle = () => {
        setDarkMode(!darkMode);
    };

    return (
        <div className="bg-ghBlack3 p-5 flex items-center justify-between">
            <div className="flex items-center">
                <img src={logo} height={50} width={60} />
                <div className="text-left">
                    <div className="text-sm">KX.AS.Code</div>
                    <div className="font-semibold text-lg">Configorator <span className="text-sm font-normal ml-1 bg-ghBlack2 p-1 px-2 rounded">v.0.8.16</span></div>
                </div>
            </div>

            <div>

                <IconButton
                    color="inherit"
                    aria-label="Toggle dark/light mode"
                    onClick={handleDarkModeToggle}
                >
                    {darkMode ? <Brightness3 /> : <WbSunnyIcon />}
                </IconButton>
            </div>
        </div>
    );
}
