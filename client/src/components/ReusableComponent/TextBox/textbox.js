import React from "react";
import { Input } from "@material-ui/core";
import './textbox.scss';
const TextBox = (props) => {
    return (
        <Input id={props.htmlFor} className={props.className ? props.className : "text-input"} type={props.type ? props.type : "text"} placeholder={props.placeholder ? props.placeholder : ""}/>
    )

}
export default TextBox;