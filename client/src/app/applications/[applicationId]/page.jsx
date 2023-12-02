"use client"
import React, { useState, useEffect } from "react";
import axios from "axios";
import { useRouter } from 'next/navigation'
// import AppLogo from "../partials/applications/AppLogo";
import AppTaskComponent from "../ApplicationTaskComponent"
import ScreenshotCarroussel from "./ScreenshotCarroussel";
import AppLogo from "../AppLogo";
import { FaArrowAltCircleDown } from "react-icons/fa";
import { usePathname } from 'next/navigation'
import ApplicationStatusActionButton from "../ApplicationStatusActionButton";

export default function ApplicationDetail(props) {

    const [appData, setAppData] = useState([]);
    const [availableTasksList, setAvailableTasksList] = useState([]);

    const pathname = usePathname()
    const pathnames = pathname.split("/").filter((x) => x);
    const slug = pathnames[pathnames.length - 1];

    const checkApplicationIsInPendingQueue = async (name) => {
        try {
            const response = await axios.get("http://localhost:5001/api/queues/pending_queue");

            const isInPendingQueue = response.data.some((item) => {
                try {
                    const payloadObj = JSON.parse(item.payload);
                    return payloadObj.name === name;
                } catch (error) {
                    console.error("Error parsing payload:", error);
                    return false;
                }
            });

            return isInPendingQueue;
        } catch (error) {
            console.error("Error checking pending queue:", error);
            return false;
        }
    };

    const fetchAppData = () => {
        console.log("slug:   ", slug)
        axios
            .get("http://localhost:5001/api/applications/" + slug)
            .then((response) => {
                console.log("appDetails: ", response.data);
                setAppData(response.data);
                if (response.data.hasOwnProperty("available_tasks")) {
                    console.log("available_tasks: ", response.data.available_tasks);
                    setAvailableTasksList(response.data.available_tasks);
                }
            });
    };

    // TODO clean up -> Dublicate Code
    const getApplicationDataByName = async () => {
        try {
            const respoonseData = await axios.get(
                "http://localhost:5001/api/applications/" + appData.name
            );
            return respoonseData.data;
        } catch (error) {
            console.log("Error: ", error);
        }
    };

    // TODO Rewrite all Installation / Execution Handler in one function with different parameters
    const taskExecutionHandler = async (taskName) => {
        // notify("install"); -> TODO: notifier for exutable tasks
        getApplicationDataByName().then((appData) => {
            var payloadObj = {
                install_folder: appData.installation_group_folder,
                name: appData.name,
                task: taskName, // TODO: pass task
                action: "executeTask",
                retries: "0",
            };
            const applicationPayload = payloadObj;

            // TODO rewrite Endpoint to add install and exe actions to pending_queue via POST
            axios
                .post(
                    "http://localhost:5001/api/add/application/pending_queue",
                    applicationPayload
                )
                .then(() => {
                    // setAppQueue("pending_queue");
                    // props.fetchQueueData();
                    // props.fetchApplicationAndQueueData();
                })
                .then(() => {
                    // setTimeout(() => {
                    //   refreshActionButton.current();
                    // }, 2000);
                })
                .catch((error) => {
                    console.error("There was an error!", error);
                });
        });
    };

    const drawAwailableTasksComponents = () => {
        return availableTasksList.map((task, i) => {
            return (
                <AppTaskComponent
                    checkApplicationIsInPendingQueue={checkApplicationIsInPendingQueue}
                    key={i}
                    task={task}
                    taskExecutionHandler={taskExecutionHandler}
                    appData={appData}
                />
            );
        });
    };

    useEffect(() => {
        fetchAppData();
    }, []);

    if (!appData.name) {
        // If appData.name is undefined, do not render the component
        return null;
    }

    return (
        <div className="px-3 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto bg-ghBlack">
            {/* Header */}
            <div className="grid grid-cols-12 items-center">
                {/* Header left */}
                <div className="col-span-9 bg-ghBlack2 p-5">
                    <div className="text-white bg-ghBlack4 py-0.5 p-2 mb-2 uppercase w-fit inline-block text-base font-bold">
                        {appData.installation_group_folder}
                    </div>
                    <div className="flex items-center">
                        <div className="mr-4">
                            <AppLogo height={"100px"} width={"100px"} appName={appData.name} />
                        </div>
                        <div className="">
                            <div className="flex items-center">
                                <div className="text-4xl uppercase font-extrabold">{appData.name} </div>
                                {appData.environment_variables && appData.environment_variables.imageTag && (
                                    <div className="ml-3 p-2 py-0.5 bg-kxBlue2 text-sm">
                                        {appData.environment_variables.imageTag}
                                    </div>
                                )}

                            </div>

                            <div className="text-base text-gray-400">{appData.Description}</div>
                        </div>

                    </div>

                    {/* Categories */}
                    <div className="mt-3">
                        {appData.categories ? appData.categories.map((item, i) => {
                            return (<span className="bg-ghBlack4 p-2 py-1 mr-0.5 text-sm">{item}</span>)
                        }) : null}
                    </div>
                </div>

                {/* Header right */}
                <div className="flex col-span-3 bg-ghBlack2 ml-5 p-5 h-full">
                    <h2 className="mb-3 text-base"></h2>

                </div>
                {/* right section header */}
                <div className="col-span-2 justify-end flex">
                    {/* <ApplicationStatusActionButton
                        isMqConnected={props.isMqConnected}
                        getQueueStatusList={props.getQueueStatusList}
                        appName={props.app.name}
                        category={props.app.installation_group_folder}
                        applicationInstallHandler={applicationInstallHandler}
                        applicationUninstallHandler={applicationUninstallHandler}
                    /> */}

                </div>
            </div>

            {/* Header Section 2 */}

            <div className="grid grid-cols-12 mt-5">
                <div className="col-span-8 bg-ghBlack2 p-5 mr-5">
                    <h2 className="mb-3 text-xl uppercase font-extrabold text-gray-400">Screenshots</h2>
                    <ScreenshotCarroussel appName={appData.name} />
                </div>
                <div className="col-span-4 p-5 bg-ghBlack2">
                    <h2 className="mb-3 uppercase text-gray-400 font-extrabold text-xl">Executable Tasks</h2>
                    {availableTasksList.length > 0 ? (
                        drawAwailableTasksComponents()
                    ) : (
                        <div className="text-base text-gray-400">No Tasks available.</div>
                    )}
                </div>
            </div>
        </div>
    );
}