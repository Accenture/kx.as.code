import React from "react";
import MuiAppBar from "@mui/material/AppBar";
import Toolbar from "@mui/material/Toolbar";
import IconButton from "@mui/material/IconButton";
import MenuIcon from "@mui/icons-material/Menu";


const Header2 = (props) => {
  const [open, setOpen] = useState(false);

  const handleDrawerOpen = () => {
    setOpen(true);
  };

  const handleDrawerClose = () => {
    setOpen(false);
  };

  return (
    <MuiAppBar position="fixed" open={props.open} className="" elevation={0}>
      <Toolbar className="bg-ghBlack4 border border-b-4 border-ghBlack2">
        <IconButton
          color="inherit"
          aria-label="open drawer"
          onClick={props.handleDrawerOpen}
          edge="start"
          sx={{
            borderRadius: 0,
            marginRight: 5,
            ...(props.open && { display: "none" }),
          }}
        >
          <MenuIcon className="" />
        </IconButton>
        {/* <Link href="/">
          <Image
            src="/media/svg/ks-logo-w.svg"
            width={50}
            height={50}
            alt="Picture of the author"
          />
        </Link> */}
        <div className="text-sm font-extrabold uppercase">
          KX.AS.Code
          <span className="font-medium ml-1 lowercase">
            {/* v.{versions.kxascode} */}
          </span>
        </div>
      </Toolbar>
    </MuiAppBar>
  );
};

export default Header2;