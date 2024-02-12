import React, { useState, useEffect, useCallback } from 'react';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import { GetCurrentBuildStage } from "../wailsjs/go/main/App"

const BuildStagesTracker = () => {
    // const [isBuildStarted, setIsBuildStarted] = useState(false);

    const [isBuildInitStarted, setIsBuildInit] = useState(false);
    const [isBuildPackerDownloadStarted, setIsBuildPackerDownloadStarted] = useState(false);
    const [isBuildPackerInstallationStarted, setIsBuildPackerInstallationStarted] = useState(false);
    const [isBuildPackerExecutionStarted, setIsBuildPackerExecutionStarted] = useState(false);
    const [isBuildCompleted, setIsBuildCompleted] = useState(false);

    const [currentStage, setCurrentStage] = useState('NA');

    useEffect(() => {
        const intervalId = setInterval(async () => {
            try {
                const newStage = await GetCurrentBuildStage();
                if (newStage !== currentStage) {
                    setCurrentStage(newStage);
                    console.log('Current build stage:', newStage);
                }
            } catch (error) {
                console.error('Error fetching build stage:', error);
            }
        }, 2000);

        return () => clearInterval(intervalId);
    }, [currentStage]);

    const generateCompletionStatus = (currentStage) => {
        const stages = ['stage 1', 'stage 2', 'stage 3', 'stage 4', 'stage 5'];
        const stagesTitles = ['Initialize Build', 'Download Packer', 'Install Packer', 'Execute Packer', 'Build Completed']
        const currentStageIndex = stages.indexOf(currentStage);

        return stages.map((stage, index) => ({
            stageNumber: index + 1,
            status: index <= currentStageIndex ? 'Completed' : 'Pending',
            title: stagesTitles[index]
        }));
    };

    const completionStatus = generateCompletionStatus(currentStage);

    return (
        <div>
            <div>
                <div className='px-5 py-3'>
                    <h2 className='text-3xl font-semibold text-left'>Build Image Status</h2>
                    <p className='text-sm dark:text-gray-400 text-justify'>More Details about the Build process here.</p>
                </div>
            </div>
            <div className='flex justify-center p-4 text-xs bg-ghBlack2 pt-4'>
                {completionStatus.map(({ stageNumber, status, title }) => (
                    <Stage key={stageNumber} stageNumber={stageNumber} status={status} title={title} currentStage={currentStage} />
                ))}
            </div>
        </div>
    );
};

export default BuildStagesTracker;


const Stage = ({ stageNumber, title, status, currentStage }) => {
    const getStatusColor = (status) => {
        if (status === 'Completed') {
            return 'text-green-500';
        } else if (status === 'Failed') {
            return 'text-red-500';
        } else {
            return 'text-gray-400';
        }
    };

    return (
        <div className={`mx-1 p-2 rounded ${status != "Completed" ? "bg-ghBlack3" : "bg-ghBlack4"}`}>
            <div className='pb-2 text-gray-400'>{`Stage ${stageNumber}`}</div>
            <div className='flex justify-center items-center w-[130px]'>
                {/* <div className={`mx-[5px] rounded-full h-[13px] w-[13px] flex justify-center items-center ${status != "Completed" ? "bg-gray-400": "bg-white"}`}>
                    <div className={`rounded-full h-2 w-2 bg-ghBlack2 ${status != "Completed" ? "bg-gray-400": "bg-green-500"}`}></div>
                </div> */}
            </div>
            <div className='pt-1 flex justify-center'>
                <div className="text-left">
                    <div className={`font-semibold text-sm ${status != "Completed" ? "text-gray-400" : "text-white"}`}>{title}</div>
                    <div className={`${getStatusColor(status)} items-center flex`}>
                        {status === 'Completed' && (
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <CheckCircleIcon fontSize='inherit' />
                            </span>
                        )}
                        {status === 'Failed' && (
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <ErrorIcon fontSize='inherit' />
                            </span>
                        )}
                        <span>{status}</span>
                    </div>
                </div>
            </div>
        </div>
    );
};
