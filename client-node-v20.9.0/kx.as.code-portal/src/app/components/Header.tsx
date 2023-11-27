import React, { FC } from "react";
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
import Image from 'next/image'
import Link from "next/link";
const versions = require("../../data/versions.json");



interface HeaderProps {
  open: boolean;
  handleDrawerOpen: () => void;
  drawerWidth?: number;
}

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
    marginLeft: 240,
    width: `calc(100% - 240px)`,
    transition: theme.transitions.create(['width', 'margin'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
  }),
}));

const Header: FC<HeaderProps> = (props) => {
  return (
    <AppBar position="fixed" open={props.open} className="" elevation={0}>
      <Toolbar className="bg-ghBlack3">
        <IconButton
          color="inherit"
          aria-label="open drawer"
          onClick={props.handleDrawerOpen}
          edge="start"
          sx={{
            borderRadius: 0,
            marginRight: 5,
            ...(props.open && { display: 'none' }),
          }}
        >
          <MenuIcon className=""/>
        </IconButton>
        <Link href="/">
          <Image
            src="/media/svg/ks-logo-w.svg"
            width={50}
            height={50}
            alt="Picture of the author"
          />
          </Link>
          <div className="text-sm">Portal v.{versions.kxascode}</div>
      </Toolbar>
    </AppBar>
  );
};

export default Header;
