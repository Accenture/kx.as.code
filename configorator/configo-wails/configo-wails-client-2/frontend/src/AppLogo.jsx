import React, { useState, useEffect } from 'react';

export default function AppLogo({ appName }) {
    const [image, setImage] = useState(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        let isMounted = true; // Flag to track if the component is still mounted

        const fetchImage = async () => {
            try {
                const { default: imageModule } = await import(`./assets/media/png/appImgs/${appName}.png`);
                if (isMounted) {
                    setImage(imageModule);
                    setIsLoading(false);
                }
            } catch (error) {
                console.error('Error loading image:', error);
                const noImagePath = './assets/media/svg/no_image_app.svg';

                try {
                    const { default: imageModule } = await import(noImagePath);
                    if (isMounted) {
                        setImage(imageModule);
                    }
                } catch (fallbackError) {
                    console.error('Error fetching or processing fallback image:', fallbackError);
                    if (isMounted) {
                        setImage(null);
                    }
                }
            }
        };

        fetchImage();

        // Cleanup function to set isMounted to false when the component unmounts
        return () => {
            isMounted = false;
        };
    }, [appName, setIsLoading, setImage]);

    return (
        !isLoading ? (
            image ? (
                <img
                    className='p-1'
                    src={image}
                    alt={appName}
                    style={{ maxHeight: '40px', width: '40px', display: 'block' }}
                />
            ) : null
        ) : (
            <div className='h-[36px] w-[36px] rounded-full animate-pulse bg-ghBlack4'></div>
        )
    );
}
