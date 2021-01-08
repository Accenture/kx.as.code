import React from "react";
import { Box, Grid, label, Button } from "@material-ui/core";
import "./InstalledCard.scss";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";


const InstalledCard = (props) => {
    const card = props.data
    return (
        <Box
            display="flex"
            flexDirection="row"
            justifyContent="center"
            alignItems="flex-start"
        >
            <Grid container direction="column" justify="flex-start" alignItems="center" id="card-container1">
              <Box className="first-1">
              <label>{card.group}</label>
              <FontAwesomeIcon className="font-icon-progress1" icon="bars" />
              </Box>
               <Box className="first-2">
                   <h3>{card.name}</h3>
               </Box>
               <Box className="first-3">
               <p>{card.description}</p>
               </Box>
               <Box className="install-but">
                   <Button className="prof-card-btn-install">
                    INSTALL
                   </Button>
               </Box>
               
               <label className="cores">{card.cores}</label>
            </Grid>
        </Box>
    )
}

export default InstalledCard;