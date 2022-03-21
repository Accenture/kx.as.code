import React from "react";
import "./NewProfileGeneral.scss";
import { NewProfileGeneralForm, NewProfileTemplate } from "../../index";

const NewProfileGeneral = () => {

  return (
    <NewProfileTemplate>
      <NewProfileGeneralForm />
    </NewProfileTemplate>
  );
};

export default NewProfileGeneral;
