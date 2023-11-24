'use client'
import Image from 'next/image'
import React from 'react';
import homeImg from '../media/svg/home-image-animate.svg';
import kxIconW from "../media/svg/ks-logo-w.svg"
import { useRouter } from 'next/navigation'

const Home: React.FC = () => {
  const router = useRouter()
  return (
    <div className="px-4 sm:px-6 lg:px-40 py-20 w-full max-w-9xl mx-auto bg-ghBlack">

      {/* Intro Header Section */}
      <div className="grid grid-cols-12 gap-14">
        {/* left */}
        <div className="col-span-6" id="">
          {/* left header with logo */}
          <div className="flex items-center">
            <Image
              src={kxIconW}
              height={70}
              width={70}
              alt="KX AS Code Logo"
            />
            <span className="text-[24px] font-extralight">KX.AS.CODE</span>
          </div>

          {/* Intro Title */}
          <div className="text-[42px] font-extralight leading-tight my-7">
            <span className="text-kxBlue font-extrabold">Transfer Knowledge as Code</span> - All in One VM.
          </div>

          {/* Intro Text */}
          <div className="text-base tracking-wide text-justify">
            Learn and share knowledge. Use it for demoing new technologies,
            tools and processes. Keep your physical workstation clean whilst
            experimenting. Have fun playing around with new technologies and use
            it as an accompaniment to trainings and certifications. Experiment
            and innovate.
          </div>

          {/* Getting Started Button */}
          <div className="mt-10">
            <button
              type="button"
              className="bg-kxBlue px-5 py-3 text-base w-[10rem] transition-all"
              onClick={() => router.push('/applications')}
            >
              Get Started
            </button>
          </div>
        </div>
        {/* right */}
        <div className="col-span-6 mt-10">
          <Image
            className="bg-kxBlue3 p-8 bg-gradient-to-r from-ghBlack3"
            src={homeImg}
            height={900}
            width={900}
            alt="Home Image"
          />
        </div>
      </div>
    </div>
  );
};

export default Home;