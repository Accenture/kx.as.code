import { Close24, Close32 } from '@carbon/icons-react';
import React, { useEffect, useRef } from 'react'

export default function Modal(props) {

    const trigger = useRef(null);
    const modal = useRef(null);

    // close if the esc key is pressed
    useEffect(() => {
        const keyHandler = ({ keyCode }) => {
            if (!props.showModal || keyCode !== 27) return;
            props.modalHandler(!props.showModal)
        };
        document.addEventListener('keydown', keyHandler);
        return () => document.removeEventListener('keydown', keyHandler);
    });

    // close on click outside
    useEffect(() => {
        const clickHandler = ({ target }) => {
            if (!modal.current || !trigger.current) return;
            if (!props.showModal || modal.current.contains(target) || trigger.current.contains(target)) return;
            props.modalHandler(!props.showModal)
        };
        document.addEventListener('click', clickHandler);
        return () => document.removeEventListener('click', clickHandler);
    });

    return (
        <>
            {props.showModal ? <div
                className="bg-inv2 overflow-x-hidden overflow-y-hidden fixed inset-x-96 inset-y-40 z-50 outline-none focus:outline-none shadow-lg rounded"
                ref={modal}>

                {/* Modal Header */}
                <div className="sm:flex sm:justify-between mb-8 bg-ghBlack">
                    <div className="text-xl font-bold italic text-gray-500 table m-auto">ADD APPLICATION GROUP</div>
                    {/* Modal Actions (Right) */}
                    <button ref={trigger}
                        onClick={() => props.modalHandler(!props.showModal)}
                        className="p-1 bg-kxBlue b-0 hover:bg-kxBlue2"><Close32/>
                    </button>
                </div>
                <div className="w-auto my-6 p-10">Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</div>

            </div> : null}
        </>
    )
}
