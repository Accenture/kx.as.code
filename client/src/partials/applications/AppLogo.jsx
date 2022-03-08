import React from "react";
import { useState, useEffect } from "react";
import { RiWindowLine } from "react-icons/ri";

// import img from "../../media/png/appImgs/jenkins.png";

export default function AppLogo(props) {
  const [image, setImage] = useState();
  const imageName = props.appName;
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  //   const loadImage = (imageName) => {
  //     import(`../../media/png/appImgs/${imageName}.png`)
  //       .then((image) => {
  //         setImage(image);
  //       })
  //       .catch(() => ({ default: () => <div>Not found</div> }));
  //   };

  useEffect(() => {
    const fetchImage = async () => {
      try {
        const response = await import(
          `../../media/png/appImgs/${imageName}.png`
        );
        setImage(response.default);
      } catch (err) {
        setError(err);
      } finally {
        setLoading(false);
      }
    };

    fetchImage();
  }, [imageName]);

  return (
    <>
      {image ? (
        <img src={image} alt="" height="50px" width="50px" />
      ) : (
        <RiWindowLine className="text-5xl opacity-40" />
      )}
    </>
  );
}
