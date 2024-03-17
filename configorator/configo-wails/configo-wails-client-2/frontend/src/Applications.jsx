import React, { useState, useEffect } from 'react';
import { ConfigSectionHeader } from './ConfigSectionHeader';
import JSONConfigTabContent from './JSONConfigTabContent';
import { ApplicationsListAndDetail } from './ApplicationsListAndDetail';
import applicationsJson from './assets/templates/applications.json';

export default function Applications() {
    const [activeTab, setActiveTab] = useState('tab1');
    const [activeConfigTab, setActiveConfigTab] = useState('config-tab1');
    const [windowHeight, setWindowHeight] = useState(window.innerHeight);
    const [applicationGroupDetailTab, setApplicationGroupDetailTab] = useState("config-ui");
    const [jsonData, setJsonData] = useState([]);


    const handleTabClick = (tab) => {
        setActiveTab(tab);
    };


    useEffect(() => {
        const handleResize = () => {
            setWindowHeight(window.innerHeight);
        };
        window.addEventListener('resize', handleResize);

        setJsonData(JSON.stringify(applicationsJson, null, 2))

        // Detach event listener on component unmount
        return () => {
            window.removeEventListener('resize', handleResize);
        };

    }, [activeConfigTab, jsonData, applicationGroupDetailTab]);

    return (
        <div className=''>
            <div className='relative'>
                {/* Config View Tabs */}
                <div className='dark:bg-ghBlack4'>
                    
                    <ConfigSectionHeader sectionTitle={"Applications"} SectionDescription={"More Details about this section here."} setActiveConfigTab={setActiveConfigTab} activeConfigTab={activeConfigTab} contentName={"Appplications"}/>

                </div>
            </div>

            <div className='bg-ghBlack2 h-1'></div>
            <div className="config-tab-content">
                {activeConfigTab === 'config-tab1' && <ApplicationsListAndDetail activeTab={activeTab} handleTabClick={handleTabClick} setJsonData={setJsonData} applicationGroupDetailTab={applicationGroupDetailTab} setApplicationGroupDetailTab={setApplicationGroupDetailTab} windowHeight={windowHeight} />}
                {activeConfigTab === 'config-tab2' && <JSONConfigTabContent jsonData={jsonData} fileName={"profile-config.json"} />}
            </div>
            <div className='bg-ghBlack2 h-1'></div>
        </div>
    );
};

const UIConfigTabContent = ({ activeTab, handleTabClick, isBuild }) => (
    <div>Manage Applications</div>
)