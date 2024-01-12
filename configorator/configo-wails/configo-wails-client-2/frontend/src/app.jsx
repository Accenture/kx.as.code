import { useState, useEffect } from "preact/hooks";
import './app.css';
import { Header } from "./Header";
import { HeaderNew } from "./HeaderNew";
import Footer from "./Footer";
import { Form2 } from "./Form2";
import { Routes, Route, Link, useLocation } from "react-router-dom";
import TabMenu from "./TabMenu";
import TabMenuBuild from "./TabMenuBuild";
import TabMenuDeploy from "./TabMenuDeploy";
import Home from "./Home";
import { createTheme, ThemeProvider, styled } from '@mui/material/styles';
import { ConsoleOutput } from "./ConsoleOutput";
import Box from "@mui/material/Box";
import MuiDrawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
import { MdDashboard } from "react-icons/md";
import PrecisionManufacturingIcon from '@mui/icons-material/PrecisionManufacturing';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import HomeIcon from '@mui/icons-material/Home';
import Tooltip from '@mui/material/Tooltip';


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

const drawerWidth = 240;


export function App() {

    const [open, setOpen] = useState(false);
    const [isDarkMode, setIsDarkMode] = useState(true);
    const location = useLocation();
    const pathnames = location.pathname.split("/").filter((x) => x);
    const slug = pathnames[pathnames.length - 1];

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
        components: {},
        shape: {
            borderRadius: 0,
        },
        palette: {
            mode: isDarkMode ? "dark" : "light",
            primary: {
                main: '#5a86ff',
            }
        },
    });

    useEffect(() => {
        console.log("pathnames: ", pathnames);

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

        return () => {
            window.removeEventListener('popstate', handleLocationChange);
        };
    }, [isDarkMode, pathnames]);


    return (

        <div className="dark:bg-ghBlack bg-gray-200 h-screen">
            <ThemeProvider theme={theme}>
                <Box sx={{ display: "flex" }}>
                    <Drawer variant="permanent" open={open}>
                        <DrawerHeader className="">
                            <IconButton onClick={handleDrawerClose}>
                                {theme.direction === "rtl" ? <ChevronRightIcon /> : <ChevronLeftIcon />}
                            </IconButton>
                        </DrawerHeader>
                        <List className="" style={{ paddingTop: "0" }}>

                            <Link to="/home">
                                <Tooltip title="Home" placement="right">
                                    <ListItemButton
                                        sx={{
                                            minHeight: 40,
                                            justifyContent: open ? "initial" : "center",
                                            px: 2.5,
                                            backgroundColor: slug == "home" ? "#5a86ff" : "",
                                            "&:hover": {
                                                backgroundColor: slug == "home" ? "#5a86ff" : "",
                                            },
                                        }}
                                    >
                                        <ListItemIcon
                                            className="listItemIconContainer"
                                            sx={{
                                                minWidth: 0,
                                                mr: open ? 3 : "auto",
                                                justifyContent: "center",
                                            }}
                                        >
                                            <HomeIcon className="text-3xl" />
                                        </ListItemIcon>
                                    </ListItemButton>
                                </Tooltip>
                            </Link>

                            <Link to="/build">
                                <Tooltip title="Build" placement="right">

                                    <ListItemButton
                                        sx={{
                                            minHeight: 40,
                                            justifyContent: open ? "initial" : "center",
                                            px: 2.5,
                                            backgroundColor: slug == "build" ? "#5a86ff" : "",
                                            "&:hover": {
                                                backgroundColor: slug == "build" ? "#5a86ff" : "",
                                            },
                                        }}
                                    >
                                        <ListItemIcon
                                            className="listItemIconContainer"
                                            sx={{
                                                minWidth: 0,
                                                mr: open ? 3 : "auto",
                                                justifyContent: "center",
                                            }}
                                        >
                                            <PrecisionManufacturingIcon className="text-3xl" />

                                        </ListItemIcon>
                                    </ListItemButton>
                                </Tooltip>
                            </Link>

                            <Link to="/deploy">
                                <Tooltip title="Deployment" placement="right">

                                    <ListItemButton
                                        sx={{
                                            minHeight: 40,
                                            justifyContent: open ? "initial" : "center",
                                            px: 2.5,
                                            backgroundColor: slug == "deploy" ? "#5a86ff" : "",
                                            "&:hover": {
                                                backgroundColor: slug == "deploy" ? "#5a86ff" : "",
                                            },
                                        }}
                                    >
                                        <ListItemIcon
                                            className="listItemIconContainer"
                                            sx={{
                                                minWidth: 0,
                                                mr: open ? 3 : "auto",
                                                justifyContent: "center",
                                            }}
                                        >
                                            <RocketLaunchIcon className="text-3xl" />


                                        </ListItemIcon>
                                    </ListItemButton>
                                </Tooltip>
                            </Link>


                        </List>
                    </Drawer>
                    <Box component="main" sx={{ flexGrow: 1, p: 0 }} className="text-black dark:text-white">
                        <HeaderNew drawerWidth={drawerWidth} handleDrawerOpen={handleDrawerOpen} open={open} handleDarkModeToggle={handleDarkModeToggle} isDarkMode={isDarkMode} />

                        <Routes>
                            {/* <Route exact path="/" element={<TabMenu />} /> */}
                            <Route path="/home" element={<Home />} />
                            <Route path="/build" element={<TabMenuBuild />} />
                            <Route path="/deploy" element={<TabMenuDeploy />} />
                            <Route path="/console-output" element={<ConsoleOutput />} />
                        </Routes>

                    </Box>
                </Box>
            </ThemeProvider>
            {/* <Footer /> */}
        </div >

    );
}
