import React, { useState, useRef, useEffect } from 'react';
import Transition from '../../utils/Transition.js';
import {Filter20} from "@carbon/icons-react"

function FilterButton(props) {

  const [dropdownOpen, setDropdownOpen] = useState(false);
  const [activeOptionsCount, setActiveOptionsCount] = useState(3);

  const trigger = useRef(null);
  const dropdown = useRef(null);

  // close on click outside
  useEffect(() => {
    const clickHandler = ({ target }) => {
      if (!dropdownOpen || dropdown.current.contains(target) || trigger.current.contains(target)) return;
      setDropdownOpen(false);
    };
    document.addEventListener('click', clickHandler);
    return () => document.removeEventListener('click', clickHandler);
  });

  // close if the esc key is pressed
  useEffect(() => {
    const keyHandler = ({ keyCode }) => {
      if (!dropdownOpen || keyCode !== 27) return;
      setDropdownOpen(false);
    };
    document.addEventListener('keydown', keyHandler);
    return () => document.removeEventListener('keydown', keyHandler);
  });

  return (
    <div className="relative inline-flex">
      <button
        ref={trigger}
        className="text-white bg-kxBlue hover:bg-kxBlue2 border-0 px-3 h-12 btn text-md rounded"
        aria-haspopup="true"
        onClick={() => setDropdownOpen(!dropdownOpen)}
        aria-expanded={dropdownOpen}
      >
        <div id="optionCount" className='h-6 w-6 bg-ghBlack2 rounded mr-2 leading-6 text-center'>
         {activeOptionsCount}
        </div>
        <Filter20/>
      </button>
      <Transition
        show={dropdownOpen}
        tag="div"
        className="origin-top-right z-10 absolute top-full left-0 right-auto md:left-auto md:left-0 min-w-56 bg-kxBlue2 pt-1.5 rounded shadow-lg overflow-hidden mt-0"
        enter="transition ease-out duration-200 transform"
        enterStart="opacity-0 -translate-y-2"
        enterEnd="opacity-100 translate-y-0"
        leave="transition ease-out duration-200"
        leaveStart="opacity-100"
        leaveEnd="opacity-0"
      >
        <div ref={dropdown}>
          <div className="p-3 pb-1 px-5 text-xs font-semibold text-gray-300 uppercase">Filter</div>
          <ul className="mx-3 mb-4 text-white">
            <li className="py-1 px-3">
              <label className="flex items-center">
                <input id="checkCompleted" defaultChecked={true} 
                onClick={ e => { props.filterHandler(e.target.id )}} 
                type="checkbox" 
                className="form-checkbox text-ghBlack"
                onChange={e => {e.target.checked ? setActiveOptionsCount(activeOptionsCount => activeOptionsCount + 1): setActiveOptionsCount(activeOptionsCount => activeOptionsCount - 1)}}/>
                <span className="text-sm font-medium ml-2">Completed</span>
              </label>
            </li>
            <li className="py-1 px-3">
              <label className="flex items-center">
              <input id="checkFailed" defaultChecked={true} 
              onClick={ e => { props.filterHandler(e.target.id )}} 
              type="checkbox" 
              className="form-checkbox text-ghBlack" 
              onChange={e => {e.target.checked ? setActiveOptionsCount(activeOptionsCount => activeOptionsCount + 1): setActiveOptionsCount(activeOptionsCount => activeOptionsCount - 1)}} />
                <span className="text-sm font-medium ml-2">Failed</span>
              </label>
            </li>
            <li className="py-1 px-3">
              <label className="flex items-center">
              <input id="checkPending" defaultChecked={true} 
              onClick={ e => { props.filterHandler(e.target.id )}} 
              type="checkbox" 
              className="form-checkbox text-ghBlack" 
              onChange={e => {e.target.checked ? setActiveOptionsCount(activeOptionsCount => activeOptionsCount + 1): setActiveOptionsCount(activeOptionsCount => activeOptionsCount - 1)}} />
                <span className="text-sm font-medium ml-2">Pending</span>
              </label>
            </li>
          </ul>
        </div>
      </Transition>
    </div>
  );
}

export default FilterButton;
