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

  componentDidUpdate() {
    this.setState({
      queueData: this.props.queueData,
      isLoading: this.props.isLoading
    })
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
    this.state.queueData.map(app => {
      return <ApplicationCard app={app} />
    })
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