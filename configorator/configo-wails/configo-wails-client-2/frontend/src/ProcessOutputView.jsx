import React, { useState, useEffect, useRef } from 'react';
import BuildStagesTracker from './BuildStagesTracker';

const ProcessOutputView = ({logOutput, processType}) => {
  const [fileContent, setFileContent] = useState("")
  const outputContainer = useRef(null);
  const [isUserScroll, setIsUserScroll] = useState(false);

  const handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.currentTarget;
    setIsUserScroll(scrollTop !== scrollHeight - clientHeight);
  }; 

  const highlightErrorText = (logOutput) => {
    const regex = new RegExp('.*error.*', 'ig');
    const lines = logOutput.split('\n');
    return lines.map((line, index) => (
      regex.test(line) ? <div key={index} className="text-red-500">{line}</div> : <div key={index}>{line}</div>
    ));
  };

  useEffect(() => {
  }, [isUserScroll, logOutput]);

  return (
    <div className=''>
      <BuildStagesTracker />
      {/* <button onClick={handleButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Exec Btn</button>
      <button onClick={handleBuildStopButtonClick} className='bg-ghBlack3 m-3 p-3 hover:bg-ghBlack2'>Temp Stop Exec Btn</button> */}

      <div className='py-3'>
        <div className='flex items-center pl-5 font-semibold text-gray-400 text-sm'>
          <span>
            <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
          </span>
          <span>
            &lt;BUILD ID&gt; - {processType} process console output:
          </span>
        </div>
        <div className="bg-ghBlack2 mt-3">
          {/* {processType} Process started... */}
          <pre id="output-container" ref={outputContainer} onScroll={handleScroll} className='text-white text-sm text-left p-4 font-mono whitespace-pre-wrap overflow-y-scroll h-[400px]'>{highlightErrorText(logOutput)}</pre>
        </div>
      </div>
    </div>
  );
};

export default ProcessOutputView;
