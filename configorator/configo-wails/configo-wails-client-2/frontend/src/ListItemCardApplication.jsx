import React, { useState, useRef, useEffect } from 'react';
import './app.css';
import "pure-react-carousel/dist/react-carousel.es.css";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";
import LayersIcon from '@mui/icons-material/Layers';
import DeleteForever from '@mui/icons-material/DeleteForever';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import { IconButton } from '@mui/material';
import { ContentCopy } from '@mui/icons-material';
import AppLogo from './AppLogo';

export function ListItemCardApplication({ index, itemData, selectedItem, handleItemClick, handleDeleteItem, handleDublicateItem }) {
    const parentRef = useRef();
    const popoverRef = useRef();
    const [isCardHovered, setIsCardHovered] = useState(false);
    const [isMoreMenuActive, setIsMoreMenuActive] = useState(false);

    const openLinkInNewWindow = (url) => {
        window.open(url, '_blank', 'noopener,noreferrer');
    }

    useEffect(() => {
        const handleClickOutside = (event) => {
            if (popoverRef.current && !popoverRef.current.contains(event.target)) {
                setIsMoreMenuActive(false)
            }
        };

        document.addEventListener('mousedown', handleClickOutside);

        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, [itemData]);

    return (
        <div key={index} className={`grid grid-cols-12 w-full py-1 px-2 items-center ${selectedItem === index ? "bg-ghBlack4 border-l-[2px] border-kxBlue" : "hover:bg-ghBlack3 border-l-[2px] border-ghBlack2 hover:border-ghBlack3"} rounded-sm cursor-pointer`}
            onClick={() => {
                handleItemClick(index)
            }}

            onMouseEnter={() => {
                setIsCardHovered(true)
            }}
            onMouseLeave={() => {
                setIsCardHovered(false)
            }}>
            <div ref={parentRef} className="col-span-12 flex items-center relative">
                <div className='flex items-center'>
                    <AppLogo appName={itemData.name} size={40} />
                    <div className="text-left ml-2">
                        <Link
                            to={`/applications/${itemData.name}`}
                            className={`whitespace-nowrap w-[190px] overflow-hidden text-ellipsis capitalize hover:underline`}
                        >
                            {itemData.name !== "" ? itemData.name : "No Title"}
                        </Link>
                        <div className='text-xs uppercase text-gray-400 text-ellipsis overflow-hidden flex'>
                            {itemData.installation_group_folder ? itemData.installation_group_folder : "Category N/A"}
                        </div>
                    </div>
                </div>
                <div className='text-white absolute right-0'>
                    {isCardHovered || isMoreMenuActive ? (
                        <IconButton onClick={() => {
                            setIsMoreMenuActive((prevIsMoreMenuActive) => !prevIsMoreMenuActive);
                        }}>
                            <MoreVertIcon fontSize='small' />
                        </IconButton>
                    ) : null}
                    {/* More Menu Popover */}
                    {isMoreMenuActive && (
                        <div ref={popoverRef}
                            className="absolute top-full right-0 z-50 bg-ghBlack3 shadow-md rounded-sm w-auto p-1 text-sm"
                        >
                            <button className='hover:bg-ghBlack4 text-white p-2 px-3 py-1 rounded-sm w-full flex items-center'
                                onClick={(e) => {
                                    e.stopPropagation();
                                    handleDeleteItem(index);
                                    setIsMoreMenuActive(false)
                                }}>
                                <span className='mr-1'>
                                    <DeleteForever fontSize='small' />
                                </span>
                                <span>Delete</span>
                            </button>
                            <button className='hover:bg-ghBlack4 text-white p-2 px-3 py-1 rounded-sm w-full flex items-center'
                                onClick={(e) => {
                                    e.stopPropagation();
                                    handleDublicateItem(index);
                                    setIsMoreMenuActive(false)
                                }}>
                                <span className='mr-1'>
                                    <ContentCopy fontSize='small' />
                                </span>
                                <span>Dublicate</span>

                            </button>
                        </div>
                    )}


                </div>
            </div>
        </div>)
        ;
}
