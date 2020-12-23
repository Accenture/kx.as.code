import React from "react";
import { withRouter } from "react-router";
import "./NewProfileGeneralForm.scss";
import { Box, Grid, Input } from "@material-ui/core";

const NewProfileGeneralForm = () => (
  <Box id="new-prof-gen-form">
    <Grid container direction="column" justify="flex-start" alignItems="center">
      <Grid item>
        <label htmlFor="new-prof-gen-form-profile-name">Profile Name</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-profile-name" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-team-name">Team Name</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-team-name" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-ssl-provider">SSL Provider</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-ssl-provider" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-platform-selection-type">
          Platform Selection Type
        </label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-platform-selection-type" type="text" />
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
        <label htmlFor="new-prof-gen-form-base-user">Base User</label>
      </Grid>
      <Grid item>
        <Input id="new-prof-gen-form-base-user" type="text" />
      </Grid>
      <Grid item>
        <label htmlFor="new-prof-gen-form-base-password">Base Password</label>
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
    </Grid>
  </Box>
);

export default withRouter(NewProfileGeneralForm);
