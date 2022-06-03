import * as React from "react";
import Pagination from "@mui/material/Pagination";
import Stack from "@mui/material/Stack";
import { makeStyles, createStyles } from "@material-ui/styles";

const useStyles = makeStyles((theme) =>
  createStyles({
    root: {
      selected: {
        backgroundColor: "green",
      },
    },
  })
);

export default function PaginationRounded() {
  const classes = useStyles();
  return (
    <Stack spacing={2}>
      {/* <Pagination count={10} shape="rounded" className={classes.root} /> */}
      <Pagination count={10} variant="outlined" shape="rounded" />
    </Stack>
  );
}
