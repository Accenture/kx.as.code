import { React, Component } from "react";
import TemplateCard from "../partials/templates/TemplateCard";
import { Search24, Add24 } from "@carbon/icons-react";
import FilterButton from "../partials/actions/FilterButton";

export default class Templates extends Component {

    drawTemplateCards() {

    }

    render() {

        return (

            <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
                {/* Templates Header */}
                <div className="text-white text-xl font-bold py-5 italic">MY TEMPLATES</div>

                {/* Template actions */}
                <div className="sm:flex sm:justify-between mb-8">

                    {/* Left: Actions */}
                    < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2" >

                        <div className="relative flex w-full flex-wrap items-stretch mb-3">
                            <span className="z-10 h-full leading-snug font-normal absolute text-center text-blueGray-300 absolute bg-transparent rounded text-base items-center justify-center w-8 pl-3 py-3">
                                <Search24 className="text-ghBlack2" />
                            </span>
                            <input type="text" placeholder="Search Templates..." className="px-3 py-3 placeholder-blueGray-300 text-blueGray-600 relative bg-white bg-white rounded-md text-md border-0 shadow outline-none focus:outline-none focus:ring w-full pl-10" />
                        </div>
                        <FilterButton />

                        
                    </div >
                    {/* Right: Actions */}
                    <div className="grid grid-flow-col sm:auto-cols-max justify-end sm:justify-end gap-2" >
                        {/* Add Template button */}
                        < button className="btn h-12 px-7 bg-kxBlue hover:bg-kxBlue2 text-white rounded-md" >
                            <Add24 />
                            <span className="hidden xs:block ml-2">Add Template</span>
                        </ button>
                    </div>
                </div >

                <div className="grid grid-cols-12 gap-8" >
                    {this.drawTemplateCards()}
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                    <TemplateCard />
                </div>

            </div>
        )
    }
}