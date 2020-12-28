import React from "react";
import { withRouter } from "react-router";
import "./NewProfileGeneralForm.scss";
import { Box, Grid, Input } from "@material-ui/core";
import { TextBox, DropDown, CustomizedCheckbox } from "../../../ReusableComponent/index";

const NewProfileGeneralForm = () => (
  <Box
    id="new-prof-gen-form"
    display="flex"
    flexDirection="row"
    justifyContent="center"
    alignItems="flex-start"
  >
    <Grid container direction="column" justify="flex-start" alignItems="center">
      <Grid item>
        <label htmlFor="new-prof-gen-form-profile-name">Profile Name*</label>
      </Grid>
      <Grid item>
        {/* <Input id="new-prof-gen-form-profile-name" type="text" /> */}
        <TextBox htmlFor="new-prof-gen-form-profile-name" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-team-name">Team Name</label>
      </Grid>
      <Grid item>
        {/* <Input id="new-prof-gen-form-team-name" type="text" /> */}
        <TextBox htmlFor="new-prof-gen-form-team-name" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-ssl-provider">Profile Type*</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-ssl-provider" type="text" />
        {/* <DropDown data={["OPTIONS"]} id="new-prof-gen-form-ssl-provider"/> */}
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-platform-selection-type">
          Profile Sub Type
        </label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-platform-selection-type" type="text" />
        {/* <DropDown data={[" OPTIONS"]} id="new-prof-gen-form-ssl-provider"/> */}
      </Grid>
      <Grid item>
        <CustomizedCheckbox />
        <label >Disable Kubernetes Session Timeout</label>
      </Grid>
    </Grid>

    <Grid container direction="column" justify="flex-start" alignItems="center">
      <Grid item>
        <label htmlFor="new-prof-gen-form-base-domain">Base Domain</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-base-domain" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-base-user">Default User</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-base-user" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-base-password">Default Password</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-base-password" type="text" />
      </Grid>
      <Grid item>
        <ul>
          <li>At least 8 characters—the more characters, the better.</li>
          <li>A mixture of both uppercase and lowercase letters.</li>
          <li>A mixture of letters and numbers.</li>
          <li>
            Inclusion of at least one special character, e.g., ! @ # ? ] Note:
            do not use &lt; or &gt; in your password, as both can cause problems
            in Web browsers.
          </li>
        </ul>
      </Grid>
      <Grid item >
        <CustomizedCheckbox />
          <label >Certification Mode</label>
      </Grid>
    </Grid>
  </Box>
);

export default withRouter(NewProfileGeneralForm);
