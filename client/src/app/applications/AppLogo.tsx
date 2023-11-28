import React, { useState, useEffect } from "react";

interface AppLogoProps {
  appName: string;
  height?: string;
  width?: string;
}

const AppLogo: React.FC<AppLogoProps> = (props) => {
  const [image, setImage] = useState<string | undefined>();
  const { appName, height, width } = props;

  const setImageSize = () => {

  };

  useEffect(() => {
    setImageSize();
    const fetchImage = async () => {
      try {
        const imagePath = `/media/png/appImgs/${appName}.png`;
        const imageResponse = await fetch(imagePath);
        const blob = await imageResponse.blob();
        const dataUrl = URL.createObjectURL(blob);
        setImage(dataUrl);
      } catch (err) {
        // Fallback image
        console.error("Error loading image:", err);
        const noImagePath = "/media/svg/no_image_app.svg";
        const noImageResponse = await fetch(noImagePath);
        const noImageBlob = await noImageResponse.blob();
        const noImageDataUrl = URL.createObjectURL(noImageBlob);
        setImage(noImageDataUrl);
      }
    };

    fetchImage();
  }, [appName]);

  return <img src={image} alt={appName} height={height} width={width} />;
};

export default AppLogo;
