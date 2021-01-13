import React from "react";
import "./NewProfileReview.scss";
import { withRouter } from "react-router";
import { Box, Grid } from "@material-ui/core";
import { NewProfileTemplate, KubernetesInstallation } from "../../index";
import { Cards } from "../../../ReusableComponent/index";
import { connect } from "react-redux";
import NewProfileReview1 from "./NewProfileReview1";
import NewProfileReview2 from "./NewProfileReview2";
import { UIView } from "../../../../redux/reducers/viewsReducer";

const NewProfileReview = (props) => {
    return (
        <NewProfileTemplate>
            <Box
                id="new-prof-review-container"
                display="flex"
                flexDirection={((props.view ===UIView.ReviewA) || (props.view ===UIView.Review))?"row":"column"}
                justifyContent="center"
                alignItems="flex-start"
            >
                <Grid container direction={((props.view ===UIView.ReviewA) || (props.view ===UIView.Review))?"column":"row"} justify="flex-start" alignItems="center">
                    <Grid item>
                        <NewProfileReview1/>
                    </Grid>
                    {((props.view ===UIView.Installation) ||(props.view === UIView.ReviewA)) && 
                        <Grid item>
                            <NewProfileReview2/>
                        </Grid>
                    }
                    {(props.view ===UIView.Installation) && 
                        <Grid item id="installation-container">
                                <KubernetesInstallation/>
                        </Grid>
                    }
                </Grid>
            </Box>
        </NewProfileTemplate>
    )
}


const mapStateToProps = state => ({
    view: state.viewsReducer.currentView
  });

export default connect(mapStateToProps, null)(withRouter(NewProfileReview));