import React from "react";
import { Carousel } from "react-responsive-carousel";
import { useState, useEffect } from "react";
import Image from 'next/image'

export default function SCarousel(props) {
  useEffect(() => {
    console.log("screenshots-caoursell: ", props.screenshots);
  }, [props.screenshots]);

  return (
    <Carousel swipeable>
      {props.screenshots.map((sc, i) => {
        return (
          <div key={i} className="rounded">
            <Image className=""
              src={sc}
              alt="Screenshoot"
            />
            {/* <img alt="" src={sc} className="rounded-xl" /> */}
            {/* <p className="legend">{props.imageName}</p> */}
          </div>
        );
      })}
    </Carousel>
  );
}
