import * as React from "react";
import Chip from "@mui/material/Chip";
import Autocomplete from "@mui/material/Autocomplete";
import TextField from "@mui/material/TextField";
import Stack from "@mui/material/Stack";
import { useState, useEffect } from "react";

export default function Tags(props) {
  const [options, setOptions] = useState([]);
  const [value, setValue] = useState(props.categoriesFilterTags || []);

  const getObjList = (list) => {
    // console.log("debug-list: ", list);
    let categoriesObjList = [];
    try {
      list.map((tag) => {
        let obj = {};
        categoriesObjList.push((obj["name"] = tag));
      });
      // console.log("categoriesObjList: ", categoriesObjList);
    } catch (error) {
      console.log(error);
    } finally {
      return categoriesObjList;
    }
  };

  const handleChange = (event, newValue) => {
    setValue(newValue);
    props.setCategoriesFilterTags(newValue);
  };

  const getAllCategoriesObj = () => {
    let categoriesList = [];

    try {
      // console.log("app data: ", props.applicationData);
      props.applicationData.map((app) => {
        // console.log("app: ", app.categories);

        if (app.categories) {
          app.categories.map((tag) => {
            if (!categoriesList.includes(tag)) {
              categoriesList.push(tag);
            }
          });
        }
      });
    } catch (error) {
      console.log("error: ", error);
    } finally {
      let categoriesObjList = [];
      categoriesList.map((tag) => {
        let obj = {};
        obj["name"] = tag;
        categoriesObjList.push(obj);
      });
      // console.log("categoriesObjList: ", categoriesObjList);
      return categoriesObjList;
    }
  };

  useEffect(() => {
    return () => {};
  }, []);

  return (
    <Stack spacing={3} sx={{ width: 500 }}>
      <Autocomplete
      multiple
      id="tags-outlined"
      options={getAllCategoriesObj()}
      getOptionLabel={(option) => option.name}
      value={value}
      onChange={handleChange}
      filterSelectedOptions
      renderInput={(params) => (
        <TextField
          {...params}
          label="Filter by Categories"
          placeholder="Add Category"
        />
      )}
    />
    </Stack>
  );
}
