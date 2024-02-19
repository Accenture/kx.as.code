import React, { useState, useEffect, useCallback } from 'react';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';
import { GetCurrentBuildStage } from "../wailsjs/go/main/App"
import Pending from '@mui/icons-material/Pending';

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

    const getCurrentStageIndex = () => {
        const stages = ['stage 1', 'stage 2', 'stage 3', 'stage 4', 'stage 5'];
        return stages.indexOf(currentStage);
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
            <div className='flex justify-center p-4 text-xs bg-ghBlack3 pt-4'>
                {completionStatus.map(({ stageNumber, status, title }) => (
                    <Stage key={stageNumber} stageNumber={stageNumber} status={status} title={title} getCurrentStageIndex={getCurrentStageIndex} />
                ))}
            </div>
        </div>
    );
};

export default BuildStagesTracker;


const Stage = ({ stageNumber, title, status, getCurrentStageIndex }) => {

    useEffect(() => {

    }, []);

    const getStatusColor = (status) => {
        if (status === 'Completed') {
            return 'text-green-500';
        } else if (status === 'Failed') {
            return 'text-red-500';
        } else {
            return 'text-gray-400';
        }
    };


    const getProgressLine = (position, stageNumber, currentIndex) => {
        const isLeft = position === "left";
        const isRight = position === "right";

        if (isLeft && stageNumber === 1 || isRight && stageNumber === 5) {
            return <div className={`w-full h-[2px] bg-ghBlack3`}></div>;
        }

        const shouldHighlight = (isLeft && stageNumber <= currentIndex + 1) || (isRight && stageNumber <= currentIndex);

        return (
            <div className={`w-full h-[2px] ${shouldHighlight ? "bg-white" : "bg-ghBlack4"}`}></div>
        );
    };


    return (
        <div className=''>
            <div className='flex justify-center mb-[-5px] items-center'>
                {getProgressLine("left", stageNumber, getCurrentStageIndex())}
                <div className={`border-[8px] border-ghBlack3 mx-[5px] rounded-full h-[25px] w-[25px] flex justify-center items-center`}>
                    <div className={`rounded-full h-2 w-2 bg-ghBlack4 ${status != "Completed" ? "bg-ghBlack4" : "bg-green-500"}`}></div>
                </div>
                {getProgressLine("right", stageNumber, getCurrentStageIndex())}
            </div>

            <div className={`mx-1 p-2 rounded ${status != "Completed" ? "bg-ghBlack3" : ""}`}>
                <div className='pb-2 text-gray-400'>{`Stage ${stageNumber}`}</div>
                <div className='flex justify-center items-center w-[130px]'>
                </div>
                <div className='pt-1 flex justify-center'>
                    <div className="text-left">
                        <div className={`font-semibold text-sm ${status != "Completed" ? "text-gray-600" : "text-white"}`}>{title}</div>
                        <div className={`${getStatusColor(status)} items-center flex`}>
                            {status === 'Completed' && (
                                <span className='text-sm mb-0.5 mr-0.5'>
                                    <CheckCircleIcon fontSize='inherit' />
                                </span>
                            )}
                            {status === 'Pending' && (
                                <span className='text-sm mb-0.5 mr-0.5'>
                                    <Pending fontSize='inherit' />
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
        </div>
    );
};
