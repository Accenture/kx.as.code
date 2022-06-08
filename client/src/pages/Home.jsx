import React from "react";
import WelcomeBanner from "../partials/WelcomeBanner";
import kxIcon from "../media/svg/icon-blau-2.svg";
import homeImg from "../media/svg/home-image.svg";
import cubesImg from "../media/svg/cubes.svg";
import { useHistory } from "react-router-dom";

export default function Home2() {
  const history = useHistory();

  const applicationPage = () => {
    history.push("/apps");
  };

  return (
    <div className="px-4 sm:px-6 lg:px-40 py-20 w-full max-w-9xl mx-auto">
      {/* Welcome banner */}
      {/* <WelcomeBanner /> */}

      {/* Intro Header Section */}
      <div className="grid grid-cols-12 gap-14">
        <div id="home-left"></div>
        {/* left */}
        <div className="col-span-5" id="">
          {/* left header with logo */}
          <div className="flex items-center">
            <img
              src={kxIcon}
              height="50px"
              width="50px"
              alt="KX AS Code Logo"
            ></img>
            <span className="text-[24px] font-semibold ml-3">KX.AS CODE</span>
          </div>

          {/* Intro Title */}
          <div className="text-[38px] font-extrabold leading-tight my-7">
            Transfer Knowledge as a Code - All in One VM.
          </div>

          {/* Intro Text */}
          <div className="text-[18px]  tracking-wide text-justify">
            Learn and share knowledge. Use it for demoing new technologies,
            tools and processes. Keep your physical workstation clean whilst
            experimenting. Have fun playing around with new technologies and use
            it as an accompaniment to trainings and certifications. Experiment
            and innovate.
          </div>

          {/* Getting Started Button */}
          <div className="mt-10">
            <button
              className="bg-kxBlue hover:bg-kxBlueH px-5 py-3 text-[18px] rounded"
              onClick={applicationPage}
            >
              Get Started
            </button>
          </div>
        </div>
        {/* right */}
        <div className="col-span-7 mt-10">
          <img
            className="bg-gray-400 p-8 rounded-xl"
            src={homeImg}
            height="900px"
            width="900px"
            alt="Home Image"
          ></img>
        </div>
      </div>
    </div>
  );
}
