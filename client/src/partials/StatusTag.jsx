import React from 'react'


export default function StatusTag(props) {

    function getTagBgColor(installStatus){
        if(installStatus === "completed_queue"){
            return "bg-statusGreen"
        }
        else if(installStatus === "pending_queue"){
            return "bg-statusOrange"
        }
        else if(installStatus === "failed_queue"){
            return "bg-statusRed"
        }
        else if(installStatus === "vip_queue"){
            return "bg-statusYellow"
        }
        else if(installStatus === "retry_queue"){
            return "bg-statusGray"
        }
        else{
            console.error("Unknown Installation Status (Install Status Tag)")
        }
    }

    function getTagContent(installStatus){
        if(installStatus === "completed_queue"){
            return "Installed"
        }
        else if(installStatus === "pending_queue"){
            return "Install Pending"
        }
        else if(installStatus === "failed_queue"){
            return "Failed"
        }
        else if(installStatus === "vip_queue"){
            return "VIP"
        }
        else if(installStatus === "retry_queue"){
            return "Reinstalling"
        }
        else{
            console.error("Unknown Installation Status (Install Status Tag)")
        }
    }

    return (
        <div className={ "text-white bg-opacity-70 rounded p-1 px-3 text-xs flex m-auto ml-2 " + getTagBgColor(props.installStatus) } >
            {getTagContent(props.installStatus)}
        </div>
    )
}
