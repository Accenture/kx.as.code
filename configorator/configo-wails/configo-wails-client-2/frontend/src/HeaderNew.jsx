import { useEffect, useState } from "preact/hooks";
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
import Tooltip from '@mui/material/Tooltip';
import { styled, useTheme } from '@mui/material/styles';
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import StopCircleIcon from '@mui/icons-material/StopCircle';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';


const drawerWidth = 240;

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
        <AppBar position="fixed" open={props.open} className="dark:bg-ghBlack2 bg-kxBlue" elevation={0}>
            <Toolbar className="dark:bg-ghBlack2 bg-kxBlue">
                <div className="">
                    <IconButton
                        color="inherit"
                        aria-label="open drawer"
                        onClick={() => {
                            props.handleDrawerOpen()
                        }}
                        edge="start"
                        sx={{
                            ...(props.open && { display: "none" }),
                        }}
                    >
                        <ChevronRightIcon />
                    </IconButton>
                </div>
                <div className="dark:bg-ghBlack2 bg-kxBlue px-4 flex items-center justify-between w-full">
                    <div className="flex items-center">
                        <img src={logo} height={50} width={60} />
                        <div className="text-left">
                            <div className="text-sm">KX.AS.Code</div>
                            <div className="font-semibold text-lg">Launcher <span className="text-sm font-normal ml-1 p-0.5 px-1 text-white">v.0.8.16</span></div>
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
                                    <Tooltip title="Start New Build" placement="right">
                                        <IconButton onClick={() => { props.toggleBuildStart() }}>
                                            <PlayCircleIcon fontSize="large" className="border-3 border-kxBlue rounded-full"/>
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
                                {props.isDarkMode ? <WbSunnyIcon /> : <Brightness3 />}
                            </IconButton>
                        </div>
                    </div>
                </div>
            </Toolbar>
        </AppBar>
    );
}
