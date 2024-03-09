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

export function ListItemCard({ index, itemData, selectedItem, handleItemClick, handleDeleteItem, handleDublicateItem }) {
    const parentRef = useRef();
    const popoverRef = useRef();
    const [isCardHovered, setIsCardHovered] = useState(false);
    const [isMoreMenuActive, setIsMoreMenuActive] = useState(false);

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
        <div key={index} className={`grid grid-cols-12 w-full py-1 px-2 items-center mb-1 ${selectedItem === index ? "bg-ghBlack4" : "hover:bg-ghBlack3"} rounded-sm cursor-pointer`}
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
                    <LayersIcon fontSize="medium" className="mr-2" />
                    <div className="">
                        <div className='whitespace-nowrap w-[190px] overflow-hidden text-ellipsis'>{itemData.title !== "" ? itemData.title : "No Title"}</div>
                        <div className='text-xs uppercase text-gray-400 text-ellipsis overflow-hidden flex'>
                            {itemData.action_queues.install[0] !== undefined ? (
                                itemData.action_queues.install.length > 1 ? (
                                    <span className='flex'>
                                        {itemData.action_queues.install[0].name}
                                        {itemData.action_queues.install.length > 0 && ` (+${itemData.action_queues.install.length - 1})`}
                                    </span>
                                ) : (
                                    itemData.action_queues.install[0].name
                                )
                            ) : "0 Applications"}
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
