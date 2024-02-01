import React, { useState, useEffect, useRef } from 'react';

const ProcessOutputView = (props) => {
  const [fileContent, setFileContent] = useState("")
  const outputContainer = useRef(null);
  const [isUserScroll, setIsUserScroll] = useState(false);


  const handleButtonClick = () => {

  };

  const handleBuildStopButtonClick = () => {
  };

  const handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    setIsUserScroll(scrollTop !== scrollHeight - clientHeight);
  };

  useEffect(() => {
    return () => clearInterval(interval);
  }, [isUserScroll]);

  return (
    <div className='py-5'>
      {/* <button onClick={handleButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Exec Btn</button>
      <button onClick={handleBuildStopButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Stop Exec Btn</button> */}

      <div className='flex pl-5 font-semibold text-gray-400 text-sm'>BUILD ID - {props.processType} process console output: </div>
      <div className="bg-ghBlack2 m-3">
        {/* {processType} Process started... */}
        <pre id="output-container" ref={outputContainer} onScroll={handleScroll} className='text-white text-sm text-left p-4 font-mono whitespace-pre-wrap overflow-y-scroll h-[400px]'>{props.logOutput}</pre>
      </div>
    </div>
  );
};

export default ProcessOutputView;
