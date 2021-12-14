import { React, Component } from "react";
import ApplicationCard from "../ApplicationCard";
import axios from "axios";

const queueList = ['pending_queue', 'failed_queue', 'completed_queue', 'retry_queue', 'wip_queue'];

export default class ApplicationView extends Component {

  constructor(props) {
    super(props);
    this.state = {
      queueData: [],
      queueList: queueList,
      isLoading: true,
      intervallId: null
    };
  }

  componentDidMount() {
    this.fetchQueueDataAndExtractApplicationMetadata();
    this.setState({
      isLoading: false
    });
    //var intervallId = setInterval(this.fetchQueueDataAndExtractApplicationMetadata, 10000)
    //this.setState({ intervallId: intervallId });
  }

  componentWillUnmount() {
    clearInterval(this.state.intervallId);
  }

  drawApplicationCards() {
    return this.state.queueData.map(app => {
      return <ApplicationCard app={app} />
    })
  }

  appList() {
    if (this.state.isLoading == false) {
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
      appName: JSON.parse(message.payload).name,
      category: JSON.parse(message.payload).install_folder,
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
    axios.get("http://localhost:5000/queues/" + queue).then(response => {
      response.data.forEach(message => {
        this.s_function(message, queue)
      });
    });
  }

  render() {

    return (
      <div>
        <div className="">
          {this.drawApplicationCards()}
        </div>
      </div>
    );
  }
}