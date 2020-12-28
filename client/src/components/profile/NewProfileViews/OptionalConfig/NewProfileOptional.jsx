import React from "react";
import "./NewProfileOptional.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate } from "../../index";

const NewProfileOptional = () => {
    return(
        <NewProfileTemplate>
            <h1 id="new-profile-optional">Optional configuration</h1>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileOptional);