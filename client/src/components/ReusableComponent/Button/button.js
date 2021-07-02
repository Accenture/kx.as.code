import React from "react";
import { Button } from "@material-ui/core";
import './button.scss'
const MatButton = (props) => {
    return (
        <Button onClick={props.onClick} className={props.className} >{props.children}</Button>
    )

}
export default MatButton;
