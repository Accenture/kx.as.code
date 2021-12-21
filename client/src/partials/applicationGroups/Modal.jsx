import React from 'react'

export default function Modal(props) {
    return (
        <>
           { props.showModal ? <div 
           className="bg-inv2 justify-center items-center flex overflow-x-hidden overflow-y-hidden fixed inset-80 z-50 outline-none focus:outline-none shadow-lg rounded border-gray-600 border-3">
               <div className="relative w-auto my-6 mx-auto max-w-3xl">
                   <button onClick={() => props.modalHandler(!props.showModal)} className="p-10 bg-green-500 b-0">X</button>
                   Model Component</div>
            
            </div> : null}          
        </>
    )
}
