import { React, Component } from "react";
import ApplicationCard from "../ApplicationCard";


export default class ApplicationView extends Component {

  constructor(props) {
    super(props);
    this.state = {
      queueData: [],
      isLoading: true
    };
  }

  componentDidMount() {
    this.setState({
      queueData: this.props.queueData,
      isLoading: this.props.isLoading
    })
    console.log("QueData Breakpoint-2: ", this.state.queueData)
  }

  static getDerivedStateFromProps(nextProps, prevState){
    return {
      queueData: nextProps.queueData
    };
  }

  drawApplicationCards() {
    if (!this.state.isLoading) {
      return <div className="--profile-cards">
        {this.state.queueData !== 'undefined' ? this.itemList() : "Empty Queue"}
      </div>
    }
    else {
      return <div>Loading...</div>
    }
  }


  itemList() {
    console.log("QueData Breakpoint-1: ", this.state.queueData)
    // this.state.queueData.map(app => {
    //   return <ApplicationCard app={app} />
    // })
  }

  render() {

    return (
      <div>
        {/* <ApplicationTable/> */}

        {this.drawApplicationCards()}

        ApplicationView Component
      </div>
    );
  }
}