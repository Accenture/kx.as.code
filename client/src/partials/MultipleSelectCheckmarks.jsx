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

const statusList = ["Installed", "Pending", "Not Installed", "Failed"];
const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
});

export default function MultipleSelectCheckmarks() {
  const [status, setStatus] = React.useState([]);

  const handleChange = (event) => {
    const {
      target: { value },
    } = event;
    setStatus(
      // On autofill we get a stringified value.
      typeof value === "string" ? value.split(",") : value
    );
    console.log("status: ", status);
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
            value={status}
            onChange={handleChange}
            input={<OutlinedInput label="Installation Status" />}
            renderValue={(selected) => selected.join(", ")}
            MenuProps={MenuProps}
          >
            {statusList.map((s) => (
              <MenuItem key={s} value={s}>
                <Checkbox checked={status.indexOf(s) > -1} />
                <ListItemText primary={s} />
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </ThemeProvider>
    </div>
  );
}
