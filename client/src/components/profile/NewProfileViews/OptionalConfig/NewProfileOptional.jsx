import React from "react";
import "./NewProfileOptional.scss";
import { withRouter } from "react-router";
import { NewProfileTemplate, NewProfileOptionalForm } from "../../index";

const NewProfileOptional = () => {
    return(
        <NewProfileTemplate>
            <NewProfileOptionalForm />
        </NewProfileTemplate>
    )
}

export default withRouter(NewProfileOptional);