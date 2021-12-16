import { React, Component } from "react";
import ApplicationCard from "../partials/applications/ApplicationCard.jsx";
import axios from "axios";

const queueList = ['pending_queue', 'failed_queue', 'completed_queue', 'retry_queue', 'wip_queue'];


export default class Applications extends Component {

    constructor(props) {
        super(props);
        this.state = {
            queueData: [],
            queueList: queueList,
            intervalId: null, 
            searchTerm: "", 
            searchResultsCount: 0
        };
    }

    componentDidMount() {
        this.fetchQueueDataAndExtractApplicationMetadata();
        this.setState({
            isLoading: false
        });
    }

    componentWillUnmount(){
        // clearInterval(this.state.intervalId)
    }

    drawApplicationCards() {
        let countFiltered = this.state.queueData.filter((val) => {
            if(this.state.searchTerm == ""){
                return val
            }
            else if(val.appName.toLowerCase().includes(this.state.searchTerm.toLowerCase())){
                return val
            }
        }).length
        
        return this.state.queueData.filter((val) => {
            if(this.state.searchTerm == ""){
                return val
            }
            else if(val.appName.toLowerCase().includes(this.state.searchTerm.toLowerCase())){
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
                <div className="text-white text-xl font-bold py-5 italic">MY APPLICATIONS</div>

                {/* Dashboard actions */}
                < div className="sm:flex sm:items-center mb-8" >

                    {/* Right: Actions */}
                    < div className="grid grid-flow-col sm:auto-cols-max justify-start sm:justify-start gap-2" >
                       
                        {/* Add view button */}
                        {/* < button className="btn px-4 bg-gray-500 hover:bg-gray-600 text-white" >
                            <svg className="w-4 h-4 fill-current opacity-50 flex-shrink-0" viewBox="0 0 16 16">
                                <path d="M15 7H9V1c0-.6-.4-1-1-1S7 .4 7 1v6H1c-.6 0-1 .4-1 1s.4 1 1 1h6v6c0 .6.4 1 1 1s1-.4 1-1V9h6c.6 0 1-.4 1-1s-.4-1-1-1z" />
                            </svg>
                            <span className="hidden xs:block ml-2">Add Application</span>
                        </ button> */}
                        <input onChange={e => {this.setState({ searchTerm: e.target.value}); console.log(this.state.searchTerm)}} type="text" className="text-white bg-ghBlack3 text-md border-2 border-ghBlack3 h-12 w-80 p-4 px-3 rounded-md focus:border-2 focus:border-acnRed" placeholder="Search Applications..."/>
                    </div >

                </div >

                <div className="grid grid-cols-12 gap-8" >
                    {this.drawApplicationCards()}
                </div>
            </div>
        );
    }
}