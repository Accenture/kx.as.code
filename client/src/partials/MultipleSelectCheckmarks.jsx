import * as React from "react";
import OutlinedInput from "@mui/material/OutlinedInput";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import FormControl from "@mui/material/FormControl";
import ListItemText from "@mui/material/ListItemText";
import Select from "@mui/material/Select";
import Checkbox from "@mui/material/Checkbox";
import { ThemeProvider, createTheme } from "@mui/material/styles";

const ITEM_HEIGHT = 50;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
  PaperProps: {
    style: {
      maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
      width: 230,
    },
  },
};

const statusList = ["failed_queue", "completed_queue", "pending_queue"];
const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
});

export default function MultipleSelectCheckmarks(props) {
  // const [status, setStatus] = React.useState([]);

  const [selectValueList, setSelectValueList] = React.useState([]);

  const getSelectStatusListItem = (string) => {
    if (string === "completed_queue") {
      return "Installed";
    } else if (string === "pending_queue") {
      return "Pending";
    } else if (string === "failed_queue") {
      return "Failed";
    }
  };

  const getSelectValueList = (list) => {
    let valueList = [];
    list.map((elem) => {
      if (elem === "completed_queue") {
        valueList.push("Installed");
      } else if (elem === "pending_queue") {
        valueList.push("Pending");
      } else if (elem === "failed_queue") {
        valueList.push("Failed");
      }
    });
    return valueList;
  };

  const handleChange = (event) => {
    const {
      target: { value },
    } = event;
    // setStatus(
    //   // On autofill we get a stringified value.
    //   typeof value === "string" ? value.split(",") : value
    // );
    props.setFilterStatusList(
      typeof value === "string" ? value.split(",") : value
    );
    // console.log("status: ", props.filterStatusList);
  };

  return (
    <div className="ml-2">
      <ThemeProvider theme={darkTheme}>
        <FormControl sx={{ m: 0, width: 230 }}>
          <InputLabel id="demo-multiple-checkbox-label">
            Installation Status
          </InputLabel>
          <Select
            labelId="demo-multiple-checkbox-label"
            id="demo-multiple-checkbox"
            multiple
            value={props.filterStatusList}
            onChange={handleChange}
            input={<OutlinedInput label="Installation Status" />}
            renderValue={(selected) => selected.join(", ")}
            MenuProps={MenuProps}
          >
            {statusList.map((s) => (
              <MenuItem key={s} value={s}>
                <Checkbox checked={props.filterStatusList.indexOf(s) > -1} />
                <ListItemText primary={getSelectStatusListItem(s)} />
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </ThemeProvider>
    </div>
  );
}
