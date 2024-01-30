import React, { useState, useEffect } from 'react';
import HistoryIcon from '@mui/icons-material/History';

const LastProcessView = (props) => {

  const [processType, setProcessType] = useState("")

  const data = [
    { id: 1, timestamp: '2024-01-25 12:00:00' },
    { id: 2, timestamp: '2024-01-25 13:30:00' },
    { id: 3, timestamp: '2024-01-25 15:45:00' },
    { id: 4, timestamp: '2024-01-25 15:45:00' },
    { id: 5, timestamp: '2024-01-25 15:45:00' }
  ];

  useEffect(() => {
    setProcessType(props.processType)
  }, []);

  return (
    <div>
      <div className="grid grid-cols-12">

        <div className="col-span-12 bg-ghBlack3 py-2">
          <h1 className='flex text-gray-400 px-5 items-center font-semibold'>
            <span className='text-xl mb-0.5 mr-1'><HistoryIcon fontSize='inherit'/></span>
            Last {processType}s History:</h1>

          <table className='mt-2 text-left w-full text-sm'>
            <thead>
              <tr className=''>
                <th className="p-1 px-5" >Build ID</th>
                <th className="p-1 px-5">Timestamp</th>
              </tr>
            </thead>
            <tbody>
              {data.map((row) => (
                <tr key={row.id} className='hover:bg-ghBlack4 hover:cursor-pointer'>
                  <td className="p-1 px-5">#{row.id}</td>
                  <td className="p-1 px-5">{row.timestamp}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="col-span-6"></div>
      </div>
    </div>
  );
};

export default LastProcessView;