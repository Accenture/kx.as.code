import * as React from 'react';
import Typography from '@material-ui/core/Typography'
import Breadcrumbs from "@material-ui/core/Breadcrumbs"
import Link from "@material-ui/core/Link"

function handleClick(event) {
  event.preventDefault();
  console.info('You clicked a breadcrumb.');
}

export default function BasicBreadcrumbs() {
  return (
    <div className="p-4 bg-gray-800 text-white" role="presentation" onClick={handleClick}>
      <Breadcrumbs color="inherit" aria-label="breadcrumb">
        <Link color="inherit" className="text-white" underline="hover" href="/">
          Home
        </Link>
        <Link
          underline="hover"
          color="white"
          href="/getting-started/installation/"
        >
          Applications
        </Link>
        <Typography color="inherit">App-1</Typography>
      </Breadcrumbs>
    </div>
  );
}