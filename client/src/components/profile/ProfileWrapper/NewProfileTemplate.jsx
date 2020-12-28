import React from "react";
import { NewProfileHeader, NewProfileFooter } from "../index"
import { Box } from "@material-ui/core";
import { connect } from "react-redux";

const NewProfileTemplate = (props) => {
    return (
        <Box id="new-profile-wrapper">
            {/* Current view to be captured from redux store*/}
            <NewProfileHeader view={props.view} />
            {/* ---- Start render all children ---- */}
            <Box id="new-profile-main-content">
                <Box >{props.children}</Box>
                <Box id="new-profile-footer">
                    {/* Current view to be captured from redux store*/}
                    <NewProfileFooter view={props.view} />
                </Box>
            </Box>
        </Box>
    )
}

const mapStateToProps = state => ({
    view: state.viewsReducer.currentView
});

export default connect(mapStateToProps)(NewProfileTemplate);