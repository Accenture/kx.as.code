import { useState } from "preact/hooks";
import './app.css';
import logo from "./assets/images/ks-logo-w.svg"
import Switch from '@mui/material/Switch';
import IconButton from '@mui/material/IconButton';
import Brightness3 from '@mui/icons-material/Brightness3';
import WbSunnyIcon from '@mui/icons-material/WbSunny';
import { ThemeProvider, createTheme } from '@mui/system';
import MuiAppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import MenuIcon from "@mui/icons-material/Menu";

export function HeaderNew(props) {

    return (
        <MuiAppBar position="fixed" open={props.open} className="h-[90px]" elevation={0}>
            <Toolbar className="dark:bg-ghBlack2 bg-kxBlue">
                <IconButton
                    color="inherit"
                    aria-label="open drawer"
                    onClick={props.handleDrawerOpen}
                    edge="start"
                    sx={{
                        borderRadius: 0,
                        marginRight: 5,
                        ...(props.open && { display: "none" }),
                    }}
                >
                    <MenuIcon className="" />
                </IconButton>
                <div className="dark:bg-ghBlack2 bg-kxBlue p-5 flex items-center justify-between w-full">
                    <div className="flex items-center">
                        <img src={logo} height={50} width={60} />
                        <div className="text-left">
                            <div className="text-sm">KX.AS.Code</div>
                            <div className="font-semibold text-lg">Launcher <span className="text-sm font-normal ml-1 dark:bg-ghBlack4 bg-gray-200 p-1 px-2 rounded text-black dark:text-white">v.0.8.16</span></div>
                        </div>
                    </div>

                    <div>

                        <IconButton
                            color="inherit"
                            aria-label="Toggle dark/light mode"
                            onClick={props.handleDarkModeToggle}
                        >
                            {props.isDarkMode ?  <WbSunnyIcon /> :  <Brightness3 />}
                        </IconButton>
                    </div>
                </div>
            </Toolbar>
        </MuiAppBar>
    );
}
