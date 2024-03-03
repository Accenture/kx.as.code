import React, { useState, useRef, useEffect } from 'react';
import './app.css';
import "pure-react-carousel/dist/react-carousel.es.css";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";
import LayersIcon from '@mui/icons-material/Layers';
import ContextMenu from "./ContextMenu";
import DeleteForever from '@mui/icons-material/DeleteForever';
import MoreVertIcon from '@mui/icons-material/MoreVert';
import { IconButton } from '@mui/material';
import { ContentCopy } from '@mui/icons-material';

export function ApplicationGroupCard(props) {

    const [contextMenu, setContextMenu] = useState(null);
    const parentRef = useRef();
    const buttonRef = useRef();
    const popoverRef = useRef();
    const [isCardHovered, setIsCardHovered] = useState(false);
    const [isMoreMenuActive, setIsMoreMenuActive] = useState(false);

    const appGroupBreadcrumb = props.appGroup.title
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());

    const [appGroupComponents, setAppGroupComponents] = useState([]);
    const [itemsList, setItemsList] = useState([]);

    useEffect(() => {
        fetchAllComponents(props.appGroup.action_queues);

        const handleClickOutside = (event) => {
            if (parentRef.current && !parentRef.current.contains(event.target)) {
                if (!buttonRef.current || !buttonRef.current.contains(event.target)) {
                    setContextMenu(null);
                }
            }

            if (popoverRef.current && !popoverRef.current.contains(event.target)) {
                setIsMoreMenuActive(false)
            }
        };

        document.addEventListener('mousedown', handleClickOutside);

        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, [props.appGroup, props.selectedId, props.id]);

    const handleContextMenu = (e) => {
        e.preventDefault();
        setContextMenu({ top: e.clientY, left: e.clientX });
    };

    const handleCloseContextMenu = () => {
        setContextMenu(null);
    };

    const handleDeleteButtonClick = () => {
        props.removeApplicationGroupById(props.id)
        handleCloseContextMenu();
        setIsMoreMenuActive(false)
    };

    async function fetchAllComponents(action_queues) {
        const components = action_queues.install.map((q) => q.name);
        setImageList(components);
        setAppGroupComponents(components);
    }

    const setImageList = (appGroupComponents) => {
        setItemsList([]);

        appGroupComponents.forEach((appName, i) => {
            setItemsList((current) => [
                ...current,
                <span className="slider-image-container min-h-12 w-12 relative" key={i}>
                    <img
                        alt=""
                        className="object-contain max-h-8 min-h-8"
                        src={`/src/assets/media/png/appImgs/${appName}.png`}
                        role="presentation"
                    />
                </span>,
            ]);
        });
    };

    const drawApplicationGroupCardComponentsTags = (appGroupComponentTags) => {
        return appGroupComponentTags.map((appGroupComponent, i) => (
            <li
                key={i}
                className="bg-gray-500 text-sm mr-1.5 mb-2 px-1.5 w-auto inline-block"
            >
                {appGroupComponent
                    .replaceAll("-", " ")
                    .replace(/\b\w/g, (l) => l.toUpperCase())}
            </li>
        ));
    };

    return (
        <div className={`flex grid grid-cols-12 items-center w-full py-1 px-3 items-center mb-1 ${props.selectedId == props.id ? "" : "hover:bg-ghBlack3"} ${props.selectedId == props.id ? "bg-ghBlack4" : ""} rounded cursor-pointer`}
            onClick={(e) => {
                props.selectedId !== props.id && props.handleDivClick(props.id)
                props.setCurrentId(props.id)
                handleCloseContextMenu()
            }}
            onMouseEnter={() => {
                setIsCardHovered(true)
            }}
            onMouseLeave={() => {
                setIsCardHovered(false)
            }}>
            <div ref={parentRef} onContextMenu={handleContextMenu} className="col-span-12 flex items-center justify-between">
                <div className='flex items-center'>
                    <LayersIcon fontSize="medium" className="mr-2" />
                    <div className="">
                        <div className='whitespace-nowrap w-[150px] overflow-hidden text-ellipsis'>{props.appGroup.title}</div>
                        <div className='text-xs uppercase text-gray-400'>{props.appGroup.action_queues.install[0] !== undefined ? props.appGroup.action_queues.install[0].install_folder : "Group Category"}</div>
                    </div>
                </div>
                <div className='text-white relative'>
                    {isCardHovered || isMoreMenuActive ? (
                        <IconButton onClick={() => {
                            setIsMoreMenuActive((prevIsMoreMenuActive) => !prevIsMoreMenuActive);
                        }}>
                            <MoreVertIcon fontSize='small'/>
                        </IconButton>
                    ) : null}
                    {/* More Menu Popover */}
                    {isMoreMenuActive && (
                        <div ref={popoverRef}
                            className="absolute top-full right-0 z-50 rounded bg-ghBlack shadow-md rounded-md w-auto p-1 text-sm"
                        >
                            <button className='bg-ghBlack2 hover:bg-ghBlack4 text-white p-2 px-3 py-1 rounded w-full flex items-center'
                                onClick={() => {
                                    handleDeleteButtonClick()
                                }}>
                                <span className='mr-1'>
                                    <DeleteForever fontSize='small' />
                                </span>
                                <span>Delete</span>

                            </button>
                            <button className='bg-ghBlack2 hover:bg-ghBlack4 text-white p-2 px-3 py-1 rounded w-full flex items-center'
                                onClick={() => {
                                    handleDeleteButtonClick()
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
            {contextMenu && (
                <ContextMenu
                    top={contextMenu.top}
                    left={contextMenu.left}
                    onClose={handleCloseContextMenu}
                >
                    <button ref={buttonRef} className='bg-ghBlack2 hover:bg-ghBlack4 text-white p-1 rounded w-full flex items-center'
                        onClick={() => {
                            handleDeleteButtonClick()
                        }}>
                        <span className='mr-1'>
                            <DeleteForever fontSize='small' />
                        </span>
                        <span>Delete</span>

                    </button>
                </ContextMenu>
            )}
        </div>)
        ;
}
