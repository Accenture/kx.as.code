import { React, Component } from "react";
import ApplicationGroupCard from "../partials/applicationGroups/ApplicationGroupCard";
import { Search24, Add24 } from "@carbon/icons-react";
import FilterButton from "../partials/actions/FilterButton";

export default class ApplicationGroups extends Component {

    drawTemplateCards() {

    }

    render() {

        return (

            <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
                {/* Application Groups Header */}
                <div className="text-white pb-10">
                    <div className="text-xl font-bold italic text-gray-500">APPLICATION GROUPS</div>
                    <div className="pt-4 pb-6">What Application Groups you want to install into your KX.AS Code environemnt?</div>
                    <div className="border-b-2 border-gray-700"></div>
                </div>

                {/* Template actions */}
                <div className="sm:flex sm:justify-between mb-8">

                    {/* Left: Actions */}
                    < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2" >

                        <div className="flex w-full flex-wrap items-stretch mb-3">
                            <span className="h-full leading-snug font-normal text-center text-blueGray-300 absolute bg-transparent rounded text-base items-center justify-center w-8 pl-3 py-3">
                                <Search24 className="text-ghBlack2" />
                            </span>
                            <input type="text" placeholder="Search App Groups..." className="px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring w-full pl-10" />
                        </div>
                        <FilterButton />


                    </div >
                    {/* Right: Actions */}
                    <div className="grid grid-flow-col sm:auto-cols-max justify-end sm:justify-end gap-2" >
                        {/* Add Template button */}
                        < button className="btn h-12 px-4 bg-kxBlue hover:bg-kxBlue2 text-white rounded" >
                            <Add24 />
                            <span className="hidden xs:block">Add Application Group</span>
                        </ button>
                    </div>
                </div >

                <div className="grid grid-cols-12 gap-8" >
                    {this.drawTemplateCards()}
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                    <ApplicationGroupCard />
                </div>

            </div>
        )
    }
}