import { useState, useEffect } from "preact/hooks";
import './app.css';
import "pure-react-carousel/dist/react-carousel.es.css";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";
import LayersIcon from '@mui/icons-material/Layers';


export function ApplicationGroupCard(props) {

    const appGroupBreadcrumb = props.appGroup.title
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());

    const [appGroupComponents, setAppGroupComponents] = useState([]);
    const [itemsList, setItemsList] = useState([]);

    useEffect(() => {
        fetchAllComponents(props.appGroup.action_queues);
        return () => { };
    }, [props.appGroup, props.selectedId, props.id]);

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
                props.handleDivClick(props.id)
            }}>
            <div className="col-span-12 flex items-center">
                <LayersIcon fontSize="medium" className="mr-2" />
                <div className="">
                    <div className=''>{props.appGroup.title}</div>
                    <div className='text-xs uppercase text-gray-400'>{props.appGroup.action_queues.install[0].install_folder}</div>
                </div>
            </div>
        </div>)
        ;
}
