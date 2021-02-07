import React from "react";
import { Box, Grid } from "@material-ui/core";
import "./Cards.scss"


const Cards = (props) => {
    const card = props.card
    return (
        <Box
            display="flex"
            flexDirection="row"
            justifyContent="center"
            alignItems="flex-start"
        >
            <Grid container direction="row" justify="flex-start" alignItems="center" id="card-container">
                {props.children && <Box id="card">{props.children}</Box>}
                {card && <Box id="card">
                    {card.map(([key, value]) => <Box id="card-key" key={key}>{key}<span id="card-value">{value.toString()}</span></Box>)}
                </Box>}
            </Grid>
        </Box>
    )
}

export default Cards;
