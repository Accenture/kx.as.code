import * as React from "react";
import Pagination from "@mui/material/Pagination";
import Stack from "@mui/material/Stack";
import { makeStyles, createStyles } from "@material-ui/styles";

interface PaginationRoundedProps {
  count: number;
  page: number;
  setPageAndJumpData: (event: React.ChangeEvent<unknown>, page: number) => void;
  PER_PAGE: number;
}

const useStyles = makeStyles((theme) =>
  createStyles({
    root: {
      selected: {
        backgroundColor: "green",
      },
    },
  })
);

const PaginationRounded: React.FC<PaginationRoundedProps> = (props) => {
  const classes = useStyles();

  const handleChange = (event: React.ChangeEvent<unknown>, page: number) => {
    props.setPageAndJumpData(event, page);
  };

  return (
    <Stack spacing={2}>
      <Pagination
        count={props.count}
        variant="outlined"
        shape="rounded"
        onChange={handleChange}
        page={props.page}
      />
    </Stack>
  );
};

export default PaginationRounded;
