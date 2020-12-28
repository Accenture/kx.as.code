import React from "react";
import "./NewProfileStorage.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate } from "../../index";

const NewProfileStorage = () => {
    return(
        <NewProfileTemplate>
            <h1 id="new-profile-storage">Network and Storage</h1>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileStorage);