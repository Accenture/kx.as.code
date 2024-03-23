import React, { useState, useEffect, useCallback } from 'react';
import './app.css';
import { HeaderNew } from "./HeaderNew";
import { Routes, Route, Link, useLocation } from "react-router-dom";
import TabMenuBuild from "./TabMenuBuild";
import TabMenuDeploy from "./TabMenuDeploy";
import Home from "./Home";
import Dashboard from "./Dashboard";
import { createTheme, ThemeProvider, styled } from '@mui/material/styles';
import { ConsoleOutput } from "./ConsoleOutput";
import UserProvisioning from "./UserProvisioning";
import CustomVariables from "./CustomVariables";
import Box from "@mui/material/Box";
import MuiDrawer from "@mui/material/Drawer";
import List from "@mui/material/List";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import PrecisionManufacturingIcon from '@mui/icons-material/PrecisionManufacturing';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import PeopleIcon from '@mui/icons-material/People';
import DataArrayIcon from '@mui/icons-material/DataArray';
import LayersIcon from '@mui/icons-material/Layers';
import { ApplicationGroups } from "./ApplicationGroups";
import { ExeBuild, StopExe, OpenURL } from "../wailsjs/go/main/App"
import buildOutputFile from './assets/buildOutput.txt';
import TipsAndUpdatesIcon from '@mui/icons-material/TipsAndUpdates';
import { Toaster } from 'sonner';
import { toast } from 'sonner';
import HistoryIcon from '@mui/icons-material/History';
import BuildHistory from "./BuildHistory";
import GitHubIcon from '@mui/icons-material/GitHub';
import { Apps, DashboardCustomize, DashboardSharp, Settings } from "@mui/icons-material";
import Applications from "./Applications";
import { ApplicationDetails } from "./ApplicationDetails";
import Test from './Test';

