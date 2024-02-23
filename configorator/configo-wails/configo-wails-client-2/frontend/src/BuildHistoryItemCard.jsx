import { useState, useEffect } from "preact/hooks";
import './app.css';
import "pure-react-carousel/dist/react-carousel.es.css";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";
import LayersIcon from '@mui/icons-material/Layers';
import { RocketLaunch } from "@mui/icons-material";


export default function BuildHistoryItemCard(props) {

    useEffect(() => {
        return () => { };
    }, [props.build, props.selectedId, props.id]);

    return (
        <div className={`flex grid grid-cols-12 items-center w-full py-1 px-3 items-center mb-1 ${props.selectedId == props.id ? "" : "hover:bg-ghBlack3"} ${props.selectedId == props.id ? "bg-ghBlack4" : ""} rounded cursor-pointer`}
            onClick={(e) => {
                props.selectedId !== props.id && props.handleDivClick(props.id)
            }}>
            <div className="col-span-12 flex items-center">
                <RocketLaunch fontSize="medium" className="mr-2" />
                <div className="w-full">
                    <div className=''>{props.build.buildId}</div>
                    <div className="flex justify-between">
                        <div className='text-xs uppercase text-gray-400'>Build</div>
                        <div className='text-xs text-gray-400'>24m ago</div>
                    </div>
                </div>
            </div>
        </div>)
        ;
}
