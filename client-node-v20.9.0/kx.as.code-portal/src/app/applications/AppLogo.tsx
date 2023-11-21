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
        const response = await import(
          `../../media/png/appImgs/${appName}.png`
        );
        setImage(response.default);
      } catch (err) {
        const response = await import(`../../media/svg/no_image_app.svg`);
        setImage(response.default);
      }
    };

    fetchImage();
  }, [appName]);

  return <img src={image} alt={appName} height={height} width={width} />;
};

export default AppLogo;
