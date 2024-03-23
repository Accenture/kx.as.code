import React, { useState, useEffect, useCallback } from 'react';
import './app.css';
import { Routes, Route, Link, useLocation } from "react-router-dom";
import List from "@mui/material/List";
import ListItemButton from "@mui/material/ListItemButton";
import ListItemIcon from "@mui/material/ListItemIcon";
import PrecisionManufacturingIcon from '@mui/icons-material/PrecisionManufacturing';
import RocketLaunchIcon from '@mui/icons-material/RocketLaunch';
import PeopleIcon from '@mui/icons-material/People';
import DataArrayIcon from '@mui/icons-material/DataArray';
import LayersIcon from '@mui/icons-material/Layers';
import HistoryIcon from '@mui/icons-material/History';
import { Apps, DashboardSharp, Settings } from "@mui/icons-material";
import { IoLayersSharp } from "react-icons/io5";
import { FaUsersViewfinder } from "react-icons/fa6";

export function NavigationHorizontal() {
    const location = useLocation();
    const pathnames = location.pathname.split("/").filter((x) => x);
    const slug = pathnames[pathnames.length - 1];

    const [isBuildStarted, setIsBuildStarted] = useState(false);


    useEffect(() => {

        return () => {

        };

    }, [pathnames]);


    return (
        <div className="relative flex bg-ghBlack3">
            {/* Navigation */}
            <div className="flex">
                <MenuItem menuItemName={"dashboard"} slug={slug} />
                <MenuItem menuItemName={"build"} slug={slug} isBuildStarted={isBuildStarted} />
                <MenuItem menuItemName={"deploy"} slug={slug} />
                {/* Separator */}
                <div className="h-full w-[2px] bg-ghBlack4 my-0"></div>
                <MenuItem menuItemName={"application-groups"} slug={slug} />
                <MenuItem menuItemName={"applications"} slug={slug} />
                <MenuItem menuItemName={"user-groups"} slug={slug} />
                <MenuItem menuItemName={"custom-variable-groups"} slug={slug} />
                <MenuItem menuItemName={"build-history"} slug={slug} />
                <MenuItem menuItemName={"settings"} slug={slug} />
            </div>
            {/* <div className='border-b-[2px] border-ghBlack4 w-full'></div> */}
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
                            className="absolute h-3 w-4 top-[-13px] right-[-18px] mt-2 mr-2 text-white animate-spin"
                            xmlns="http://www.w3.org/2000/svg"
                            fill="none"
                            viewBox="0 0 24 24"
                        >
                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>

                        <PrecisionManufacturingIcon fontSize='small' />
                    </div>) : (<PrecisionManufacturingIcon fontSize='small' />)
                }
            case "deploy":
                return <RocketLaunchIcon fontSize="small" color="inherit" />
            case "application-groups":
                return <IoLayersSharp className='text-[18px]' />
            case "user-groups":
                return <FaUsersViewfinder className="text-[20px]" />
            case "custom-variable-groups":
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
        <Link to={`/${menuItemName}`} className={`${slug === menuItemName ? "border-kxBlue bg-ghBlack3 hover:bg-ghBlack3" : "border-ghBlack hover:border-ghBlack3 hover:bg-ghBlack3"} bg-ghBlack border-b-[2px] p-2 px-3 flex items-center justify-center`}>
            {getMenuItemIcon(menuItemName)}
        </Link>

    );
};