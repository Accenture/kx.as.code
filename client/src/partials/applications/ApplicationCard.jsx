import React from 'react';
import { Link } from 'react-router-dom';
import EditMenu from '../EditMenu';
import { TrashCan32 } from '@carbon/icons-react';
import StatusTag from '../StatusTag';

function ApplicationCard(props) {

  return (
    <div className="flex flex-col col-span-full sm:col-span-6 xl:col-span-4 bg-white shadow-lg rounded-xl border border-gray-200">
      <div className="p-6">
        <header className="flex justify-between items-start mb-2">
          {/* Icon */}
           <div className="flex content-start">
           <div className="bg-gray-800 rounded-full h-8 w-8" alt="Icon 02"></div>
           <StatusTag installStatus={props.app.queueName}/>
            </div>
          {/* Menu button */}
          <EditMenu className="relative inline-flex">
            <li>
              <Link className="font-medium text-sm text-gray-600 hover:text-gray-800 flex py-1 px-3" to="#0">Option 1</Link>
            </li>
            <li>
              <Link className="font-medium text-sm text-gray-600 hover:text-gray-800 flex py-1 px-3" to="#0">Option 2</Link>
            </li>
            <li>
              <Link className="font-medium text-sm text-red-500 hover:text-red-600 flex py-1 px-3" to="#0">
                <div className="flex items-start">
                <TrashCan32 className="p-1 flex my-auto"/>
              </div>
              <span className="flex my-auto">Uninstall</span>
            </Link>
          </li>
        </EditMenu>
      </header>
      <h2 className="text-lg font-semibold text-gray-800 mb-2">{props.app.appName} ({props.app.category}) </h2>
      <div className="text-xs font-semibold text-gray-400 uppercase mb-1">

      </div>
    </div>

  <div className="flex-grow">

  </div>
    </div >
  );
}

export default ApplicationCard;
