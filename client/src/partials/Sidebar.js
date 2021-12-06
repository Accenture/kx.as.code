import React, { useState, useEffect, useRef } from 'react';
import { NavLink, useLocation } from 'react-router-dom';

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
        className={`flex flex-col absolute z-40 left-0 top-0 lg:static lg:left-auto lg:top-auto lg:translate-x-0 transform h-screen overflow-y-scroll lg:overflow-y-auto no-scrollbar w-64 lg:w-20 lg:sidebar-expanded:!w-64 2xl:!w-64 flex-shrink-0 bg-primary transition-all duration-200 ease-in-out ${sidebarOpen ? 'translate-x-0' : '-translate-x-64'}`}
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
              <path d="M10.7 18.7l1.4-1.4L7.8 13H20v-2H7.8l4.3-4.3-1.4-1.4L4 12z" />
            </svg>
          </button>
          {/* Logo */}
          <NavLink exact to="/" className="flex pl-4">
            <svg width="32" height="32" viewBox="0 0 32 32">

              <rect fill="white" width="32" height="32" rx="16" />
            </svg>
          </NavLink>
          <div className="pl-4 text-white flex my-auto lg:hidden lg:sidebar-expanded:block 2xl:block">KXaS Portal</div>
        </div>

        {/* Links */}
        <div className="space-y-8">
          {/* Pages group */}
          <div>
            <h3 className="text-xs uppercase text-gray-500 font-semibold pl-3">
              <span className="hidden lg:block lg:sidebar-expanded:hidden 2xl:hidden text-center w-6" aria-hidden="true">•••</span>
            </h3>
            <ul className="mt-3">
              {/* Dashboard */}
              <li className={`px-3 py-2 rounded-sm mb-0.5 last:mb-0 ${pathname === '/' && 'bg-black'}`}>
                <NavLink exact to="/" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                  <svg className="flex-shrink-0 h-8 w-8"
                      viewBox="0 0 38 24" style={{ "enableBackground": "new 0 0 32 32" }} >
                      <path stroke="white" stroke-width=".5" d="M31,31.36H1c-0.199,0-0.36-0.161-0.36-0.36V1c0-0.199,0.161-0.36,0.36-0.36h30
	c0.199,0,0.36,0.161,0.36,0.36v30C31.36,31.199,31.199,31.36,31,31.36z M1.36,30.64h29.28V12.36H1.36V30.64z M13.36,11.64h17.28
	V1.36H13.36V11.64z M1.36,11.64h11.28V1.36H1.36V11.64z M9,27.36c-2.956,0-5.36-2.405-5.36-5.36h0.72c0,2.559,2.082,4.64,4.64,4.64
	s4.64-2.081,4.64-4.64S11.559,17.36,9,17.36v-0.72c2.956,0,5.36,2.405,5.36,5.36S11.956,27.36,9,27.36z M27.36,27h-0.72V16h0.721
	L27.36,27L27.36,27z M23.36,27h-0.72v-8h0.721L23.36,27L23.36,27z M19.36,27h-0.72v-3h0.721L19.36,27L19.36,27z"/>
                      <rect style={{"fill":"none"}} width="32" height="32" />
                    </svg>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Dashboard</span>
                  </div>
                </NavLink>
              </li>
              {/* Applications */}
              <li className={`hover:bg-drei px-3 py-2 rounded-sm mb-0.5 last:mb-0 ${pathname.includes('applications') && 'bg-gray-900'}`}>
                <NavLink exact to="/" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                    <svg className="flex-shrink-0 h-8 w-8"
                      viewBox="0 0 38 24" style={{ "enableBackground": "new 0 0 32 32" }} >
                      <path stroke="white" stroke-width=".5" d="M16,31.36c-0.059,0-0.117-0.015-0.171-0.043l-13-7
	C2.713,24.254,2.64,24.133,2.64,24V8c0-0.132,0.073-0.254,0.189-0.317l13-7c0.107-0.058,0.234-0.058,0.342,0l13,7
	C29.287,7.746,29.36,7.868,29.36,8v16c0,0.133-0.073,0.254-0.189,0.317l-13,7C16.117,31.346,16.059,31.36,16,31.36z M16.36,15.215
	v15.183l12.28-6.612V8.603L16.36,15.215z M3.36,23.785l12.28,6.612V15.215L3.36,8.603V23.785z M3.759,8L16,14.591L28.24,8L16,1.409
	L3.759,8z"/>
                      <rect style={{ "fill": "none" }} width="32" height="32" />
                    </svg>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Applications</span>
                  </div>
                </NavLink>
              </li>
              {/* Settings */}
              <li className={`hover:bg-drei px-3 py-2 rounded-sm mb-0.5 last:mb-0 ${pathname.includes('applications') && 'bg-gray-900'}`}>
                <NavLink exact to="/" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                    <svg className="flex-shrink-0 h-6 w-6" viewBox="0 0 24 24">
                      <path className={`fill-current text-gray-400 ${pathname === '/' && '!text-indigo-500'}`} d="M12 0C5.383 0 0 5.383 0 12s5.383 12 12 12 12-5.383 12-12S18.617 0 12 0z" />
                      <path className={`fill-current text-gray-600 ${pathname === '/' && 'text-indigo-600'}`} d="M12 3c-4.963 0-9 4.037-9 9s4.037 9 9 9 9-4.037 9-9-4.037-9-9-9z" />
                      <path className={`fill-current text-gray-400 ${pathname === '/' && 'text-indigo-200'}`} d="M12 15c-1.654 0-3-1.346-3-3 0-.462.113-.894.3-1.285L6 6l4.714 3.301A2.973 2.973 0 0112 9c1.654 0 3 1.346 3 3s-1.346 3-3 3z" />
                    </svg>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Settings</span>
                  </div>
                </NavLink>
              </li>
            </ul>
          </div>
        </div>

        {/* Expand / collapse button */}
        <div className="pt-3 hidden lg:inline-flex 2xl:hidden justify-end mt-auto">
          <div className="px-3 py-2">
            <button onClick={() => setSidebarExpanded(!sidebarExpanded)}>
              <span className="sr-only">Expand / collapse sidebar</span>
              <svg className="w-6 h-6 fill-current sidebar-expanded:rotate-180" viewBox="0 0 24 24">
                <path className="text-gray-400" d="M19.586 11l-5-5L16 4.586 23.414 12 16 19.414 14.586 18l5-5H7v-2z" />
                <path className="text-gray-600" d="M3 23H1V1h2z" />
              </svg>
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

export default Sidebar;