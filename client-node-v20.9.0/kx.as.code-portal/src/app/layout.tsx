'use client';
import React, { useState, useEffect } from "react";
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import Header from "../app/components/Header";
import ThemeRegistry from './ThemeRegistry';
// import Sidebar from "./components/Sidebar"

import { styled, useTheme, Theme, CSSObject } from '@mui/material/styles';
import Box from '@mui/material/Box';
import MuiDrawer from '@mui/material/Drawer';
import MuiAppBar, { AppBarProps as MuiAppBarProps } from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import List from '@mui/material/List';
import CssBaseline from '@mui/material/CssBaseline';
import Typography from '@mui/material/Typography';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import ChevronLeftIcon from '@mui/icons-material/ChevronLeft';
import ChevronRightIcon from '@mui/icons-material/ChevronRight';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import InboxIcon from '@mui/icons-material/MoveToInbox';
import MailIcon from '@mui/icons-material/Mail';
import { BrowserRouter as Router } from "react-router-dom";
import { MdDashboard } from "react-icons/md";
import Image from 'next/image'
import { black } from "tailwindcss/colors";
import Link from "next/link";
import { LiaCubesSolid } from "react-icons/lia";
import { IoSettingsSharp } from "react-icons/io5";




const inter = Inter({ subsets: ['latin'] })


const drawerWidth = 240;

const openedMixin = (theme: Theme): CSSObject => ({
  width: drawerWidth,
  transition: theme.transitions.create('width', {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.enteringScreen,
  }),
  overflowX: 'hidden',
});

const closedMixin = (theme: Theme): CSSObject => ({
  transition: theme.transitions.create('width', {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.leavingScreen,
  }),
  overflowX: 'hidden',
  width: `calc(${theme.spacing(7)} + 1px)`,
  [theme.breakpoints.up('sm')]: {
    width: `calc(${theme.spacing(8)} + 1px)`,
  },
});

const DrawerHeader = styled('div')(({ theme }) => ({
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'flex-end',
  padding: theme.spacing(0, 1),
  // necessary for content to be below app bar
  ...theme.mixins.toolbar,
}));

interface AppBarProps extends MuiAppBarProps {
  open?: boolean;
}

const AppBar = styled(MuiAppBar, {
  shouldForwardProp: (prop) => prop !== 'open',
})<AppBarProps>(({ theme, open }) => ({
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

const Drawer = styled(MuiDrawer, { shouldForwardProp: (prop) => prop !== 'open' })(
  ({ theme, open }) => ({
    width: drawerWidth,
    flexShrink: 0,
    whiteSpace: 'nowrap',
    boxSizing: 'border-box',
    ...(open && {
      ...openedMixin(theme),
      '& .MuiDrawer-paper': openedMixin(theme),
    }),
    ...(!open && {
      ...closedMixin(theme),
      '& .MuiDrawer-paper': closedMixin(theme),
    }),
  }),
);



export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {

  const theme = useTheme();
  const [open, setOpen] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const drawerWidth = 240;


  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  return (
    <html lang="en">
      <body className={`${inter.className} bg-ghBlack mt-16`}>
        <ThemeRegistry options={{ key: 'mui' }}>
          <Drawer variant="permanent" open={open} className="bg-kxBlue" >
            <DrawerHeader className="">
              <IconButton onClick={handleDrawerClose}>
                {theme.direction === 'rtl' ? <ChevronRightIcon /> : <ChevronLeftIcon />}
              </IconButton>
            </DrawerHeader>
            <List className="">
              <ListItem key={"Dashboard"} disablePadding sx={{ display: 'block' }}>
                <Link href="/dashboard">
                  <ListItemButton
                    sx={{
                      minHeight: 40,
                      justifyContent: open ? 'initial' : 'center',
                      px: 2.5,
                    }}
                  >
                    <ListItemIcon
                      sx={{
                        minWidth: 0,
                        mr: open ? 3 : 'auto',
                        justifyContent: 'center',
                      }}
                    >
                      <MdDashboard className="text-3xl" />
                    </ListItemIcon>
                    <ListItemText primary={"Dashboard"} sx={{ opacity: open ? 1 : 0 }} />
                  </ListItemButton>
                </Link>
              </ListItem>
              <ListItem key={"applications"} disablePadding sx={{ display: 'block' }}>
              <Link href="/applications">
                <ListItemButton
                  sx={{
                    minHeight: 40,
                    justifyContent: open ? 'initial' : 'center',
                    px: 2.5,
                  }}
                >
                  <ListItemIcon
                    sx={{
                      minWidth: 0,
                      mr: open ? 3 : 'auto',
                      justifyContent: 'center',
                    }}
                  >
                    <Image className=""
                      src="/media/svg/ks-logo-w.svg"
                      width={40}
                      height={40}
                      alt="Picture of the author"
                    />
                  </ListItemIcon>
                  <ListItemText primary={"Applications"} sx={{ opacity: open ? 1 : 0, marginLeft: "-10px" }} />
                </ListItemButton>
                </Link>
              </ListItem>
              <ListItem key={"Application Groups"} disablePadding sx={{ display: 'block' }}>
                <Link href="/application-groups">
                  <ListItemButton
                    sx={{
                      minHeight: 40,
                      justifyContent: open ? 'initial' : 'center',
                      px: 2.5,
                    }}
                  >
                    <ListItemIcon
                      sx={{
                        minWidth: 0,
                        mr: open ? 3 : 'auto',
                        justifyContent: 'center',
                      }}
                    >
                      <LiaCubesSolid className="text-3xl" />
                    </ListItemIcon>
                    <ListItemText primary={"Application Groups"} sx={{ opacity: open ? 1 : 0 }} />
                  </ListItemButton>
                </Link>
              </ListItem>
              <ListItem key={"Settings"} disablePadding sx={{ display: 'block' }}>
                <Link href="/settings">
                  <ListItemButton
                    sx={{
                      minHeight: 40,
                      justifyContent: open ? 'initial' : 'center',
                      px: 2.5,
                    }}
                  >
                    <ListItemIcon
                      sx={{
                        minWidth: 0,
                        mr: open ? 3 : 'auto',
                        justifyContent: 'center',
                      }}
                    >
                      <IoSettingsSharp className="text-3xl" />
                    </ListItemIcon>
                    <ListItemText primary={"Settings"} sx={{ opacity: open ? 1 : 0 }} />
                  </ListItemButton>
                </Link>
              </ListItem>
            </List>
          </Drawer>
          <Header drawerWidth={drawerWidth} handleDrawerOpen={handleDrawerOpen} open={open} />
          {/* Sidebar */}
          {/* <Sidebar sidebarOpen={sidebarOpen} setSidebarOpen={setSidebarOpen} /> */}
          {children}
        </ThemeRegistry>
      </body>
    </html>
  )
}
