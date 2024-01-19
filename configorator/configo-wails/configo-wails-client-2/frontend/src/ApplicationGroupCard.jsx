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
        props.isListLayout ? (
            <div className="col-span-full hover:bg-ghBlack3 bg-ghBlack2 p-2 px-5">
                <div className="grid grid-cols-12">
                    <div className="col-span-4">
                        <Link href={`/application-groups/${appGroupBreadcrumb}`}>
                            <h2
                                className="hover:underline hover:cursor-pointer text-base uppercase text-white truncate"
                            >
                                {props.appGroup.title}
                            </h2>
                        </Link>
                        <div className="text-gray-400 text-sm">
                            {appGroupComponents.length}{" "}
                            {appGroupComponents.length > 1 ? "Applications" : "Application"}
                        </div>
                    </div>
                    <div className="col-span-4">
                        <div className="flex w-auto">
                            <CarouselProvider
                                visibleSlides={5}
                                totalSlides={appGroupComponents.length}
                                step={1}
                                naturalSlideWidth={30}
                                naturalSlideHeight={10}
                            >
                                <div className="flex items-center">
                                    <div className="">
                                        <ButtonBack className="hover:bg-ghBlack4 p-3 text-sm items-center flex">
                                            <MdArrowBackIosNew />
                                        </ButtonBack>
                                    </div>
                                    <div className="w-full items-center flex">
                                        <Slider className="h-10 w-56 items-center mt-2">{itemsList.map((image, i) => {
                                            return (
                                                <Slide index={i} key={i}>
                                                    <Tooltip
                                                        title={transformName(appGroupComponents[i])}
                                                        placement="top"
                                                        arrow
                                                    >
                                                        <Link
                                                            href={"/applications/" + appGroupComponents[i]}
                                                            className=""
                                                        >
                                                            <div className="flex items-center justify-center hover:bg-ghBlack4 hover:pointer" key={i}>
                                                                {image}
                                                            </div>
                                                        </Link>
                                                    </Tooltip>
                                                </Slide>
                                            );
                                        })}</Slider>
                                    </div>
                                    <div className="">
                                        <ButtonNext className="hover:bg-ghBlack4 p-3 text-sm items-center">
                                            <MdArrowForwardIos />
                                        </ButtonNext>
                                    </div>
                                </div>
                            </CarouselProvider>
                        </div>
                    </div>
                    <div className="col-span-5"></div>
                </div>
            </div>) : (
            <div className="col-span-full sm:col-span-6 md:col-span-6 xl:col-span-3 hover:bg-ghBlack3 bg-ghBlack2">
                <div className="relative">
                    <div className="p-6">
                        <div className="pb-4">
                            <header className="items-start">
                                <div className="flex items-center">
                                    <Link href={`/application-groups/${appGroupBreadcrumb}`}>
                                        <h2
                                            className="hover:underline hover:cursor-pointer text-lg font-extrabold uppercase text-white truncate"
                                        >
                                            {props.appGroup.title}
                                        </h2>
                                    </Link>
                                </div>
                                <div className="text-gray-400 text-sm">
                                    {appGroupComponents.length}{" "}
                                    {appGroupComponents.length > 1 ? "Applications" : "Application"}
                                </div>
                            </header>
                        </div>

                        <div className="h-28">
                            <CarouselProvider
                                visibleSlides={4}
                                totalSlides={appGroupComponents.length}
                                step={1}
                                naturalSlideWidth={500}
                                naturalSlideHeight={500}
                            >
                                <div className="flex items-center py-5">
                                    <div className="h-14">
                                        <ButtonBack className="hover:bg-ghBlack4 px-3 text-sm items-center flex h-full">
                                            <MdArrowBackIosNew />
                                        </ButtonBack>
                                    </div>
                                    <div className="w-full">
                                        <Slider className="">{itemsList.map((image, i) => {
                                            return (
                                                <Slide index={i} key={i}>
                                                    <Tooltip
                                                        title={transformName(appGroupComponents[i])}
                                                        placement="top"
                                                        arrow
                                                    >
                                                        <Link
                                                            href={"/applications/" + appGroupComponents[i]}
                                                            className=""
                                                        >
                                                            <div className="flex items-center justify-center hover:bg-ghBlack4 p-1 hover:pointer h-16" key={i}>
                                                                {image}
                                                            </div>
                                                        </Link>
                                                    </Tooltip>
                                                </Slide>
                                            );
                                        })}</Slider>
                                    </div>
                                    <div className="h-14">
                                        <ButtonNext className="hover:bg-ghBlack4 px-3 text-sm items-center flex h-full">
                                            <MdArrowForwardIos />
                                        </ButtonNext>
                                    </div>
                                </div>
                            </CarouselProvider>
                        </div>
                        <Tooltip
                            title={"BETA"}
                            placement="top"
                            arrow
                        >
                            <div className="">

                            </div>
                        </Tooltip>
                    </div>
                </div>
            </div>)
    );
}
