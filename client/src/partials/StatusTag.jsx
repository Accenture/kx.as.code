import React from 'react'


export default function StatusTag(props) {

    function getTagBgColor(installStatus){
        switch (installStatus) {
            case "completed_queue":
                return "bg-statusGreen"
            case "pending_queue":
                return "bg-statusOrange"
            case "failed_queue":
                return "bg-statusRed"
            case "vip_queue":
                return "bg-statusYellow"
            case "retry_queue":
                return "bg-statusGray"

            default:
                console.error("Unknown Installation Status (Install Status Tag)")
                break;
        }
    }

    return (
        <div className={ "rounded-xl p-1 px-3 text-xs flex m-auto ml-2" + getTagBgColor(props.installStatus) } >

{/*             
            className={`hover:bg-drei px-6 py-2 last:mb-0 ${pathname.includes('applications') ? 'pl-7 bg-gray-800 hover:bg-gray-800' : 'bg-transparent hover:bg-drei'}`} */}

            {props.installStatus}
        </div>
    )
}
