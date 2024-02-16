import { useState, useEffect } from "preact/hooks";
import './app.css';
import {
    CarouselProvider,
    Slider,
    Slide,
    ButtonBack,
    ButtonNext,
} from "pure-react-carousel";
import "pure-react-carousel/dist/react-carousel.es.css";
import { MdArrowBackIosNew, MdArrowForwardIos } from "react-icons/md";
import Tooltip from "@mui/material/Tooltip";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";

export function ApplicationGroupCard(props) {

    const appGroupBreadcrumb = props.appGroup.title
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());

    const [appGroupComponents, setAppGroupComponents] = useState([]);
    const [itemsList, setItemsList] = useState([]);

    useEffect(() => {
        fetchAllComponents(props.appGroup.action_queues);
        return () => { };
    }, [props.appGroup]);

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
                    .replaceAll("_", " ")
                    .replace(/\b\w/g, (l) => l.toUpperCase())}
            </li>
        ));
    };

    return (
        <div className='w-full rounded py-2 px-6 bg-ghBlack4 items-center mb-1'>
            <div className=''>{props.appGroup.title}</div>
            <div className='text-sm uppercase text-gray-400'>{props.appGroup.action_queues.install[0].install_folder}</div>
        </div>)
        ;
}
