import * as React from "react";
import Pagination from "@mui/material/Pagination";
import Stack from "@mui/material/Stack";
import { makeStyles, createStyles } from "@material-ui/styles";
import { countBy } from "lodash";

const useStyles = makeStyles((theme) =>
  createStyles({
    root: {
      selected: {
        backgroundColor: "green",
      },
    },
  })
);

export default function PaginationRounded(props) {
  const classes = useStyles();
  // const PER_PAGE = 4;

  // const _DATA = usePagination(props.data, PER_PAGE);

  const handleChange = (e, p) => {
    props.setPageAndJumpData(e, p);
  };

  // const count = Math.ceil(data.length / PER_PAGE);
  return (
    <Stack spacing={2}>
      {/* <Pagination count={10} shape="rounded" className={classes.root} /> */}
      <Pagination
        count={props.count}
        variant="outlined"
        shape="rounded"
        onChange={handleChange}
        page={props.page}
      />
    </Stack>
  );
}
