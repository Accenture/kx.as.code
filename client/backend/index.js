import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import * as API from 'api';
import URLSearchParams from 'url-search-params';

import './style.css';

export default class Sum extends React.Component{
  constructor(props){
    super(props);
    this.state = {
      a: '',
      b: '',
      result: ''  
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentDidMount() { 
    console.log(API);
    API.subscribe(({result})=>{
      this.setState({
        result: result
      })
   });
  }

  handleChange(event) {
    this.setState({
      [event.target.name]: event.target.value}
    );
  }

  handleSubmit(event) {
    event.preventDefault();

    const params = new URLSearchParams();
    params.append('a', this.state.a);
    params.append('b', this.state.b);

    fetch(`${API.API_URL}/api/calc/sum`, { method: 'POST', body: params })
    .then(res => res.json());
  }

  render() {
    const result = this.state.result ? (         
      <label>
          Result:
          <input type="text" value={this.state.result} name='b' readOnly />
      </label>
    ) : '';
    return (
      <form onSubmit={this.handleSubmit}>
        <label>
          A:
          <input type="text" name='a' onChange={this.handleChange} />
        </label>
        <label>
          B:
          <input type="text"  name='b' onChange={this.handleChange} />
        </label>
      {result}
            <br/>
        <input type="submit"  value="Add" />
      </form>
    );
  }
}

ReactDOM.render(
  <Sum />,
  document.getElementById("mainReact")
);