export function App() {
    const [isDarkMode, setIsDarkMode] = useState(true);
    const location = useLocation();
    const pathnames = location.pathname.split("/").filter((x) => x);
    const slug = pathnames[pathnames.length - 1];

    const [buildOutputFileContent, setBuildOutputFileContent] = useState('');
    const [isBuildStarted, setIsBuildStarted] = useState(false);
    const [buildLogOutput, setBuildLogOutput] = useState('');
    const [intervalId, setIntervalId] = useState(null);

    const [hasError, setHasError] = useState(false);
    const [isTestError, setIsTestError] = useState(false);
    const [isJsonView, setIsJsonView] = useState(false);



    const handleDarkModeToggle = () => {
        setIsDarkMode((prevIsDarkMode) => !prevIsDarkMode);
        document.documentElement.classList.toggle('dark', !isDarkMode);
    };

    const theme = createTheme({
        components: {
            MuiAutocomplete: {
                styleOverrides: {
                    option: {
                        padding: 0,
                    },
                },
            },
        },
        shape: {
            borderRadius: 3,
        },
        palette: {
            mode: isDarkMode ? "dark" : "light",
            primary: {
                main: '#5a86ff',
            }
        },
        overrides: {
            MuiOutlinedInput: {
                root: {
                    '&$focused $notchedOutline': {
                        borderColor: 'green',
                    },
                },
            },
            MuiSelect: {
                icon: {
                    color: 'green',
                },
            }
        }
    });

    const toggleBuildStart = useCallback(() => {
        setIsBuildStarted((prevIsBuildStarted) => !prevIsBuildStarted);
        if (isBuildStarted) {
            toast("Build stopped.", { icon: <PrecisionManufacturingIcon /> })
            StopExe();
        } else {
            toast("Build started.", { icon: <PrecisionManufacturingIcon /> })
            ExeBuild().then(result => {
                setBuildOutputFileContent(result);
            });
        }
    }, [isBuildStarted]);

    const fetchBuildOutput = useCallback(() => {
        fetch(buildOutputFile)
            .then(response => response.text())
            .then(text => setBuildOutputFileContent(text))
            .catch(error => console.error("Error fetching build output:", error));
    }, [buildOutputFile]);


    const fetchFileContentNew = async () => {
        try {
            const response = await fetch(buildOutputFile);
            const text = await response.text();
            setBuildLogOutput(text)
        } catch (error) {
            console.error('Error fetching file content:', error);
        }
    };

    useEffect(() => {
        const htmlElement = document.querySelector('html');
        if (isDarkMode) {
            htmlElement.classList.add('dark');
        } else {
            htmlElement.classList.remove('dark');
        }
        const handleLocationChange = () => {
            setPathname(window.location.pathname);
        };

        window.addEventListener('popstate', handleLocationChange);

        fetchFileContentNew(); // Initial fetch

        const intervalId = setInterval(() => {
            fetchFileContentNew();
        }, 2000);


        return () => {
            window.removeEventListener('popstate', handleLocationChange);
            if (intervalId) {
                clearInterval(intervalId);
            }
        };

    }, [isDarkMode, pathnames, isBuildStarted, buildOutputFileContent, intervalId]);


    return (
        <div className="relative">
            <div className="dark:bg-ghBlack3 relative flex" >
                <ThemeProvider theme={theme}>
                    <Box component="main" sx={{ flexGrow: 1, p: 0 }} className="text-black dark:text-white flex flex-col min-h-screen">

                        <div className="">
                            {/* isTestValue: <span className={`${isTestError ? "text-green-500" : "text-red-500"}`}>{isTestError.toString()}</span>
                            <Test setIsTestError={setIsTestError}/> */}
                            <HeaderNew handleDarkModeToggle={handleDarkModeToggle} isDarkMode={isDarkMode} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} hasError={hasError} isJsonView={isJsonView} setIsJsonView={setIsJsonView} />
                            {/* <div><span className={`${hasError ? "text-green-500" : "text-red-500"}`}>{hasError.toString()}</span></div> */}
                        </div>
                        <div className="">
                            <Routes>
                                {/* <Route exact path="/" element={<TabMenu />} /> */}
                                <Route path="/" element={<Home />} />
                                <Route path="/dashboard" element={<Dashboard />} />
                                <Route path="/build" element={<TabMenuBuild buildOutputFileContent={buildLogOutput} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} setHasError={setHasError} isJsonView={isJsonView} />} />
                                <Route path="/deploy" element={<TabMenuDeploy isJsonView={isJsonView} />} />
                                <Route path="/application-groups" element={<ApplicationGroups />} />
                                <Route path="/user-groups" element={<UserProvisioning />} />
                                <Route path="/custom-variable-groups" element={<CustomVariables />} />
                                <Route path="/build-history" element={<BuildHistory />} />
                                <Route path="/console-output" element={<ConsoleOutput />} />
                                <Route path="/applications" element={<Applications />} />
                                <Route path="/applications/:id" element={<ApplicationDetails />} />
                                {/* <Route path="/users" element={<Users />} /> */}
                                {/* <Route path="/custom-variable-groups" element={<CustomVariableGroups />} /> */}
                                {/* <Route path="/user-groups" element={<CustomVariablesGroups />} /> */}
                            </Routes>
                        </div>

                        {/* Footer Section */}
                        <div className="bg-ghBlack p-4 pt-3 w-full text-gray-400 flex justify-end px-10 items-center border-t border-ghBlack4">
                            <button className="hover:text-white text-gray-400 p-1 rounded-sm hover:underline mr-2 text-sm px-2" onClick={() => {
                                OpenURL("https://accenture.github.io/kx.as.code/")
                            }}>
                                Docs
                            </button>

                            <button className="flex items-center hover:text-white" onClick={() => OpenURL("https://github.com/Accenture/kx.as.code")}>
                                <GitHubIcon fontSize="small" />
                            </button>
                        </div>

                    </Box>
                    <Toaster
                        expand visibleToasts={3}
                        duration={2000}
                        toastOptions={{
                            style: {
                                background: "#3e5db2",
                                borderRadius: "3px",
                                borderWidth: "0",
                                color: "white",
                                boxShadow: "none"
                            },
                            className: '',
                        }} />
                </ThemeProvider>
            </div >
        </div >

    );
}