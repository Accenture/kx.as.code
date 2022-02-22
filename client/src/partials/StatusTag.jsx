import React from 'react'


export default function StatusTag(props) {

    function getTagBgColor(installStatus){
        if(installStatus === "completed_queue"){
            return "bg-statusNewGreen"
        }
        else if(installStatus === "pending_queue"){
            return "bg-statusNewOrange"
        }
        else if(installStatus === "failed_queue"){
            return "bg-statusNewRed"
        }
        else if(installStatus === "vip_queue"){
            return "bg-statusNewYellow"
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
            return "INSTALLED"
        }
        else if(installStatus === "pending_queue"){
            return "PENDING"
        }
        else if(installStatus === "failed_queue"){
            return "FAILED"
        }
        else if(installStatus === "vip_queue"){
            return "VIP"
        }
        else if(installStatus === "retry_queue"){
            return "REINSTALLING"
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
