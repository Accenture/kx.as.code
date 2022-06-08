import React from "react";
import AddIcon from "@mui/icons-material/Add";

export default function Dashboard() {
  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto">
      {/* Applications Header */}
      <div className="text-white text-xl font-bold py-5 italic">
        MY DASHBOARD
      </div>

      {/* Dashboard Components */}
      <div className="grid grid-cols-12 gap-2">
        <div className="col-span-3 bg-ghBlack rounded h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
          <div className="text-[16px] uppercase font-bold text-gray-600">
            Installed Applications
          </div>
          <div className="flex justify-center mt-8 text-[50px]">8</div>
          <div className="flex justify-center text-[14px]">
            Application count
          </div>
        </div>

        <div className="col-span-3 bg-ghBlack rounded h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
          <div className="text-[16px]  uppercase font-bold text-gray-600">
            Failed Applications
          </div>
          <div className="flex justify-center mt-8 text-[50px]">3</div>
          <div className="flex justify-center text-[14px]">
            Application count
          </div>
        </div>

        <div className="col-span-3 bg-ghBlack rounded h-60 p-6  border-2 border-ghBlack hover:border-gray-700">
          <div className="text-[16px] uppercase font-bold text-gray-600">
            Pending Applications
          </div>
          <div className="flex justify-center mt-8 text-[50px]">10</div>
          <div className="flex justify-center text-[14px]">
            Application count
          </div>
        </div>

        <div className="col-span-3 text-gray-700 bg-inv1 rounded h-60 p-6  border-2 border-dashed border-gray-700 hover:border-gray-600">
          <div className="flex justify-center mt-16 text-[50px]">
            <AddIcon
              fontSize="inherit"
              color="inherit"
              className="hover:text-600"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
