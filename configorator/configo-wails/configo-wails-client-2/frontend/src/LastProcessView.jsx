import React, { useState, useEffect } from 'react';
import HistoryIcon from '@mui/icons-material/History';
import { IconButton } from '@mui/material';
import PlayCircleIcon from '@mui/icons-material/PlayCircle';
import MonitorHeartIcon from '@mui/icons-material/MonitorHeart';

const LastProcessView = (props) => {

  const [processType, setProcessType] = useState("")

  const data = [
    { id: 1, timestamp: '2024-01-25 12:00:00', vmProfile: "Virtualbox", nodeType: "main", buildStatus: 'success' },
    { id: 2, timestamp: '2024-01-25 13:30:00', vmProfile: "Virtualbox", nodeType: "main", buildStatus: 'success' },
    { id: 3, timestamp: '2024-01-25 15:45:00', vmProfile: "Virtualbox", nodeType: "main", buildStatus: 'failed' },
    { id: 4, timestamp: '2024-01-25 15:45:00', vmProfile: "Virtualbox", nodeType: "main", buildStatus: 'stopped' },
    { id: 5, timestamp: '2024-01-25 15:45:00', vmProfile: "Virtualbox", nodeType: "main", buildStatus: 'success' }
  ];

  const getStatusComponent = (status) => {
    switch (status) {
      case 'success':
        return <div className="bg-green-600 flex justify-center py-0.5 w-20 rounded">Success</div>;
      case 'failed':
        return <div className="bg-red-600 flex justify-center py-0.5 w-20 rounded">Failed</div>;
      case 'stopped':
        return <div className="bg-gray-500 flex justify-center py-0.5 w-20 rounded">Stopped</div>;
      default:
        return <div className="">Unknown Status</div>;
    }
  };

  useEffect(() => {
    setProcessType(props.processType)
  }, []);

  return (
    <div>
      <div className="grid grid-cols-12 dark:bg-ghBlack4">

        <div className="col-span-12 py-2">
          <h1 className='flex text-gray-400 px-5 items-center font-semibold'>
            <span className='text-xl mb-0.5 mr-1'><HistoryIcon fontSize='inherit' /></span>
            Last {processType}s History:</h1>

          <table className='mt-2 text-left w-full text-sm'>
            <thead>
              <tr className=''>
                <th className="px-5" >Build ID</th>
                <th className="px-5">Timestamp</th>
                <th className="px-5">VM Profile</th>
                <th className="px-5">Node Type</th>
                <th className="px-5">Build Status</th>
                <th className="px-5">
                </th>
              </tr>
            </thead>
            <tbody>
              {data.map((row) => (
                <tr key={row.id} className='hover:bg-ghBlack3 hover:cursor-pointer'>
                  <td className="px-5">#{row.id}</td>
                  <td className="px-5">{row.timestamp}</td>
                  <td className="px-5">{row.vmProfile}</td>
                  <td className="px-5 capitalize">{row.nodeType}</td>
                  <td className="px-5 text-xs font-semibold uppercase">{getStatusComponent(row.buildStatus)}</td>
                  <td className='pr-10 flex justify-end'>
                    {/* Build action buttons */}
                    <div className="w-20">
                      <IconButton onClick={() => { }}>
                        <MonitorHeartIcon />
                      </IconButton>

                      {/* <IconButton onClick={() => { }}>
                        <PlayCircleIcon />
                      </IconButton> */}

                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="col-span-6"></div>
      </div>
      <div className='bg-ghBlack2 h-1'></div>

    </div>
  );
};

export default LastProcessView;