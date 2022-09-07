import React from "react";
import { Carousel } from "react-responsive-carousel";
import { useState, useEffect } from "react";

export default function SCarousel(props) {
  useEffect(() => {}, [props.screenshots]);

  return (
    <Carousel swipeable>
      {props.screenshots.map((sc, i) => {
        return (
          <div key={i} className="rounded">
            <img alt="" src={sc} className="rounded-xl" />
            {/* <p className="legend">{props.imageName}</p> */}
          </div>
        );
      })}
    </Carousel>
  );
}
