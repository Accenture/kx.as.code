import React from 'react';
import { Link } from 'react-router-dom';
import EditMenu from '../EditMenu';
import { TrashCan32, Restart32 } from '@carbon/icons-react';


function ApplicationGroupCard(props) {
  const appGroupBreadcrumb = props.appGroup.name.replaceAll(" ", "-").replace(/\b\w/g, l => l.toLowerCase())

  return (
    <div className="flex flex-col col-span-full sm:col-span-6 xl:col-span-4 bg-inv2 shadow-lg rounded">
      <div className="p-6">
        <header className="flex justify-between items-start mb-2">
          {/* Icon */}
          <div className="flex content-start">
            <div className="bg-ghBlack rounded-full h-12 w-12" alt="Icon 02"></div>

          </div>
          {/* Menu button */}
          <EditMenu className="relative inline-flex">
            <li>
              <Link className="font-medium text-sm text-white hover:text-gray-500 flex py-1 px-3" to="#0">
                <div className="flex items-start">
                  <Restart32 className="p-1 flex my-auto" />
                </div>
                <span className="flex my-auto">Reinstall</span>
              </Link>
            </li>
            <li>
              <Link className="font-medium text-sm text-white hover:text-gray-500 flex py-1 px-3" to="#0">
                <div className="flex items-start">
                  <Restart32 className="p-1 flex my-auto" />
                </div>
                <span className="flex my-auto">Reinstall</span>
              </Link>
            </li>
            <li>
              <Link className="font-medium text-sm text-red-500 hover:text-red-600 flex py-1 px-3" to="#0">
                <div className="flex items-start">
                  <TrashCan32 className="p-1 flex my-auto" />
                </div>
                <span className="flex my-auto">Uninstall</span>
              </Link>
            </li>
          </EditMenu>
        </header>

        <Link to={'/app-groups/' + appGroupBreadcrumb}>
          <h2 className="hover:underline hover:cursor-pointer text-lg text-white mb-2">{props.appGroup.name}</h2>
        </Link>
      </div>

      <div className="flex-grow">
    
      </div>
    </div>
  );
}

export default ApplicationGroupCard;
