import React, { FC } from "react";

interface HeaderProps {

}

const Header: FC<HeaderProps> = () => {
  return (
    <div className="top-0 bg-inv3 z-30 text-red-500">
      
      <div className="px-4 sm:px-6 lg:px-8">
      
        <div className="flex items-center justify-between h-16 -mb-px">

        </div>
      </div>
    </div>
  );
};

export default Header;
