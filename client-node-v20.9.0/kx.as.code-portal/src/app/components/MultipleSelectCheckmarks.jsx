import * as React from "react";
import OutlinedInput from "@mui/material/OutlinedInput";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import FormControl from "@mui/material/FormControl";
import ListItemText from "@mui/material/ListItemText";
import Select from "@mui/material/Select";
import Checkbox from "@mui/material/Checkbox";
import { ThemeProvider, createTheme } from "@mui/material/styles";

const ITEM_HEIGHT = 60;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
  PaperProps: {
    style: {
      maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
      width: 230,
    },
  },
};

const statusList = [
  "isInstalled",
  "isFailed",
  "isInstalling",
  "isUninstalling",
  "isPending",
];

const darkTheme = createTheme({
  palette: {
    mode: "dark",
  },
});

export default function MultipleSelectCheckmarks(props) {
  const handleChange = (event) => {
    const {
      target: { value },
    } = event;

    try {
      props.setFilterInstallationStatusList(
        // On autofill we get a stringified value.
        typeof value === "string" ? value.split(",") : value
      );
    } catch (err) {
    } finally {
      let obj = {
        isInstalled: false,
        isFailed: false,
        isInstalling: false,
        isUninstalling: false,
        isPending: false,
      };
      try {
        if (props.filterInstallationStatusList.includes("isInstalled")) {
          obj.isInstalled = true;
        } else if (props.filterInstallationStatusList.includes("IsPending")) {
          obj.isPending = true;
        } else if (props.filterInstallationStatusList.includes("IsFailed")) {
          obj.isFailed = true;
        }
      } catch (err) {
      } finally {
        props.setFilterObj(obj);
      }
    }
  };

  return (
    <div className="ml-2">
      <ThemeProvider theme={darkTheme}>
        <FormControl sx={{ m: 0, width: 230 }}>
          <InputLabel id="demo-multiple-checkbox-label">
            Installation Status
          </InputLabel>
          <Select
            disabled
            labelId="demo-multiple-checkbox-label"
            id="demo-multiple-checkbox"
            multiple
            value={props.filterInstallationStatusList}
            onChange={handleChange}
            input={<OutlinedInput label="Installation Status" />}
            renderValue={(selected) => selected.join(", ")}
            MenuProps={MenuProps}
          >
            {statusList.map((name) => (
              <MenuItem key={name} value={name}>
                <Checkbox
                  checked={
                    props.filterInstallationStatusList.indexOf(name) > -1
                  }
                />
                <ListItemText primary={name} />
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </ThemeProvider>
    </div>
  );
}
