import React, { useState, useEffect, useRef } from 'react';
import homeImg from "./assets/media/svg/home-image-animate.svg"
import logo from "./assets/images/ks-logo-w.svg"
import { DataArray, Layers, People, PrecisionManufacturing } from '@mui/icons-material';
import RocketLaunch from '@mui/icons-material/RocketLaunch';
import { Link } from "react-router-dom";
import jenkinsLogo from "./assets/media/png/appImgs/jenkins.png";
import argocdLogo from "./assets/media/png/appImgs/argocd.png";
import giteaLogo from "./assets/media/png/appImgs/gitea.png";
import kubernetesLogo from "./assets/media/png/appImgs/kubernetes.png";
import elasticheartbeatLogo from "./assets/media/png/appImgs/elastic-heartbeat.png";
import openlensLogo from "./assets/media/png/appImgs/openlens.png";
import prometheusLogo from "./assets/media/png/appImgs/prometheus.png";




export default function Home() {

    useEffect(() => {

    }, []);

    return (
        <div className='bg-ghBlack2 p-5 text-base'>
            <div className='grid grid-cols-12 gap-x-3.5 py-10 bg-ghBlack3 p-10 rounded-sm'>
                <div className="col-span-6 ">
                    {/* Intro Title */}
                    <div className="text-3xl font-extralight leading-tight mb-5 text-left">
                        <div className="flex items-center mb-2">
                            <img src={logo} height={40} width={40} alt="KX.AS.Code Logo" />
                            <div className='text-2xl text-white'>KX.AS.Code</div>
                        </div>
                        <div className="text-kxBlue font-extrabold">Transfer Knowledge as Code</div>
                    </div>

                    {/* Intro Text */}
                    <div className="tracking-wide text-justify">
                        Learn and share knowledge. Use it for demoing new technologies,
                        tools and processes. Keep your physical workstation clean whilst
                        experimenting. Have fun playing around with new technologies and use
                        it as an accompaniment to trainings and certifications. Experiment
                        and innovate.
                    </div>

                </div>
                <div className="col-span-6 flex justify-center items-center relative">
                    <div className='h-full w-full m-10 rounded-2xl bg-ghBlack4/50'></div>
                    <img src={homeImg} className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-0" style={{ height: '400px', width: '400px' }} alt="Home" />
                </div>
            </div>

            <div className='text-center p-10 py-5'>
                <div className='mb-2 text-gray-400 font-semibold'>Explorer Applications</div>
                <div className="flex items-center mb-2 justify-center">
                    <Link to={"/applications/argocd"} className='m-3 mr-1 size-[50px]'>
                        <img src={argocdLogo} alt="" />
                    </Link>
                    <Link to={"/applications/gitea"} className='m-3 mr-1 size-[50px]'>
                        <img src={giteaLogo} alt="" />
                    </Link>
                    <Link to={"/applications/kubernetes"} className='m-3 mr-1 size-[50px]'>
                        <img src={kubernetesLogo} alt="" />
                    </Link>
                    <Link to={"/applications/elasticheartbeat"} className='m-3 mr-1 size-[50px]'>
                        <img src={elasticheartbeatLogo} alt="" />
                    </Link>
                    <Link to={"/applications/openlens"} className='m-3 mr-1 size-[50px]'>
                        <img src={openlensLogo} alt="" />
                    </Link>
                    <Link to={"/applications/prometheus"} className='m-3 mr-1 size-[50px]'>
                        <img src={prometheusLogo} alt="" />
                    </Link>
                </div>
                <div className=''>
                    <Link to={"/applications"} className='bg-ghBlack4 p-2 px-10 rounded-sm'>Show All Applications</Link>
                </div>

            </div>

            <div className="grid grid-cols-12 gap-4 mt-5">
                <div className="col-span-6 bg-ghBlack3 rounded-sm p-10 items-center text-left">
                    <div className='mb-2 text-lg font-bold text-kxBlue'>Build & Deploy KX.AS.Code</div>
                    <div className="tracking-wide text-justify mb-5">
                        Configure Build & Deployment Settings to start Build & Deployment process.
                    </div>
                    <div className='flex justify-start'>
                        <Link to={"/build"} className='bg-kxBlue hover:bg-kxBlue2 p-2 rounded-sm px-5 mr-1 items-center flex'>
                            <PrecisionManufacturing fontSize='small' />
                            <span className='ml-2'>Build</span>
                        </Link>
                        <Link to={"/deploy"} className='bg-kxBlue hover:bg-kxBlue2 p-2 rounded-sm px-5 items-center flex'>
                            <RocketLaunch fontSize='small' />
                            <span className='ml-2'>Deployment</span>
                        </Link>
                    </div>
                </div>
                <div className="col-span-6 bg-ghBlack3 rounded-sm items-center text-left p-10">
                    <div className='mb-2 text-lg font-bold text-kxBlue'>Config Groups</div>
                    <div className="tracking-wide text-justify mb-5">
                        Create Config Groups and integrate them in your KX.AS.Code Deployment.
                    </div>
                    <div className='flex justify-start overflow-x-scroll overflow-hidden custom-scrollbar pb-2'>
                        <Link to={"/application-groups"} className='bg-kxBlue hover:bg-kxBlue2 p-2 rounded-sm px-5 mr-1 items-center flex justify-center'>
                            <Layers fontSize='small' />
                            <span className='ml-2 whitespace-nowrap'>Application Groups</span>
                        </Link>
                        <Link to={"/user-groups"} className='bg-kxBlue hover:bg-kxBlue2 p-2 rounded-sm px-5 items-center flex mr-1 justify-center'>
                            <People fontSize='small' />
                            <span className='ml-2 whitespace-nowrap'>User Groups</span>
                        </Link>
                        <Link to={"/custom-variable-groups"} className='bg-kxBlue hover:bg-kxBlue2 p-2 rounded-sm px-5 items-center flex justify-center'>
                            <DataArray fontSize='small' />
                            <span className='ml-2 whitespace-nowrap'>Custom Variable Groups</span>
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    );

};