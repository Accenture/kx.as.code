import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate } from "../../index";

const NewProfileReview = () => {
    return(
        <NewProfileTemplate>
            <h1 id="new-profile-review">Review and Launch</h1>
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileReview);