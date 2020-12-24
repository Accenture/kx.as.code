import React from "react";
import UIView, { NewProfileHeader, NewProfileFooter } from "../index"
import { Box } from "@material-ui/core";



const NewProfileTemplate = (props) => {
    return (
        <Box id="new-profile-wrapper">
            {/* Current view to be captured from redux store*/}
            <NewProfileHeader view={UIView.General}/>
            {/* ---- Start render all children ---- */}
            <Box id="new-profile-main-content">
                <Box >{props.children}</Box>
                <Box id="new-profile-footer">
                    {/* Current view to be captured from redux store*/}
                    <NewProfileFooter view={UIView.General}/>
                </Box>
            </Box>
        </Box>
    )
}

export default NewProfileTemplate;