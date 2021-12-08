import React, { useState, useEffect, useRef } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { Apps32, Dashboard32, Settings32 } from '@carbon/icons-react';

import SidebarLinkGroup from './SidebarLinkGroup';

function Sidebar({
  sidebarOpen,
  setSidebarOpen
}) {

  const location = useLocation();
  const { pathname } = location;

  const trigger = useRef(null);
  const sidebar = useRef(null);

  const storedSidebarExpanded = localStorage.getItem('sidebar-expanded');
  const [sidebarExpanded, setSidebarExpanded] = useState(storedSidebarExpanded === null ? false : storedSidebarExpanded === 'true');

  // close on click outside
  useEffect(() => {
    const clickHandler = ({ target }) => {
      if (!sidebar.current || !trigger.current) return;
      if (!sidebarOpen || sidebar.current.contains(target) || trigger.current.contains(target)) return;
      setSidebarOpen(false);
    };
    document.addEventListener('click', clickHandler);
    return () => document.removeEventListener('click', clickHandler);
  });

  // close if the esc key is pressed
  useEffect(() => {
    const keyHandler = ({ keyCode }) => {
      if (!sidebarOpen || keyCode !== 27) return;
      setSidebarOpen(false);
    };
    document.addEventListener('keydown', keyHandler);
    return () => document.removeEventListener('keydown', keyHandler);
  });

  useEffect(() => {
    localStorage.setItem('sidebar-expanded', sidebarExpanded);
    if (sidebarExpanded) {
      document.querySelector('body').classList.add('sidebar-expanded');
    } else {
      document.querySelector('body').classList.remove('sidebar-expanded');
    }
  }, [sidebarExpanded]);

  return (
    <div>
      {/* Sidebar backdrop (mobile only) */}
      <div className={`fixed inset-0 bg-gray-900 bg-opacity-30 z-40 lg:hidden lg:z-auto transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0 pointer-events-none'}`} aria-hidden="true"></div>

      {/* Sidebar */}
      <div
        id="sidebar"
        ref={sidebar}
        className={`flex flex-col absolute z-40 left-0 top-0 lg:static lg:left-auto lg:top-auto lg:translate-x-0 transform h-screen overflow-y-scroll lg:overflow-y-auto no-scrollbar w-64 lg:w-20 lg:sidebar-expanded:!w-64 2xl:!w-64 flex-shrink-0 bg-gray-700 transition-all duration-200 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-64'}`}
      >

        {/* Sidebar header */}
        <div className="pt-8 flex mb-10 sm:px-2">
          {/* Close button */}
          <button
            ref={trigger}
            className="lg:hidden text-gray-500 hover:text-gray-400"
            onClick={() => setSidebarOpen(!sidebarOpen)}
            aria-controls="sidebar"
            aria-expanded={sidebarOpen}
          >
            <span className="sr-only">Close sidebar</span>
            <svg className="w-12 h-6 fill-current" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path className="text-white" d="M10.7 18.7l1.4-1.4L7.8 13H20v-2H7.8l4.3-4.3-1.4-1.4L4 12z" />
            </svg>
          </button>
          {/* Logo */}
          <NavLink exact to="/" className="flex pl-4">
            <svg width="32" height="32" viewBox="0 0 32 32">

              <rect fill="white" width="32" height="32" rx="16" />
            </svg>
          </NavLink>
          <div className="pl-4 text-white flex my-auto lg:hidden lg:sidebar-expanded:block 2xl:block font-extrabold md:text-xl md:text-md">KX.AS CODE</div>
        </div>

        {/* Links */}
        <div className="space-y-8">
          {/* Pages group */}
          <div>
            <h3 className="text-xs uppercase text-gray-500 font-semibold pl-3">
            </h3>
            <ul className="mt-3">
              {/* Dashboard */}
              <li className={`hover:bg-drei px-6 py-2 last:mb-0 ${pathname.includes('/dashboard') ? 'pl-7 bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/dashboard" className={`block text-gray-200 truncate transition duration-150`}>
                  <div className="flex items-center">
                    <Dashboard32 className="p-1 flex-shrink-0"/>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Dashboard</span>
                  </div>
                </NavLink>
              </li>
              {/* Applications */}
              <li className={`hover:bg-drei px-6 py-2 last:mb-0 ${pathname.includes('applications') ? 'pl-7 bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/applications" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/application' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                    <Apps32 className="p-1 flex-shrink-0"/>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Applications</span>
                  </div>
                </NavLink>
              </li>
              {/* Settings */}
              <li className={`hover:bg-drei px-6 py-2 last:mb-0 ${pathname.includes('/settings') ? 'pl-7 bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/settings" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                    <Settings32 className="p-1 flex-shrink-0"/>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Settings</span>
                  </div>
                </NavLink>
              </li>
            </ul>
          </div>
        </div>

        {/* Expand / collapse button */}
        <div className="hidden lg:inline-flex 2xl:hidden justify-end mt-auto">
          <div className="p-8">
            <button onClick={() => setSidebarExpanded(!sidebarExpanded)}>
              <span className="sr-only">Expand / collapse sidebar</span>
              <svg className="w-6 h-6 fill-current sidebar-expanded:rotate-180" viewBox="0 0 24 24">
                <path className="text-white" d="M19.586 11l-5-5L16 4.586 23.414 12 16 19.414 14.586 18l5-5H7v-2z" />
                <path className="text-white" d="M3 23H1V1h2z" />
              </svg>
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

export default Sidebar;