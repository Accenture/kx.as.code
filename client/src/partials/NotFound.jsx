import React from 'react'
import {FaceDissatisfied32} from "@carbon/icons-react"

import sadEmoji from "../media/svg/sad.svg"

export default function NotFound() {
    return (
        <div className="text-center">
                    <img className="tabel m-auto my-10" src={sadEmoji} height="100px" width="100px" alt="sad-emoji" />
                    <div className="font-light text-4xl text-center">Unfortunately, we could not find the page.</div>
                    <div className="text-lg mt-5">Check the link or use our search to find the right thing.</div>
        </div>
    )
}
