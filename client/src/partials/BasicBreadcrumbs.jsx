import * as React from 'react';
import Typography from '@material-ui/core/Typography'
import Breadcrumbs from "@material-ui/core/Breadcrumbs"
import Link from "@material-ui/core/Link"

export default function BasicBreadcrumbs() {
  return (
    <div className="p-4 bg-ghBlack text-white border-b border-gray-700" role="presentation">
      <Breadcrumbs color="inherit" aria-label="breadcrumb">
        <Link color="inherit" className="text-white" underline="hover" href="/">
          Home
        </Link>
        <Link 
        color="inherit"
          underline="hover"
          href="/apps"
        >
          Applications
        </Link>
        <Typography color="inherit">{window.location.pathname.split('/')}</Typography>
      </Breadcrumbs>
    </div>
  );
}