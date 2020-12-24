import React from "react";
import { Input } from "@material-ui/core";
import './textbox.scss';
const TextBox = (props) => {
    return (
        <Input id={props.htmlFor} className={props.className} type="text" />
    )

}
export default TextBox;