import React, { useState, useEffect } from 'react';

const AppLogo = ({ appName }) => {
    const [image, setImage] = useState(null);

    useEffect(() => {
        const fetchImage = async () => {
            try {
                const { default: imageModule } = await import(`./assets/media/png/appImgs/${appName}.png`);
                setImage(imageModule);
            } catch (error) {
                console.error('Error loading image:', error);
                const noImagePath = './assets/media/svg/no_image_app.svg';

                try {
                    const { default: imageModule } = await import(noImagePath);
                    setImage(imageModule);
                } catch (fallbackError) {
                    console.error('Error fetching or processing fallback image:', fallbackError);
                    setImage(null); 
                }
            }
        };

        fetchImage();
    }, [appName]);

    return image ? (
        <img
            className='p-1'
            src={image}
            alt={appName}
            style={{ maxHeight: '40px', width: '40px', display: 'block' }}
        />
    ) : null;
};

export default AppLogo;
