import React from "react";
import Select from '@material-ui/core/Select';
import './dropdown.scss'
const DropDown = (props) => {

    return (
        <Select
            native
            className="select"
            onChange={props.onChange}
            name={props.name}
            value={props.value}
        >
            <option value="" disabled defaultValue>OPTIONS</option>
            {props.data.map((data,id) =>
                <option key={id} value={data} style={{backgroundColor: '#212938',color:'white',textAlign:'center'}}>{data}</option>
            )}
        </Select>
    )

}
export default DropDown; 