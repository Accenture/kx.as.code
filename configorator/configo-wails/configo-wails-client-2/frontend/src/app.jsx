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


const openedMixin = (theme) => ({
    width: drawerWidth,
    transition: theme.transitions.create("width", {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.enteringScreen,
    }),
    overflowX: "hidden",
});

const closedMixin = (theme) => ({
    transition: theme.transitions.create("width", {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.leavingScreen,
    }),
    overflowX: "hidden",
    width: `calc(${theme.spacing(7)} + 1px)`,
    [theme.breakpoints.up("sm")]: {
        width: `calc(${theme.spacing(6.2)} + 1px)`
    },
});

const DrawerHeader = styled("div")(({ theme }) => ({
    display: "flex",
    alignItems: "center",
    justifyContent: "flex-end",
    padding: theme.spacing(0, 1),
    ...theme.mixins.toolbar,
}));

const Drawer = styled(MuiDrawer, { shouldForwardProp: (prop) => prop !== "open" })(
    ({ theme, open }) => ({
        width: drawerWidth,
        flexShrink: 0,
        whiteSpace: "nowrap",
        boxSizing: "border-box",
        ...(open && {
            ...openedMixin(theme),
            "& .MuiDrawer-paper": openedMixin(theme),
        }),
        ...(!open && {
            ...closedMixin(theme),
            "& .MuiDrawer-paper": closedMixin(theme),
        }),
    })
);

const handleDrawerToggle = () => {
    setOpen(!open);
};

const drawerWidth = 240;


export function App() {
    const [open, setOpen] = useState(false);
    const [isDarkMode, setIsDarkMode] = useState(true);
    const location = useLocation();
    const pathnames = location.pathname.split("/").filter((x) => x);
    const slug = pathnames[pathnames.length - 1];

    const [buildOutputFileContent, setBuildOutputFileContent] = useState('');
    const [isBuildStarted, setIsBuildStarted] = useState(false);
    const [buildLogOutput, setBuildLogOutput] = useState('');
    const [intervalId, setIntervalId] = useState(null);

    const handleDrawerOpen = () => {
        setOpen(true);
    };

    const handleDrawerClose = () => {
        setOpen(false);
    };

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

    }, [isDarkMode, pathnames, isBuildStarted, buildOutputFileContent, intervalId, open]);


    return (
        <div className="relative">
            <div className="dark:bg-ghBlack3 relative flex" >
                <ThemeProvider theme={theme}>
                    <div className="dark:bg-ghBlack3 h-screen flex items-center border-ghBlack2 border-r-[2px]">
                        {/* Navigation */}
                        <div className="bg-ghBlack3 mt-auto mb-auto">
                            <List className="" sx={{ paddingY: "0" }}>
                                <MenuItem menuItemName={"dashboard"} slug={slug} />
                                <MenuItem menuItemName={"build"} slug={slug} isBuildStarted={isBuildStarted} />
                                <MenuItem menuItemName={"deploy"} slug={slug} />
                                {/* Separator */}
                                <div className="w-full h-1 bg-ghBlack2 my-0"></div>
                                <MenuItem menuItemName={"application-groups"} slug={slug} />
                                <MenuItem menuItemName={"applications"} slug={slug} />
                                <MenuItem menuItemName={"user-provisioning"} slug={slug} />
                                <MenuItem menuItemName={"custom-variables"} slug={slug} />
                                <MenuItem menuItemName={"build-history"} slug={slug} />
                                <MenuItem menuItemName={"settings"} slug={slug} />
                            </List>
                        </div>
                    </div>
                    <Box component="main" sx={{ flexGrow: 1, p: 0 }} className="text-black dark:text-white flex flex-col min-h-screen">

                        <div className="">
                            <HeaderNew drawerWidth={drawerWidth} handleDrawerOpen={handleDrawerOpen} open={open} handleDarkModeToggle={handleDarkModeToggle} isDarkMode={isDarkMode} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} />
                        </div>
                        <div className="">
                            <Routes>
                                {/* <Route exact path="/" element={<TabMenu />} /> */}
                                <Route path="/" element={<Home />} />
                                <Route path="/dashboard" element={<Dashboard />} />
                                <Route path="/build" element={<TabMenuBuild buildOutputFileContent={buildLogOutput} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} />} />
                                <Route path="/deploy" element={<TabMenuDeploy />} />
                                <Route path="/application-groups" element={<ApplicationGroups />} />
                                <Route path="/user-provisioning" element={<UserProvisioning />} />
                                <Route path="/custom-variables" element={<CustomVariables />} />
                                <Route path="/build-history" element={<BuildHistory />} />
                                <Route path="/console-output" element={<ConsoleOutput />} />
                                <Route path="/applications" element={<Applications />} />
                                <Route path="/applications/:id" component={ApplicationDetails} />
                                {/* <Route path="/users" element={<Users />} /> */}
                                {/* <Route path="/custom-variable-groups" element={<CustomVariableGroups />} /> */}
                                {/* <Route path="/user-groups" element={<CustomVariablesGroups />} /> */}
                            </Routes>
                        </div>

                        {/* Footer Section */}
                        <div className="bg-ghBlack4 p-4 pt-3 w-full text-gray-400 flex justify-end px-10 items-center">
                            <button className="hover:text-white text-gray-400 p-1 rounded-sm hover:underline mr-2 text-sm px-2" onClick={() => {
                                OpenURL("https://github.com/Accenture/kx.as.code")
                            }}>
                                Docs
                            </button>

                            <button className="flex items-center hover:text-white" onClick={() => OpenURL("https://accenture.github.io/kx.as.code/")}>
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

const MenuItem = ({ menuItemName, slug, isBuildStarted }) => {

    useEffect(() => {

    }, [isBuildStarted]);

    const getMenuItemIcon = (menuItemName) => {
        switch (menuItemName) {
            case "build":
                {
                    return isBuildStarted ? (<div className="relative">
                        <svg
                            className="absolute h-4 w-4 top-[-13px] right-[-18px] mt-2 mr-2  text-white animate-spin"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                        >
                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>

                        <PrecisionManufacturingIcon className={`text-lg`} />
                    </div>) : (<PrecisionManufacturingIcon className={`text-lg`} />)
                }
            case "deploy":
                return <RocketLaunchIcon fontSize="small" color="inherit" />
            case "application-groups":
                return <LayersIcon fontSize="small" />
            case "user-provisioning":
                return <PeopleIcon fontSize="small" />
            case "custom-variables":
                return <DataArrayIcon fontSize="small" />
            case "build-history":
                return <HistoryIcon fontSize="small" />
            case "settings":
                return <Settings fontSize="small" />
            case "applications":
                return <Apps fontSize="small" />
            case "dashboard":
                return <DashboardSharp fontSize="small" />
            default:
                break;
        }
    }

    return (
        <Link to={`/${menuItemName}`} className="">
            <ListItemButton
                sx={{
                    backgroundColor: slug == menuItemName ? "#2f3640" : "",
                    "&:hover": {
                        backgroundColor: slug == menuItemName ? "#2f3640" : "#1f262e",
                        borderLeft: slug == menuItemName ? "3px solid #5a86ff" : "3px solid #1f262e"
                    },
                    borderLeft: slug == menuItemName ? "3px solid #5a86ff" : "3px solid #1f262e",
                    paddingX: "3px",
                }}
            >
                <ListItemIcon
                    className="listItemIconContainer items-center flex justify-center p-0"
                >
                    {getMenuItemIcon(menuItemName)}
                </ListItemIcon>
            </ListItemButton>
        </Link>
    );
};