import React, { useState, useEffect } from 'react';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import JSONConfigTabContent from './JSONConfigTabContent';


export default function Applications() {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');

    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };


    useEffect(() => {

    }, [activeConfigTab]);

    return (
        <div className='relative'>
            <div className='grid grid-cols-12 items-center dark:bg-ghBlack4 p-1'>
                <div className='col-span-9'>
                    <ConfigSectionHeader sectionTitle={"Manage Applications"} SectionDescription={"More Details about the Build process here."} />
                </div>
                <div className='col-span-3 pr-10 mx-3'>
                    <div className="relative w-full h-[40px] p-1 bg-ghBlack2 rounded-md">
                        <div className="relative w-full h-full flex items-center text-sm">
                            <div
                                onClick={() => setActiveConfigTab('config-tab1')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button>
                                    Config UI
                                </button>
                            </div>
                            <div
                                onClick={() => setActiveConfigTab('config-tab2')}
                                className="w-full flex justify-center text-gray-300 cursor-pointer"
                            >
                                <button>
                                    JSON
                                </button>
                            </div>
                        </div>

                        <span
                            className={`${activeConfigTab === 'config-tab1'
                                ? 'left-1 ml-0'
                                : 'left-1/2 -ml-1'
                                } py-1 text-white bg-ghBlack4 text-sm flex items-center justify-center w-1/2 rounded transition-all duration-150 ease-linear top-[5px] absolute`}
                        >
                            {activeConfigTab === 'config-tab1'
                                ? "Config UI"
                                : "JSON"}
                        </span>
                    </div>
                </div>
            </div>

            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <UIConfigTabContent activeTab={activeTab} handleTabClick={handleTabClick} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"profile-config.json"} />}
            </div>
            <div className='bg-ghBlack2 h-1'></div>
        </div>
    );
};

const UIConfigTabContent = ({ activeTab, handleTabClick, isBuild }) => (
    <div>Manage Applications</div>
)