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
              <path className="text-white" d="M10.7 18.7l1.4-1.4L7.8 13H20v-2H7.8l4.3-4.3-1.4-1.4L4 12z" />
            </svg>
          </button>
          {/* Logo */}
          <NavLink exact to="/" className="flex pl-4">
            <svg width="32" height="32" viewBox="0 0 32 32">

              <rect fill="white" width="32" height="32" rx="16" />
            </svg>
          </NavLink>
          <div className="pl-4 text-white flex my-auto lg:hidden lg:sidebar-expanded:block 2xl:block font-extrabold md:text-2xl md:text-md">KX.AS CODE</div>
        </div>

        {/* Links */}
        <div className="space-y-8">
          {/* Pages group */}
          <div>
            <h3 className="text-xs uppercase text-gray-500 font-semibold pl-3">
            </h3>
            <ul className="mt-3">
              {/* Dashboard */}
              <li className={`hover:bg-drei px-6 py-2 mb-0.5 last:mb-0 ${pathname.includes('/dashboard') ? 'bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/dashboard" className={`block text-gray-200 truncate transition duration-150`}>
                  <div className="flex items-center">
                    <svg className="flex-shrink-0 h-8 w-8"
                      viewBox="0 0 42 24" style={{ "enableBackground": "new 0 0 32 32" }} >
                      <path stroke="white" stroke-width="1" d="M31,31.36H1c-0.199,0-0.36-0.161-0.36-0.36V1c0-0.199,0.161-0.36,0.36-0.36h30
	c0.199,0,0.36,0.161,0.36,0.36v30C31.36,31.199,31.199,31.36,31,31.36z M1.36,30.64h29.28V12.36H1.36V30.64z M13.36,11.64h17.28
	V1.36H13.36V11.64z M1.36,11.64h11.28V1.36H1.36V11.64z M9,27.36c-2.956,0-5.36-2.405-5.36-5.36h0.72c0,2.559,2.082,4.64,4.64,4.64
	s4.64-2.081,4.64-4.64S11.559,17.36,9,17.36v-0.72c2.956,0,5.36,2.405,5.36,5.36S11.956,27.36,9,27.36z M27.36,27h-0.72V16h0.721
	L27.36,27L27.36,27z M23.36,27h-0.72v-8h0.721L23.36,27L23.36,27z M19.36,27h-0.72v-3h0.721L19.36,27L19.36,27z"/>
                      <rect style={{ "fill": "none" }} width="32" height="32" />
                    </svg>
                    <span className="text-sm font-medium ml-3 lg:opacity-0 lg:sidebar-expanded:opacity-100 2xl:opacity-100 duration-200">Dashboard</span>
                  </div>
                </NavLink>
              </li>
              {/* Applications */}
              <li className={`hover:bg-drei px-6 py-2 mb-0.5 last:mb-0 ${pathname.includes('applications') ? 'bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/applications" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                    <svg className="flex-shrink-0 h-8 w-8"
                      viewBox="0 0 42 24" style={{ "enableBackground": "new 0 0 32 32" }} >
                      <path stroke="white" stroke-width="1" d="M16,31.36c-0.059,0-0.117-0.015-0.171-0.043l-13-7
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
              <li className={`hover:bg-drei px-6 py-2 mb-0.5 last:mb-0 ${pathname.includes('/settings') ? 'bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`}>
                <NavLink exact to="/settings" className={`block text-gray-200 hover:text-white truncate transition duration-150 ${pathname === '/' && 'hover:text-gray-200'}`}>
                  <div className="flex items-center">
                  <svg className="flex-shrink-0 h-8 w-8"
                      viewBox="0 0 42 24" style={{ "enableBackground": "new 0 0 32 32" }} >
                      <path stroke="white" stroke-width="1" d="M18.958,31.36h-5.915c-0.199,0-0.36-0.161-0.36-0.36v-3.633l-2.368-0.99l-2.576,2.575
	c-0.141,0.141-0.368,0.141-0.509,0L3.048,24.77c-0.141-0.141-0.141-0.369,0-0.51l2.568-2.568l-0.974-2.375H1
	c-0.199,0-0.36-0.161-0.36-0.36v-5.915c0-0.199,0.161-0.36,0.36-0.36h3.632l0.991-2.368L3.048,7.739
	c-0.141-0.141-0.141-0.368,0-0.509L7.23,3.048C7.298,2.98,7.389,2.942,7.485,2.942l0,0c0.096,0,0.187,0.038,0.254,0.105l2.568,2.569
	l2.375-0.975V1c0-0.199,0.161-0.36,0.36-0.36h5.915c0.199,0,0.36,0.161,0.36,0.36v3.632l2.367,0.991l2.575-2.575
	c0.141-0.141,0.369-0.141,0.51,0l4.183,4.182c0.067,0.067,0.105,0.159,0.105,0.254s-0.038,0.187-0.105,0.254l-2.569,2.568
	l0.975,2.375H31c0.199,0,0.36,0.161,0.36,0.36v5.915c0,0.199-0.161,0.36-0.36,0.36h-3.633l-0.99,2.368l2.576,2.575
	c0.067,0.067,0.105,0.159,0.105,0.255s-0.038,0.188-0.105,0.255l-4.183,4.182c-0.141,0.141-0.369,0.141-0.51,0l-2.568-2.568
	l-2.374,0.974V31C19.318,31.199,19.157,31.36,18.958,31.36z M13.403,30.64h5.195v-3.523c0-0.146,0.089-0.277,0.224-0.333
	l2.819-1.156c0.134-0.057,0.288-0.024,0.392,0.078l2.483,2.483l3.674-3.673l-2.492-2.491c-0.103-0.104-0.134-0.259-0.077-0.394
	l1.176-2.812c0.056-0.134,0.187-0.222,0.332-0.222h3.512v-5.194h-3.522c-0.146,0-0.277-0.088-0.333-0.223l-1.157-2.82
	c-0.055-0.134-0.024-0.289,0.078-0.391l2.484-2.483l-3.674-3.673l-2.491,2.491c-0.104,0.103-0.26,0.134-0.394,0.078L18.82,5.206
	c-0.134-0.056-0.222-0.187-0.222-0.332V1.36h-5.195v3.523c0,0.146-0.088,0.278-0.223,0.333l-2.82,1.157
	c-0.135,0.055-0.289,0.024-0.391-0.079L7.485,3.812L3.812,7.484l2.491,2.492c0.104,0.103,0.134,0.259,0.078,0.394l-1.177,2.812
	c-0.056,0.134-0.187,0.221-0.332,0.221H1.36v5.194h3.524c0.146,0,0.278,0.089,0.333,0.224l1.157,2.82
	c0.055,0.135,0.024,0.289-0.079,0.392l-2.483,2.483l3.673,3.673l2.492-2.491c0.103-0.104,0.26-0.133,0.393-0.077l2.812,1.176
	c0.134,0.056,0.221,0.187,0.221,0.332V30.64z M16,23.36c-4.058,0-7.36-3.302-7.36-7.36S11.942,8.64,16,8.64
	c4.059,0,7.36,3.302,7.36,7.36C23.36,20.059,20.059,23.36,16,23.36z M16,9.36c-3.661,0-6.64,2.979-6.64,6.64s2.979,6.64,6.64,6.64
	s6.64-2.979,6.64-6.64S19.661,9.36,16,9.36z"/>
                      <rect style={{"fill":"none"}} width="32" height="32" />
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