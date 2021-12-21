import { React, Component } from "react";
import ApplicationCard from "../partials/applications/ApplicationCard.jsx";
import axios from "axios";
import FilterButton from "../partials/actions/FilterButton"
import { Search24 } from "@carbon/icons-react";

const queueList = ['pending_queue', 'failed_queue', 'completed_queue', 'retry_queue', 'wip_queue'];


export default class Applications extends Component {

    constructor(props) {
        super(props);
        this.state = {
            queueData: [],
            queueList: queueList,
            intervalId: null,
            searchTerm: "",
            searchResultsCount: 0,
            isCompleted: true,
            isFailed: true,
            isPending: true
        };
        this.filterHandler = this.filterHandler.bind(this)
    }

    componentDidMount() {
        this.fetchQueueDataAndExtractApplicationMetadata();
        this.setState({
            isLoading: false
        });
    }

    componentWillUnmount() {
        // clearInterval(this.state.intervalId)
    }

    filterHandler(filterId) {
        if (filterId == "checkCompleted") {
            this.setState({ isCompleted: !this.state.isCompleted })
        }
        else if (filterId == "checkFailed") {
            this.setState({ isFailed: !this.state.isFailed })
        }
        else if (filterId == "checkPending") {
            this.setState({ isPending: !this.state.isPending })
        }
    }

    drawApplicationCards() {
        console.log("draw app cards func")
        let countFiltered = this.state.queueData.filter((val) => {
            if (this.state.searchTerm == "") {
                return val
            }
            else if (val.appName.toLowerCase().includes(this.state.searchTerm.toLowerCase())) {
                return val
            }
        }).length

        return this.state.queueData.filter((val) => {
            if (this.state.searchTerm == "") {
                return val
            }
            else if (val.appName.toLowerCase().includes(this.state.searchTerm.toLowerCase())) {
                return val
            }
        }).filter((val) => {
            if (this.state.isCompleted && val.queueName == "completed_queue") {
                return val
            }
            else if (this.state.isFailed && val.queueName == "failed_queue") {
                return val
            }
            else if (this.state.isPending && val.queueName == "pending_queue") {
                return val
            }
        }).map((app, i) => {
            return <ApplicationCard app={app} key={i} />
        })

    }

    appList() {
        if (this.state.isLoading === false) {
            this.state.queueData.forEach(app => {
                return <div>{app.appName}</div>
            });
        }
        else {
            return <div>Loading...</div>
        }
    }


    async f_setAppMetaData(message, queue) {
        var app = {
            queueName: queue,
            appName: JSON.parse(message.payload).name.replaceAll("-", " ").replace(/\b\w/g, l => l.toUpperCase()),
            category: JSON.parse(message.payload).install_folder.replace(/\b\w/g, l => l.toUpperCase()),
            retries: JSON.parse(message.payload).retries
        }
        return app;
    }

    async s_function(message, queue) {
        const app = await this.f_setAppMetaData(message, queue);
        const queueDataTmp = this.state.queueData
        queueDataTmp.push(app);
        this.setState({
            queueData: queueDataTmp
        })
    }

    fetchQueueDataAndExtractApplicationMetadata() {
        this.state.queueList.forEach(queue => this.fetchData(queue));
        this.setState({
            isLoading: false
        })
    }

    fetchData(queue) {
        axios.get("http://localhost:5000/api/queues/" + queue).then(response => {
            response.data.forEach(message => {
                this.s_function(message, queue)
            });
        });
    }
    render() {

        return (
            <div className="px-6 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
                {/* Applications Header */}
                <div className="text-white pb-10">
                    <div className="text-xl font-bold italic text-gray-500">APPLICATIONS</div>
                    <div className="pt-4 pb-6">What Applications you want to install into your KX.AS Code environemnt?</div>
                    <div className="border-b-2 border-gray-700"></div>
                </div>

                {/* Applications actions */}
                <div className="sm:flex sm:items-center mb-8">
                    {/* Left: Actions */}
                    < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2" >

                        <div className="flex w-full flex-wrap items-stretch mb-3">
                            <span className="h-full leading-snug font-normal text-center text-blueGray-300 absolute bg-transparent rounded text-base items-center justify-center w-8 pl-3 py-3">
                                <Search24 className="text-gray-400" />
                            </span>
                            <input onChange={e => { this.setState({ searchTerm: e.target.value }); console.log(this.state.searchTerm) }}
                                type="text" placeholder="Search Applications..."
                                className="bg-ghBlack2 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 rounded text-md border-0 shadow outline-none focus:outline-none focus:ring w-full pl-10" />
                        </div>
                        <FilterButton filterHandler={this.filterHandler}
                            isCompleted={this.state.isCompleted}
                            isFailed={this.state.isFailed}
                            isPending={this.state.isPending} />
                    </div >
                </div >
                <div className="grid grid-cols-12 gap-8" >
                    {this.drawApplicationCards()}
                </div>

            </div>
        );
    }
}