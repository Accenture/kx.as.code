import React from "react";
import "./NewProfileResource.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate } from "../../index";

const NewProfileResource = () => {
    return(
        <NewProfileTemplate>
            <h1 id="new-profile-resource">Resource configuration</h1>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileResource);