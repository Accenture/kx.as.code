import { useState, useEffect } from "preact/hooks";
import './app.css';
import "pure-react-carousel/dist/react-carousel.es.css";
import { transformName } from "./utils/application"
import { Link } from "react-router-dom";
import LayersIcon from '@mui/icons-material/Layers';


export function ApplicationGroupCard(props) {

    const [isSelected, setISelected] = useState(false);

    const handleItemSelection = () => {
        setISelected((prevIsSelected) => !prevIsSelected);
    }

    const appGroupBreadcrumb = props.appGroup.title
        .replaceAll(" ", "-")
        .replace(/\b\w/g, (l) => l.toLowerCase());

    const [appGroupComponents, setAppGroupComponents] = useState([]);
    const [itemsList, setItemsList] = useState([]);

    useEffect(() => {
        fetchAllComponents(props.appGroup.action_queues);
        return () => { };
    }, [props.appGroup, isSelected]);

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
        <div className={`flex grid grid-cols-12 items-center w-full py-2 px-6 items-center mb-1 bg-ghBlack4`}>
            <div className="col-span-1">
                <LayersIcon fontSize="large" />
            </div>
            <div className="col-span-4">
                <div className=''>{props.appGroup.title}</div>
                <div className='text-sm uppercase text-gray-400'>{props.appGroup.action_queues.install[0].install_folder}</div>
            </div>
            <div className="col-span-4">

            </div>
        </div>)
        ;
}
