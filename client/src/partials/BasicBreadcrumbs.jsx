import * as React from "react";
import Typography from "@material-ui/core/Typography";
import Breadcrumbs from "@material-ui/core/Breadcrumbs";
import Link from "@material-ui/core/Link";

import { withRouter } from "react-router-dom";

const BasicBreadcrumbs = (props) => {
  const {
    history,
    location: { pathname },
  } = props;
  const pathnames = pathname.split("/").filter((x) => x);

  return (
    <div
      className="z-20 sticky top-0 p-4 bg-inv3 text-white shadow-md"
      role="presentation"
    >
      <Breadcrumbs color="inherit" aria-label="breadcrumb">
        {pathnames.length > 0 ? (
          <Link
            className="hover:text-underline hover:cursor-pointer"
            color="inherit"
            onClick={() => history.push("/")}
          >
            Home
          </Link>
        ) : (
          <Typography> </Typography> //Empty Breadcrumb when on Home Component
        )}
        {pathnames.map((name, index) => {
          const routeTo = `/${pathnames.slice(0, index + 1).join("/")}`;
          const isLast = index === pathnames.length - 1;
          var name = name.replace(/\b\w/g, (l) => l.toUpperCase());
          return isLast ? (
            <Typography className="font-semibold" key={name}>
              {name.replace(/\b\w/g, (l) => l.toUpperCase())}
            </Typography>
          ) : (
            <Link
              color="inherit"
              className="hover:cursor-pointer text-white"
              key={name}
              onClick={() => history.push(routeTo)}
            >
              {name}
            </Link>
          );
        })}
      </Breadcrumbs>
    </div>
  );
};
export default withRouter(BasicBreadcrumbs);
