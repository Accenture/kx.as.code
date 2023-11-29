import React, { useState, useEffect } from 'react';
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import Tooltip from "@mui/material/Tooltip";
import AppLogo from "../applications/AppLogo";
import { formatTimestamp } from '../utils/timestamp';
import { withStyles } from '@mui/styles';
import { transformName } from "../utils/application";

interface HealthcheckInfoBoxProps {
    healthcheckStatus: number;
    timestamp: Date; // Allow null as a valid type
}

const StyledTooltip = withStyles({
    tooltip: {
        fontSize: '14px',
    },
})(Tooltip);

const HealthcheckInfoBox: React.FC<HealthcheckInfoBoxProps> = ({ healthcheckStatus, timestamp }) => {
    let bgColorClass = "";
    if (healthcheckStatus === 200) {
        bgColorClass = 'bg-statusGreen';
    } else if (healthcheckStatus === 0) {
        bgColorClass = 'bg-ghBlack4';
    } else {
        bgColorClass = 'bg-red-500';
    }

    const statusColorBox = <div className={`h-5 mr-1.5 w-full mx-auto ${bgColorClass}`}></div>;

    return (
        healthcheckStatus === 0 ? (statusColorBox) : (
            <StyledTooltip title={`${formatTimestamp(timestamp)}`} placement="top" arrow className='hover:cursor-pointer text-md'>
                {statusColorBox}
            </StyledTooltip>)
    );
};

interface HealthCheckInfoComponentProps {
    appHealthcheckDataArray: any[];
}

const HealthCheckInfoComponent: React.FC<HealthCheckInfoComponentProps> = ({ appHealthcheckDataArray }) => {

    const healthcheckBoxes = appHealthcheckDataArray.slice(0, 120).map((item, index) => (
        <HealthcheckInfoBox key={index} healthcheckStatus={item.status} timestamp={item.timestamp} />
    ));

    const remainingHealthcheckBoxes = Array.from({ length: Math.max(120 - appHealthcheckDataArray.length, 0) }).map((_, index) => (
        // TODO: Update HealthcheckInfoBox -> accept null value for timestamp props
        <HealthcheckInfoBox key={index + appHealthcheckDataArray.length} healthcheckStatus={0} timestamp={new Date('2023-01-15T12:34:56.789Z')} />
    ));

    return <div className="flex justify-start">{[...healthcheckBoxes, ...remainingHealthcheckBoxes]}</div>;
};

const checkIsAppNameInCompletedQueue = (queueData: any[], appName: string) => {
    for (const item of queueData) {
        try {
            const { routing_key, payload } = item;

            if (routing_key === 'notification_queue') {
                continue;
            }

            if (typeof payload !== 'string' || payload.trim() === '') {
                console.error('Invalid payload:', payload);
                continue;
            }

            const { name } = JSON.parse(payload);

            if (typeof name !== 'string' || name.trim() === '') {
                console.error('Invalid name:', name);
                continue;
            }

            if (routing_key === 'completed_queue' && name === appName) {
                return true;
            }
        } catch (error) {
            console.error('Error parsing payload JSON:', error);
            console.error('Problematic payload:', item.payload);
        }
    }
    return false;
};

interface HealthcheckDashboardProps {
    healthCheckData: any[];
}

const HealthcheckDashboard: React.FC<HealthcheckDashboardProps> = (props) => {
    const [isOpenAppsHealthcheckDashboardSection, setIsOpenAppsHealthcheckDashboardSection] = useState(true);
    const [searchTerm, setSearchTerm] = useState("");

    useEffect(() => {

    }, []);

    const filteredAndTransformedApps = Object.keys(props.healthCheckData)
        .filter((app) => {
            const appName = app.toLowerCase().trim();
            return searchTerm === "" || appName.includes(searchTerm.toLowerCase().trim());
        })
        .map((appNameObj: any) => (
            <div key={appNameObj}>
                <div className='bg-ghBlack2 hover:bg-ghBlack3 mb-1 p-3 items-center text-gray-400'>
                    <div className='mb-2'>{transformName(appNameObj)}</div>
                    <HealthCheckInfoComponent appHealthcheckDataArray={props.healthCheckData[appNameObj]} />
                </div>
            </div>
        ));

    return (
        <div className={`mb-5 px-20 bg-ghBlack4 ${isOpenAppsHealthcheckDashboardSection ? "py-5" : "pt-5"} `}>
            {/* Dashboard section header */}
            <div className="flex justify-between items-center pb-5">
                {/* Dashboard section title */}
                <div className="text-base items-center text-gray-400">
                    Application Healthcheck Monitoring
                </div>
                <div className=''>
                    <Button
                        variant="text"
                        size="small"
                        className="h-full text-white bg-ghBlack2 hover:bg-ghBlack3"
                        onClick={() => {
                            setIsOpenAppsHealthcheckDashboardSection(!isOpenAppsHealthcheckDashboardSection);
                        }}
                    >
                        {isOpenAppsHealthcheckDashboardSection ? (
                            <ExpandLessIcon fontSize="small" className="text-white" />
                        ) : (
                            <ExpandMoreIcon fontSize="small" className="text-white" />
                        )}
                    </Button>
                </div>
            </div>

            <div className={`w-full ${isOpenAppsHealthcheckDashboardSection ? "visible" : "hidden"}`}>

                <div className='flex items-center mb-5'>
                    {/* Search Input Field */}
                    <div className="group relative">
                        <svg
                            width="20"
                            height="20"
                            fill="currentColor"
                            className="absolute left-3 top-1/2 -mt-2.5 text-gray-500 pointer-events-none group-focus-within:text-kxBlue"
                            aria-hidden="true"
                        >
                            <path
                                fillRule="evenodd"
                                clipRule="evenodd"
                                d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                            />
                        </svg>
                        <input
                            type="text"
                            placeholder="Search..."
                            className="focus:ring-kxBlue bg-ghBlack2 px-3 py-2 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none focus:outline-none focus:ring-1 min-w-80 pl-10"
                            onChange={(e) => {
                                setSearchTerm(e.target.value);
                            }}
                        />
                    </div>

                    {/* Installed Application Count */}
                    <div className='text-gray-400 text-sm ml-3'>Installed Applications: {Object.keys(props.healthCheckData).length}</div>
                </div>

                <div className={` ${Object.keys(props.healthCheckData).length == 0 ? "h-[100px]" : "h-[400px]"} overflow-auto scrollbar-orange bg-ghBlack3`}>
                    {Object.keys(props.healthCheckData)
                        .filter((app) => {
                            const appName = app.toLowerCase().trim();
                            return searchTerm === "" || appName.includes(searchTerm.toLowerCase().trim());
                        })
                        .map((appNameObj: any) => (
                            <div key={appNameObj}>
                                <div className='bg-ghBlack2 hover:bg-ghBlack3 mb-1 p-3 items-center text-white'>
                                    <div className='mb-2'>{transformName(appNameObj)}</div>
                                    <HealthCheckInfoComponent appHealthcheckDataArray={props.healthCheckData[appNameObj]} />
                                </div>
                            </div>
                        ))}

                    {Object.keys(props.healthCheckData)
                        .filter((app) => {
                            const appName = app.toLowerCase().trim();
                            return searchTerm === "" || appName.includes(searchTerm.toLowerCase().trim());
                        })
                        .length === 0 && searchTerm !== "" && (
                            <div className=''>
                                <div className='mb-2 text-base text-gray-400 pl-3 pt-3'>No results for ' {searchTerm}'</div>
                            </div>
                        )}
                </div>
            </div>
        </div>
    );
};

export default HealthcheckDashboard;
