import React from 'react';
import { Link } from 'react-router-dom';
import EditMenu from '../EditMenu';
import { TrashCan32, Restart32 } from '@carbon/icons-react';


function ApplicationGroupCard(props) {
  const appGroupBreadcrumb = props.appGroup.name.replaceAll(" ", "-").replace(/\b\w/g, l => l.toLowerCase())
  const appGroupCategory = props.appGroup.group_category.toUpperCase().replaceAll("_", " ")

  return (
    <div className="col-span-full sm:col-span-6 xl:col-span-4 bg-inv2 shadow-lg rounded">
      <div className="relative h-64 p-6">

        {/* Header */}
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

        <div className="font-semibold text-gray-400">{appGroupCategory}</div>
        <div className="inline-flex m-auto">
          <Link to={'/app-groups/' + appGroupBreadcrumb}>
            <h2 className="hover:underline hover:cursor-pointer text-lg text-white">{props.appGroup.name}</h2>
          </Link>
        </div>

        {/* Main Card Content */}
        <div className="">{props.appGroup.description}</div>

        <div className="flex justify-center">
          <button disabled className="btn rounded bg-kxBlue hover:bg-kxBlue2 p-2 absolute bottom-3 mb-6 justify-center flex px-6">
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            INSTALLING
          </button>
        </div>
        <div className="flex justify-center">
          <div className="rounded-t-none rounded bg-statusNewGreen absolute bottom-0 justify-center flex px-6 h-3 w-full"></div>
        </div>

      </div>
    </div>
  );
}

export default ApplicationGroupCard;
