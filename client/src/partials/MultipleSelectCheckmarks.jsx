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
  // const [status, setStatus] = React.useState([]);

  const [selectValueList, setSelectValueList] = React.useState([]);

  const [filterObj, setFilterObj] = React.useState({
    isInstalled: false,
    isFailed: false,
    isInstalling: false,
    isUninstalling: false,
    isPending: false,
  });

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
      if (elem === "isInstalled") {
        valueList.push("Installed");
      } else if (elem === "pending_queue") {
        valueList.push("Pending");
      } else if (elem === "failed_queue") {
        valueList.push("Failed");
      }
    });
    return valueList;
  };

  const setUpFilterObjAndSetFilterObj = (list) => {
    if (list.includes("isInstalled")) {
      filterObj.isCompleted = true;
    } else if (list.includes("isPending")) {
      filterObj.isPending = true;
    } else if (list.includes("isFailed")) {
      filterObj.isFailed = true;
    }

    // props.setFilterInstallationStatusList(filterObj);
  };

  const handleChange = (event) => {
    const {
      target: { value },
    } = event;

    // console.log("VALUE: ", value);
    // setStatus(
    //   // On autofill we get a stringified value.
    //   typeof value === "string" ? value.split(",") : value
    // );
    // props.setFilterStatusList(
    //   typeof value === "string" ? value.split(",") : value
    // );
    // props.setFilterInstallationStatusObj();
    // console.log("status: ", props.filterStatusList);

    props.setFilterInstallationStatusList(
      // On autofill we get a stringified value.
      typeof value === "string" ? value.split(",") : value
    );

    // setUpFilterObjAndSetFilterObj(statusList);
  };

  return (
    <div className="ml-2">
      <ThemeProvider theme={darkTheme}>
        <FormControl sx={{ m: 0, width: 230 }}>
          <InputLabel id="demo-multiple-checkbox-label">
            Installation Status
          </InputLabel>
          {/* 
          <Select
            labelId="demo-multiple-checkbox-label"
            id="demo-multiple-checkbox"
            multiple
            value={Object.keys(props.filterInstallationStatusObj)} //-> Hier die keys umwandeln
            onChange={handleChange}
            input={<OutlinedInput label="Installation Status" />}
            renderValue={(selected) => selected.join(", ")}
            MenuProps={MenuProps}
          >
            {Object.keys(props.filterInstallationStatusObj).map((s) => (
              <MenuItem key={s} value={s}>
                <Checkbox checked={props.filterStatusList.indexOf(s) > -1} />
                <ListItemText primary={s} />
                <ListItemText
                  primary={Object.keys(props.filterInstallationStatusObj)}
                />
              </MenuItem>
            ))}
          </Select>
          */}

          <Select
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
