import React, { useState, useEffect } from "react";
// import { Inter } from "next/font/google";
// import "./globals.css";
import Header2 from "./Header2";
import ThemeRegistry from "./ThemeRegistry";
import { styled, useTheme, Theme, CSSObject } from "@mui/material/styles";
import Box from "@mui/material/Box";
import MuiDrawer from "@mui/material/Drawer";
import MuiAppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import List from "@mui/material/List";
import CssBaseline from "@mui/material/CssBaseline";
import Typography from "@mui/material/Typography";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import MenuIcon from "@mui/icons-material/Menu";
import ChevronLeftIcon from "@mui/icons-material/ChevronLeft";
import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import ListItem from "@mui/material/ListItem";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import ListItemText from "@mui/material/ListItemText";
// import Image from "next/image";
// import { MdDashboard } from "react-icons/md";
// import { LiaCubesSolid } from "react-icons/lia";
// import { IoSettingsSharp } from "react-icons/io5";
// import Tooltip from "@mui/material/Tooltip";
import { withStyles } from "@mui/styles";
import Zoom from "@mui/material/Zoom";
// import { usePathname } from "next/navigation";
import Breadcrumb from "./components/Breadcrumb";
// import "react-toastify/dist/ReactToastify.css";
import { ToastContainer } from "react-toastify";
import KXASCodeNotifications from "./components/KXASCodeNotifications";

const inter = Inter({ subsets: ["latin"] });

const StyledTooltip = withStyles({
  tooltip: {
    fontSize: "14px",
  },
})(Tooltip);

const drawerWidth = 240;

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

const AppBar = styled(MuiAppBar, {
  shouldForwardProp: (prop) => prop !== "open",
})(({ theme, open }) => ({
  zIndex: theme.zIndex.drawer + 1,
  transition: theme.transitions.create(["width", "margin"], {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.leavingScreen,
  }),
  ...(open && {
    marginLeft: drawerWidth,
    width: `calc(100% - ${drawerWidth}px)`,
    transition: theme.transitions.create(["width", "margin"], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
  }),
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

export default function RootLayout({ children }) {
  const theme = useTheme();
  const [open, setOpen] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const pathname = usePathname();
  const pathnames = pathname.split("/").filter((x) => x);
  const slug = pathnames[pathnames.length - 1];

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  return (
    <html lang="en">
      <body className={`${inter.className} bg-ghBlack mt-16 text-base`}>
        <ThemeRegistry options={{ key: "mui" }}>
          <Box sx={{ display: "flex" }}>
            <Drawer variant="permanent" open={open}>
              <DrawerHeader className="">
                <IconButton onClick={handleDrawerClose}>
                  {theme.direction === "rtl" ? <ChevronRightIcon /> : <ChevronLeftIcon />}
                </IconButton>
              </DrawerHeader>
              <List className="" style={{ paddingTop: "0" }}>
                <StyledTooltip
                  title={"Dashboard"}
                  placement="right"
                  enterDelay={1000}
                  TransitionComponent={Zoom}
                  className="hover:cursor-pointer text-md"
                >
                  <ListItem key={"Dashboard"} disablePadding sx={{ display: "block" }}>
                    <Link href="/dashboard">
                      <ListItemButton
                        sx={{
                          minHeight: 40,
                          justifyContent: open ? "initial" : "center",
                          px: 2.5,
                          backgroundColor: slug == "dashboard" ? "#5a86ff" : "",
                          "&:hover": {
                            backgroundColor: slug == "dashboard" ? "#5a86ff" : "",
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
                          <MdDashboard className="text-3xl" />
                        </ListItemIcon>
                        <ListItemText primary={"Dashboard"} sx={{ opacity: open ? 1 : 0 }} />
                      </ListItemButton>
                    </Link>
                  </ListItem>
                </StyledTooltip>
                <StyledTooltip
                  title={"Applications"}
                  placement="right"
                  enterDelay={1000}
                  TransitionComponent={Zoom}
                  className="hover:cursor-pointer text-md"
                >
                  <ListItem key={"applications"} disablePadding sx={{ display: "block" }}>
                    <Link href="/applications">
                      <ListItemButton
                        sx={{
                          minHeight: 40,
                          justifyContent: open ? "initial" : "center",
                          px: 2.5,
                          backgroundColor: pathname.includes("/applications") ? "#5a86ff" : "",
                          "&:hover": {
                            backgroundColor: pathname.includes("/applications") ? "#5a86ff" : "",
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
                          <Image
                            className=""
                            src="/media/svg/ks-logo-w.svg"
                            width={40}
                            height={40}
                            alt="KX.AS.Code Logo"
                          />
                        </ListItemIcon>
                        <ListItemText primary={"Applications"} sx={{ opacity: open ? 1 : 0, marginLeft: "-10px" }} />
                      </ListItemButton>
                    </Link>
                  </ListItem>
                </StyledTooltip>
                <StyledTooltip
                  title={"Application Groups"}
                  placement="right"
                  enterDelay={1000}
                  TransitionComponent={Zoom}
                  className="hover:cursor-pointer text-md"
                >
                  <ListItem key={"Application Groups"} disablePadding sx={{ display: "block" }}>
                    <Link href="/application-groups">
                      <ListItemButton
                        sx={{
                          minHeight: 40,
                          justifyContent: open ? "initial" : "center",
                          px: 2.5,
                          backgroundColor: slug == "application-groups" ? "#5a86ff" : "",
                          "&:hover": {
                            backgroundColor: slug == "application-groups" ? "#5a86ff" : "",
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
                          <LiaCubesSolid className="text-4xl" />
                        </ListItemIcon>
                        <ListItemText primary={"Application Groups"} sx={{ opacity: open ? 1 : 0, marginLeft: "-6px" }} />
                      </ListItemButton>
                    </Link>
                  </ListItem>
                </StyledTooltip>
              </List>
              <List className="text-base" style={{ position: "absolute", bottom: "20px", width: "100%" }}>
                <StyledTooltip
                  title={"Settings"}
                  placement="right"
                  enterDelay={1000}
                  TransitionComponent={Zoom}
                  className="hover:cursor-pointer text-md"
                >
                  <ListItem key={"Settings"} disablePadding sx={{ display: "block" }}>
                    <Link href="/settings">
                      <ListItemButton
                        sx={{
                          minHeight: 40,
                          justifyContent: open ? "initial" : "center",
                          px: 2.5,
                          backgroundColor: slug == "settings" ? "#5a86ff" : "",
                          "&:hover": {
                            backgroundColor: slug == "settings" ? "#5a86ff" : "",
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
                          <IoSettingsSharp className="text-3xl" />
                        </ListItemIcon>
                        <ListItemText primary={"Settings"} sx={{ opacity: open ? 1 : 0 }} />
                      </ListItemButton>
                    </Link>
                  </ListItem>
                </StyledTooltip>
              </List>
            </Drawer>
            <Box component="main" sx={{ flexGrow: 1, p: 0 }}>
              <Header2 drawerWidth={drawerWidth} handleDrawerOpen={handleDrawerOpen} open={open} />
              <ToastContainer
                position="bottom-right"
                autoClose={5000}
                hideProgressBar={false}
                newestOnTop={false}
                closeOnClick
                rtl={false}
                pauseOnFocusLoss
                draggable
                pauseOnHover
              />
              <Breadcrumb />
              <KXASCodeNotifications></KXASCodeNotifications>
              {children}
            </Box>
          </Box>
        </ThemeRegistry>
      </body>
    </html>
  );
}
