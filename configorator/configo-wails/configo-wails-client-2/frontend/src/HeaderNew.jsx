import { useEffect, useState } from "react";
import './app.css';
import logo from "./assets/images/ks-logo-w.svg"
import IconButton from '@mui/material/IconButton';
import Brightness3 from '@mui/icons-material/Brightness3';
import WbSunnyIcon from '@mui/icons-material/WbSunny';
import MuiAppBar from "@mui/material/AppBar";
import Tooltip from '@mui/material/Tooltip';
import { styled, useTheme } from '@mui/material/styles';
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import StopCircleIcon from '@mui/icons-material/StopCircle';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import { Breadcrumbs } from "./Breadcrumbs";
import { Link } from "react-router-dom"

const drawerWidth = 0;

const AppBar = styled(MuiAppBar, {
    shouldForwardProp: (prop) => prop !== 'open',
})(({ theme, open }) => ({
    zIndex: theme.zIndex.drawer + 1,
    transition: theme.transitions.create(['width', 'margin'], {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.leavingScreen,
    }),
    ...(open && {
        marginLeft: drawerWidth,
        width: `calc(100% - ${drawerWidth}px)`,
        transition: theme.transitions.create(['width', 'margin'], {
            easing: theme.transitions.easing.sharp,
            duration: theme.transitions.duration.enteringScreen,
        }),
    }),
}));

export function HeaderNew(props) {

    useEffect(() => {

    }, [props.open]);

    return (
        <AppBar position="" open={props.open} className="dark:bg-ghBlack2 bg-kxBlue" elevation={0}>
            <div className="dark:bg-ghBlack2 bg-kxBlue px-4 flex items-center justify-between w-full h-[67px]" style="--wails-draggable:drag">
                <div className="flex items-center">
                    <Link to={"/"}>
                        <img src={logo} height={40} width={40} className="hover:p-0.5"/>
                    </Link>
                    <div className="text-left">
                        <div className="text-sm">KX.AS.Code <span className="italic font-bold">ALPHA</span></div>
                        <div className="font-bold text-lg">Launcher <span className="text-sm font-normal p-0.5 px-1 text-white">v.0.8.16</span></div>
                    </div>
                </div>

                <div className="flex items-center">
                    <div className="bg-ghBlack3 p-2 justify-start flex items-center mr-2">
                        {/* Action Settings / Button */}
                        <div className='flex justify-center items-center'>
                            {props.isBuildStarted ?
                                <Tooltip title="Stop Build Process" placement="right">
                                    <IconButton onClick={() => { props.toggleBuildStart() }}>
                                        <StopCircleIcon fontSize="large" className="border-3 border-white rounded-full" />
                                    </IconButton>
                                </Tooltip> :
                                <Tooltip title="Run Build & Deploy" placement="right">
                                    <IconButton onClick={() => { props.toggleBuildStart() }}>
                                        <PlayCircleIcon fontSize="large" className="border-3 border-kxBlue rounded-full" />
                                    </IconButton>
                                </Tooltip>
                            }
                        </div>
                    </div>

                    <div>
                        <IconButton
                            color="inherit"
                            aria-label="Toggle dark/light mode"
                            onClick={props.handleDarkModeToggle}
                        >
                            {props.isDarkMode ? <WbSunnyIcon fontSize="small" /> : <Brightness3 fontSize="small" />}
                        </IconButton>
                    </div>
                </div>
            </div>

            {/* Breadcrumbs */}
            <Breadcrumbs />
        </AppBar>
    );
}
