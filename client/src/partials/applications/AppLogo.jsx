import React from "react";
import { useState, useEffect } from "react";

export default function AppLogo(props) {
  const [image, setImage] = useState();
  const imageName = props.appName;

  const [height, setHeight] = useState("10px");
  const [width, setWidth] = useState("10px");

  const setImageSize = () => {
    setHeight(props.height);
    setWidth(props.width);
  };

  useEffect(() => {
    setImageSize();
    const fetchImage = async () => {
      try {
        const response = await import(
          `../../media/png/appImgs/${imageName}.png`
        );
        console.log("response img: ", response.default);
        setImage(response.default);
      } catch (err) {
        console.log(err);
        const response = await import(`../../media/svg/no_image_app.svg`);
        setImage(response.default);
      } finally {
      }
    };

    fetchImage();
  }, [imageName, image]);

  return (
    <>
      <img src={image} alt={props.appName} height={height} width={width} />
    </>
  );
}
