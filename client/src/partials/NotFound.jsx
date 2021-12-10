import React from 'react'
import {FaceDissatisfied32} from "@carbon/icons-react"

export default function NotFound() {
    return (
        <div className="text-center">
                    <FaceDissatisfied32 className="table mx-auto my-10"/>
                    <div className="font-light text-4xl text-center">Unfortunately, we could not find the page.</div>
                    <div className="text-lg mt-5">Check the link or use our search to find the right thing.</div>
        </div>
    )
}
