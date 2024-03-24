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
import { Clear, CreateNewFolder, Folder } from "@mui/icons-material";
import { NavigationHorizontal } from "./NavigationHorizontal";
import { WorkspaceDropdown } from "./WorkspaceDropdown";
import { AiFillFolderAdd } from "react-icons/ai";
import { AiFillFolderOpen } from "react-icons/ai";
import { BsFillSunFill } from "react-icons/bs";
import { BsFillMoonStarsFill } from "react-icons/bs";
import { CreateWorkspaceFile } from "../wailsjs/go/main/App"
import Close from "@mui/icons-material/Close";
import Add from "@mui/icons-material/Add";
import { WorkspaceTabs } from "./WorkspaceTabs";
import { IoPlayCircleSharp } from "react-icons/io5";
import ConfigUiJsonSwitch from "./ConfigUiJsonSwitch";
import { useLocation } from 'react-router-dom';



export function HeaderNew(props) {

    const location = useLocation();
    const [filename, setFilename] = useState('');
    const [searchTerm, setSearchTerm] = useState("")
    const [workspaces, setWorkspaces] = useState([
        {
            "name": "Workspace 1",
            "location_path": ""
        },
        {
            "name": "Workspace 2",
            "location_path": ""
        },
        {
            "name": "Workspace 3",
            "location_path": ""
        }
    ]);

    const handleAddNewWorkspace = async () => {
        CreateWorkspaceFile("test")
    };

    useEffect(() => {

    }, [props.hasError]);

    return (
        <div className="dark:bg-ghBlack bg-kxBlue">
            <div className="dark:bg-ghBlack bg-kxBlue px-4 flex items-center justify-between w-full" style="--wails-draggable:drag">
                <div className="flex items-center ml-[80px]">
                    <Link to={"/"}>
                        <img src={logo} height={40} width={40} className="" />
                    </Link>
                    <div className="text-left pt-1.5">
                        <div className="leading-3 text-[14px]">KX.AS.Code </div>
                        <div className="font-semibold items-center uppercase text-[14px]">Launcher</div>
                    </div>
                </div>

                {/* Global Search */}
                <div className="group relative text-sm">
                    <svg
                        width="16"
                        height="16"
                        fill="currentColor"
                        className="absolute left-3 top-1/2 -mt-2.5 text-gray-500 pointer-events-none group-focus-within:text-kxBlue"
                        aria-hidden="true"
                    >
                        <path
                            fillRule="evenodd"
                            clipRule="evenodd"
                            d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                        />
                    </svg>
                    <input
                        value={searchTerm}
                        type="text"
                        placeholder="Search..."
                        className="border focus:border-kxBlue border-ghBlack3 focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack3 focus:bg-ghBlack4 py-1 placeholder-blueGray-300 text-blueGray-600 text-md shadow outline-none pl-10 pr-8 rounded-sm w-full"
                        onChange={(e) => {

                        }}
                    />
                    {searchTerm !== "" && (
                        <IconButton
                            size="small"
                            onClick={() => { }}
                            style={{ position: 'absolute', right: '0', top: '50%', transform: 'translateY(-50%)' }}
                        >
                            <Clear fontSize='small' />
                        </IconButton>
                    )}
                </div>

                <div className="flex items-center">
                    <WorkspaceDropdown workspaces={workspaces} />
                    <button onClick={handleAddNewWorkspace} className="p-2 flex items-center justify-center hover:bg-ghBlack3 text-gray-400 hover:text-white rounded-sm ml-1">
                        <AiFillFolderAdd />
                    </button>
                    <button className="p-2 flex items-center justify-center hover:bg-ghBlack3 text-gray-400 hover:text-white mr-2 rounded-sm">
                        <AiFillFolderOpen />
                    </button>

                    <div className="flex items-center">
                        <div className="bg-ghBlack3 p-1 justify-start flex items-center mr-2">
                            {/* Action Settings / Button */}
                            <div className='flex justify-center items-center'>
                                {props.isBuildStarted ?
                                    <Tooltip title="Stop Build Process" placement="bottom">
                                        <IconButton onClick={() => { props.toggleBuildStart() }}>
                                            <StopCircleIcon fontSize="large" className="border-3 border-white rounded-full" />
                                        </IconButton>
                                    </Tooltip> :
                                    <Tooltip title="Run Build & Deploy" placement="bottom">
                                        <IconButton disabled={props.hasError} onClick={() => { props.toggleBuildStart() }} className="flex justify-center items-center">
                                            <div className={`border-2 ${props.hasError ? " border-gray-400" : "border-kxBlue"} rounded-full flex justify-center items-center`}>
                                                <IoPlayCircleSharp className="text-[32px]" />
                                            </div>
                                        </IconButton>
                                    </Tooltip>
                                }
                            </div>
                        </div>

                        <div className="text-gray-400 hover:text-white">
                            <IconButton
                                color="inherit"
                                aria-label="Toggle dark/light mode"
                                onClick={props.handleDarkModeToggle}
                            >
                                {props.isDarkMode ? <BsFillSunFill className="text-lg" /> : <BsFillMoonStarsFill className="text-lg" />}
                            </IconButton>
                        </div>
                    </div>
                </div>

            </div>

            {/* Breadcrumbs */}
            <Breadcrumbs />

            {/* Workspace Tabs */}
            {/* <WorkspaceTabs /> */}

            {location.pathname !== "/" && location.pathname !== "/workspaces" && (
                <div className="flex items-center justify-between">
                    {/* Navigation Horizontal */}
                    <NavigationHorizontal />
                    <ConfigUiJsonSwitch isJsonView={props.isJsonView} setIsJsonView={props.setIsJsonView} />
                </div>)
            }


        </div>
    );
}
