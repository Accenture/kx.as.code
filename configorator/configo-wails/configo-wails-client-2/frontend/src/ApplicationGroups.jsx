import React, { useState, useEffect, useRef } from 'react';
import applicationGroupJson from './assets/templates/applicationGroups.json';
import JSONConfigTabContent from './JSONConfigTabContent';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import { ApplicationGroupsListAndDetail } from './ApplicationGroupsListAndDetail';


export function ApplicationGroups({ }) {

    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [jsonData, setJsonData] = useState([]);
    const [applicationGroupDetailTab, setApplicationGroupDetailTab] = useState("config-ui");
    const [windowHeight, setWindowHeight] = useState(window.innerHeight);

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };

    useEffect(() => {
        const handleResize = () => {
            setWindowHeight(window.innerHeight);
        };
        window.addEventListener('resize', handleResize);

        setJsonData(JSON.stringify(applicationGroupJson, null, 2))

        // Detach event listener on component unmount
        return () => {
            window.removeEventListener('resize', handleResize);
        };

    }, [activeConfigTab, jsonData, applicationGroupDetailTab]);

    return (
        <div className='text-left'>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='dark:bg-ghBlack4'>
                    
                    <ConfigSectionHeader sectionTitle={"Application Groups"} SectionDescription={"More Details about this section here."} setActiveConfigTab={setActiveConfigTab} activeConfigTab={activeConfigTab} contentName={"App Groups"}/>

                    {/* <div className="relative w-full h-[40px] p-1 bg-ghBlack3 rounded">
                        <div className="relative w-full h-full flex items-center">
                            <div
                                onClick={() => setActiveConfigTab('config-tab1')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button className='text-sm'>
                                    Config UI
                                </button>
                            </div>
                            <div
                                onClick={() => setActiveConfigTab('config-tab2')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button className='text-sm'>
                                    JSON
                                </button>
                            </div>
                        </div>

                        <span
                            className={`${activeConfigTab === 'config-tab1'
                                ? 'left-1 ml-0'
                                : 'left-1/2 -ml-1'
                                } py-1 text-white bg-ghBlack4 text-sm flex items-center justify-center w-1/2 rounded-sm transition-all duration-150 ease-linear top-[5px] absolute`}
                        >
                            {activeConfigTab === 'config-tab1'
                                ? "Config UI"
                                : "JSON"}
                        </span>

                    </div> */}

                </div>
            </div>
            <div className="config-tab-content flexGrow">
                <div className='bg-ghBlack2 h-[2px]'></div>

                {activeConfigTab === 'config-tab1' && <ApplicationGroupsListAndDetail activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} applicationGroupDetailTab={applicationGroupDetailTab} setApplicationGroupDetailTab={setApplicationGroupDetailTab} windowHeight={windowHeight} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"applicationGroups.json"} windowHeight={windowHeight} />}
            </div>
        </div>)
};