import { useState, useEffect, useCallback } from "preact/hooks";
import './app.css';
import { HeaderNew } from "./HeaderNew";
import { Routes, Route, Link, useLocation } from "react-router-dom";
import TabMenuBuild from "./TabMenuBuild";
import TabMenuDeploy from "./TabMenuDeploy";
import Home from "./Home";
import { createTheme, ThemeProvider, styled } from '@mui/material/styles';
import { ConsoleOutput } from "./ConsoleOutput";
import UserProvisioning from "./UserProvisioning";
import CustomVariables from "./CustomVariables";
import Box from "@mui/material/Box";
import MuiDrawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import List from "@mui/material/List";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import PrecisionManufacturingIcon from '@mui/icons-material/PrecisionManufacturing';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import HomeIcon from '@mui/icons-material/Home';
import Tooltip from '@mui/material/Tooltip';
import PeopleIcon from '@mui/icons-material/People';
import DataArrayIcon from '@mui/icons-material/DataArray';
import LayersIcon from '@mui/icons-material/Layers';
import { ApplicationGroups } from "./ApplicationGroups";
import { ExeBuild, StopExe, OpenURL } from "../wailsjs/go/main/App"
import buildOutputFile from './assets/buildOutput.txt';
import TipsAndUpdatesIcon from '@mui/icons-material/TipsAndUpdates';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import MenuIcon from '@mui/icons-material/Menu';
import { Toaster } from 'sonner';
import { toast } from 'sonner';
import HistoryIcon from '@mui/icons-material/History';
import BuildHistory from "./BuildHistory";
import GitHubIcon from '@mui/icons-material/GitHub';
import { Settings } from "@mui/icons-material";


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
        width: `calc(${theme.spacing(8)} + 1px)`,
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
            <div className="dark:bg-ghBlack relative" >
                <ThemeProvider theme={theme}>
                    <Box sx={{ display: "flex" }}>
                        <Drawer variant="permanent" open={open}
                            sx={{
                                '& .MuiDrawer-paper': {
                                    // borderRight: 'none',
                                    borderRightWidth: "0px",
                                    borderColor: "#2f3640",
                                    backgroundColor: '#1f262e',
                                    zIndex: 0
                                }
                            }} >
                            <DrawerHeader>
                                <IconButton onClick={() => setOpen(!open)}>
                                    {open ? <ChevronLeftIcon /> : <ChevronRightIcon />}
                                </IconButton>
                            </DrawerHeader>
                            <List className="" style={{ marginTop: "auto", marginBottom: "auto", paddingBottom: "150px" }}>
                                <MenuItem menuItemName={"home"} slug={slug} />
                                <MenuItem menuItemName={"build"} slug={slug} isBuildStarted={isBuildStarted} />
                                <MenuItem menuItemName={"deploy"} slug={slug} />
                                {/* Separator */}
                                <div className="w-full h-[3px] bg-ghBlack4 mt-0 mb-2"></div>
                                <MenuItem menuItemName={"application-groups"} slug={slug} />
                                <MenuItem menuItemName={"user-provisioning"} slug={slug} />
                                <MenuItem menuItemName={"custom-variables"} slug={slug} />
                                <MenuItem menuItemName={"build-history"} slug={slug} />
                                <MenuItem menuItemName={"settings"} slug={slug} />
                            </List>
                        </Drawer>

                        <Box component="main" sx={{ flexGrow: 1, p: 0 }} className="text-black dark:text-white flex flex-col min-h-screen">

                            <div className="">
                                <HeaderNew drawerWidth={drawerWidth} handleDrawerOpen={handleDrawerOpen} open={open} handleDarkModeToggle={handleDarkModeToggle} isDarkMode={isDarkMode} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} />
                            </div>
                            <div className="">
                                <Routes>
                                    {/* <Route exact path="/" element={<TabMenu />} /> */}
                                    <Route path="/home" element={<Home />} />
                                    <Route path="/build" element={<TabMenuBuild buildOutputFileContent={buildLogOutput} toggleBuildStart={toggleBuildStart} isBuildStarted={isBuildStarted} />} />
                                    <Route path="/deploy" element={<TabMenuDeploy />} />
                                    <Route path="/application-groups" element={<ApplicationGroups />} />
                                    <Route path="/user-provisioning" element={<UserProvisioning />} />
                                    <Route path="/custom-variables" element={<CustomVariables />} />
                                    <Route path="/build-history" element={<BuildHistory />} />
                                    <Route path="/console-output" element={<ConsoleOutput />} />
                                </Routes>
                            </div>

                        </Box>
                        <Toaster
                            expand visibleToasts={3}
                            duration={2000}
                            toastOptions={{
                                style: {
                                    background: "#161b22",
                                    borderRadius: "3px",
                                    borderWidth: "0",
                                    color: "white",
                                    boxShadow: "none"
                                },
                                className: '',
                            }} />
                    </Box>
                </ThemeProvider>
            </div >
            {/* Footer Section */}
            <div className="bg-ghBlack p-4 pt-3 absolute zIndex-20 bottom-0 w-full text-gray-400 hover:text-white flex justify-end px-10">
                <button onClick={() => {
                    OpenURL("https://github.com/Accenture/kx.as.code")
                }}>
                    <GitHubIcon fontSize="small" />
                </button>
            </div>
        </div>

    );
}

const MenuItem = ({ menuItemName, slug, isBuildStarted }) => {

    useEffect(() => {

    }, [isBuildStarted]);

    const getMenuItemIcon = (menuItemName) => {
        switch (menuItemName) {
            case "home":
                return <TipsAndUpdatesIcon fontSize="small" />
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
                return <RocketLaunchIcon fontSize="small" />
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
            default:
                break;
        }
    }

    return (
        <Link to={`/${menuItemName}`} className="flex justify-center">
            <ListItemButton
                sx={{
                    justifyContent: open ? "initial" : "center",
                    px: 1.5,
                    backgroundColor: slug == menuItemName ? "#5a86ff" : "",
                    margin: "9px",
                    borderRadius: "3px",
                    marginTop: "0px",
                    "&:hover": {
                        backgroundColor: slug == menuItemName ? "#5a86ff" : "",
                    },
                }}
            >
                <ListItemIcon
                    className="listItemIconContainer items-center flex"
                    sx={{
                        minWidth: 0,
                        mr: open ? 3 : "auto",
                    }}
                >
                    {getMenuItemIcon(menuItemName)}
                    <span className="ml-6 capitalize">{menuItemName}</span>
                </ListItemIcon>
            </ListItemButton>
        </Link>
    );
};