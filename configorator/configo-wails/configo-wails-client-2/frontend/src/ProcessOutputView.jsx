import React, { useState, useEffect, useRef } from 'react';
import { WriteTimeToFile, ExeBuild, StopExe } from "../wailsjs/go/main/App"
import timeTxt from './assets/time.txt';

const ProcessOutputView = (props) => {
  const [processType, setProcessType] = useState("")
  const [fileContent, setFileContent] = useState("")
  const outputContainer = useRef(null);
  const [isUserScroll, setIsUserScroll] = useState(false);

  const [logOutput, setLogOutput] = useState('');

  const handleButtonClick = () => {
    ExeBuild().then(result => {
      setLogOutput(result);
    });
  };

  const handleBuildStopButtonClick = () => {
    StopExe()
  };

  const handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    setIsUserScroll(scrollTop !== scrollHeight - clientHeight);
  };

  useEffect(() => {
    setProcessType(props.processType)

    const interval = setInterval(() => {
      fetch(timeTxt)
        .then(response => response.text())
        .then(text => setLogOutput(text));
    }, 1000);

    return () => clearInterval(interval);
  }, [isUserScroll]);

  return (
    <div>
      <button onClick={handleButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Exec Btn</button>
      <button onClick={handleBuildStopButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Stop Exec Btn</button>

      <div className='flex pl-5 font-semibold text-gray-400 text-sm'>BUILD ID - {processType} process console output: </div>
      <div className="bg-ghBlack2 m-3">
        {/* {processType} Process started... */}
        <pre id="output-container" ref={outputContainer} onScroll={handleScroll} className='text-white text-sm text-left p-4 font-mono whitespace-pre-wrap overflow-y-scroll h-[400px]'>{logOutput}</pre>
      </div>
    </div>
  );
};

export default ProcessOutputView;
