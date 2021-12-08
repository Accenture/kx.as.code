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
        };
    }

    componentDidMount() {
        this.fetchQueueDataAndExtractApplicationMetadata();
        this.setState({
            isLoading: false
        });
    }

    drawApplicationCards() {
        return this.state.queueData.map((app, i) => {
            return <ApplicationCard app={app} key={i}/>
        })
    }

    appList() {
        if (this.state.isLoading == false) {
            console.log("length-2:", this.state.queueData.length)
            this.state.queueData.forEach(app => {
                console.log("debug-3 QData: ", app.appName)
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
        console.log("debug-qData: ", this.state.queueData)
        this.setState({
            isLoading: false
        })
    }

    fetchData(queue) {
        console.log("debug-qList elem: ", queue)
        axios.get("http://localhost:5000/queues/" + queue).then(response => {
            response.data.forEach(message => {
                this.s_function(message, queue)
            });
        });
    }
    render() {

        return (
            <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
                {/* Applications Header */}
                <div className="text-white text-xl font-bold py-5 italic">MY APPLICATIONS</div>
                <div className="grid grid-cols-12 gap-8" >
                    {this.drawApplicationCards()}
                </div>
            </div>
        );
    }
}