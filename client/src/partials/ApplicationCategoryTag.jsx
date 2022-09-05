import React from "react";
import { useState, useEffect } from "react";
import Tooltip from "@mui/material/Tooltip";
import Button from "@mui/material/Button";

export default function ApplicationCategoryTag(props) {
  const [appTagTransformed, setAppTagTransformed] = useState("");

  useEffect(() => {
    setAppTagTransformed(
      props.appTag
        .replaceAll("-", " ")
        .replaceAll("_", " ")
        .replace(/\b\w/g, (l) => l.toUpperCase())
    );
  }, []);

  return (
    <Tooltip
      title="Add to filters"
      placement="top"
      arrow
      key={props.keyId}
      disable
    >
      <button
        disable
        id={props.appTag}
        key={props.keyId}
        className="rounded bg-gray-500 hover:bg-kxBlue text-sm mr-1.5 mb-2 px-1.5 w-auto
      inline-block"
        onClick={(e) => {
          var tagObj = {};
          tagObj["name"] = props.appTag;
          props.addCategoryTofilterTags(tagObj);
        }}
      >
        {appTagTransformed}
      </button>
    </Tooltip>
  );
}
