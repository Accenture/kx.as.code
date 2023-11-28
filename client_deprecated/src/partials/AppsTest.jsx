import React from "react";
import { Button } from "@material-ui/core";

const AppsTest = props => {
  const { history } = props;
  return (
    <>
      <Button onClick={() => history.push("/application/app-1")}>App-1</Button>
      <Button onClick={() => history.push("/jobs/app-2")}>App-2</Button>
      <Button onClick={() => history.push("/jobs/app-3")}>App-3</Button>
    </>
  );
};

export default AppsTest;