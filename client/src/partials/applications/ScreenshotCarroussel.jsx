import React from "react";
import { useState, useEffect } from "react";
import { RiWindowLine } from "react-icons/ri";
import SCarousel from "./SCarousel";
import "react-responsive-carousel/lib/styles/carousel.min.css";

// import img from "../../media/png/appImgs/jenkins.png";

export default function ScreenshotCarroussel(props) {
  const [image, setImage] = useState();
  const [screenshots, setScreenshots] = useState([]);
  const imageName = props.appName;
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [height, setHeight] = useState("10px");
  const [width, setWidth] = useState("10px");

  //   const loadImage = (imageName) => {
  //     import(`../../media/png/appImgs/${imageName}.png`)
  //       .then((image) => {
  //         setImage(image);
  //       })
  //       .catch(() => ({ default: () => <div>Not found</div> }));
  //   };

  const setImageSize = () => {
    setHeight("500px");
    setWidth("500px");
  };

  useEffect(() => {
    // setImageSize();
    const fetchImage = async () => {
      let screenshotsListTmp = [];

      try {
        for (let i = 1; i < 10; i++) {
          const response = await import(
            `../../media/png/screenshots/${imageName}_screenshot${i}.png`
          );
          screenshotsListTmp.push(response.default);
        }
      } catch (err) {
        console.log("Error: ", err);
      } finally {
        setLoading(false);
        setScreenshots(screenshotsListTmp);
      }
    };

    fetchImage();
  }, [imageName]);

  return (
    <>
      <div className="grid grid-cols-12">
        <div className="flex col-span-12 md:col-span-8">
          <SCarousel screenshots={screenshots} imageName={imageName} />
        </div>
        <div className="flex md:col-span-6"></div>
      </div>

      {/* {screenshots.map((sc) => {
        return (
          <div>
            <img src={sc} alt={imageName} height={height} width={width} />
          </div>
        );
      })} */}
    </>
  );
}
