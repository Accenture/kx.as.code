import React, { useState, useEffect, useCallback } from 'react';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import ErrorIcon from '@mui/icons-material/Error';

const BuildStages = () => {
    // const [isBuildStarted, setIsBuildStarted] = useState(false);

    useEffect(() => {

    }, []);

    return (
        <div className='flex justify-center p-4 text-xs bg-ghBlack2 pt-6'>
            <div>
                <div className='pb-1 text-gray-400'>Stage 1</div>
                <div className='flex justify-center items-center w-[130px]'>
                    <div className='h-0.5 w-[50px] bg-ghBlack2'></div>
                    <div className='mx-[5px] rounded-full h-[20px] w-[20px] bg-white flex justify-center items-center'>
                        <div className='rounded-full h-3 w-3 bg-ghBlack2'></div>
                    </div>
                    <div className='h-[2px] w-[50px] bg-white rounded-tl-full rounded-bl-full'></div>
                </div>
                <div className='pt-1 flex justify-center'>
                    <div className="text-left">
                        <div className='font-semibold text-sm'>Initialize Build</div>
                        <div className='text-green-500 items-center flex'>
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <CheckCircleIcon fontSize='inherit' />
                            </span>
                            <span>
                                Completed
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div className='pb-1 text-gray-400'>Stage 2</div>
                <div className='flex justify-center items-center w-[130px]'>
                    <div className='h-0.5 w-[50px] bg-white rounded-tr-full rounded-br-full'></div>
                    <div className='mx-[5px] rounded-full h-[20px] w-[20px] bg-white flex justify-center items-center'>
                        <div className='rounded-full h-3 w-3 bg-ghBlack2'></div>
                    </div>
                    <div className='h-[2px] w-[50px] bg-white rounded-tl-full rounded-bl-full'></div>
                </div>
                <div className='pt-1 flex justify-center'>
                    <div className="text-left">
                        <div className='font-semibold text-sm'>Download Packer</div>
                        <div className='text-green-500 items-center flex'>
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <CheckCircleIcon fontSize='inherit' />
                            </span>
                            <span>
                                Completed
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div className='pb-1 text-gray-400'>Stage 3</div>
                <div className='flex justify-center items-center w-[130px]'>
                    <div className='h-0.5 w-[50px] bg-white rounded-tr-full rounded-br-full'></div>
                    <div className='mx-[5px] rounded-full h-[20px] w-[20px] bg-white flex justify-center items-center'>
                        <div className='rounded-full h-3 w-3 bg-ghBlack2'></div>
                    </div>
                    <div className='h-[2px] w-[50px] bg-white rounded-tl-full rounded-bl-full'></div>

                </div>
                <div className='pt-1 flex justify-center'>
                    <div className="text-left">
                        <div className='font-semibold text-sm'>Install Packer</div>
                        <div className='text-green-500 items-center flex'>
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <CheckCircleIcon fontSize='inherit' />
                            </span>
                            <span>
                                Completed
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div className='pb-1 text-gray-400'>Stage 4</div>
                <div className='flex justify-center items-center w-[130px]'>
                    <div className='h-0.5 w-[50px] bg-white rounded-tr-full rounded-br-full'></div>
                    <div className='mx-[5px] rounded-full h-[20px] w-[20px] bg-white flex justify-center items-center'>
                        <div className='rounded-full h-3 w-3 bg-ghBlack2'></div>
                    </div>
                    <div className='h-[2px] w-[50px] bg-gray-400 rounded-tl-full rounded-bl-full'></div>

                </div>
                <div className='pt-1 flex justify-center text-white'>
                    <div className="text-left">
                        <div className='font-semibold text-sm'>Execute Packer</div>
                        <div className='text-red-500 items-center flex'>
                            <span className='text-sm mb-0.5 mr-0.5'>
                                <ErrorIcon fontSize='inherit' />
                            </span>
                            <span>
                                Failed
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div className='pb-1 text-gray-400'>Stage 5</div>
                <div className='flex justify-center items-center w-[130px]'>
                    <div className='h-0.5 w-[50px] bg-gray-400 rounded-tr-full rounded-br-full'></div>
                    <div className='mx-[5px] rounded-full h-[20px] w-[20px] bg-gray-400 flex justify-center items-center'>
                        <div className='rounded-full h-3 w-3 bg-gray-400'></div>
                    </div>
                    <div className='h-[2px] w-[50px] bg-ghBlack2'></div>

                </div>
                <div className='pt-1 flex justify-center text-gray-400'>
                    <div className="text-left">
                        <div className='font-semibold text-sm'>Build Completed</div>
                        <div className=''></div>
                    </div>
                </div>

            </div>

        </div>
    );
};

export default BuildStages;
