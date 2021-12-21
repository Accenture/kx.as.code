import { React, Component } from "react";
import ApplicationGroupCard from "../partials/applicationGroups/ApplicationGroupCard";
import { Search24, Add24 } from "@carbon/icons-react";
import FilterButton from "../partials/actions/FilterButton";
import Modal from "../partials/applicationGroups/Modal";

const applicationGroupJson = require('../../src/data/application-groups.json');

export default class ApplicationGroups extends Component {

    constructor(props) {
        super(props)
        this.state = {
            applicationGroupsData: [],
            showModal: false,
            searchTerm: ""
        }
        this.modalHandler = this.modalHandler.bind(this)
    }

    componentDidMount() {
        this.fetchApplicationGroupsData();
        this.setState({
            applicationGroupsData: applicationGroupJson
        })
    }

    modalHandler(boolean) {
        this.setState({
            showModal: boolean
        })
    }

    drawApplicationGroupCards() {
        return applicationGroupJson.filter((val) => {
            if (this.state.searchTerm == "") {
                return val
            }
            else if (val.name.toLowerCase().includes(this.state.searchTerm.toLowerCase().trim())) {
                return val
            }
        }).map((appGroup, i) => {
            return <ApplicationGroupCard appGroup={appGroup} key={i} />
        })
    }

    fetchApplicationGroupsData() {
        this.setState({

        })
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

                {/* Application Groups actions */}
                <div className="sm:flex sm:justify-between mb-8">

                    {/* Left: Actions */}
                    < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2" >

                        <div className="flex w-full flex-wrap items-stretch mb-3">
                            <span className="h-full leading-snug font-normal text-center text-blueGray-300 absolute bg-transparent rounded text-base items-center justify-center w-8 pl-3 py-3">
                                <Search24 className="text-gray-400" />
                            </span>
                            <input type="text"
                                placeholder="Search Application Groups..."
                                className="bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring min-w-80 pl-10"
                                onChange={e => { this.setState({ searchTerm: e.target.value }); console.log(this.state.searchTerm) }} />
                        </div>
                        {/* <FilterButton /> */}


                    </div >
                    {/* Right: Actions */}
                    <div className="grid grid-flow-col sm:auto-cols-max justify-end sm:justify-end gap-2" >
                        {/* Add Template button */}
                        < button onClick={this.modalHandler} className="btn h-12 px-4 bg-kxBlue hover:bg-kxBlue2 text-white rounded"
                        >
                            <Add24 />
                            <span className="hidden xs:block">Add Application Group</span>
                        </ button>
                    </div>
                </div >

                <div className="grid grid-cols-12 gap-8" >
                    {this.drawApplicationGroupCards()}
                </div>

                <Modal showModal={this.state.showModal}
                    modalHandler={this.modalHandler} />

            </div>
        )
    }
}