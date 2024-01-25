import React, { useState, useEffect } from 'react';


const ProcessOutputView = (props) => {

  const [processType, setProcessType] = useState("")
  
  useEffect(() => {
    setProcessType(props.processType)
  }, []);

  return (
    <div className="bg-ghBlack h-[300px] m-3">
      {processType} Process started...
    </div>
  );
};

export default ProcessOutputView;