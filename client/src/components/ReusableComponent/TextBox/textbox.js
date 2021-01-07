import React from "react";
import { Input } from "@material-ui/core";
import './textbox.scss';

const TextBox = (props) => {
    return (
        <Input 
            id={props.htmlFor} 
            name={props.name}
            className={props.className ? props.className : "text-input"} 
            type={props.type ? props.type : "text"} 
            placeholder={props.placeholder ? props.placeholder : ""}
            onChange={props.onChange}
            value={props.value}
        />
    )

}
export default TextBox;