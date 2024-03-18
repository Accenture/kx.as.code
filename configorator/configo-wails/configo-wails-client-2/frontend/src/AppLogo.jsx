import React, { useState, useEffect } from 'react';

export default function AppLogo({ appName, size }) {
    const [image, setImage] = useState(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        let isMounted = true;

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

        return () => {
            isMounted = false;
        };
    }, [appName, setIsLoading, setImage]);

    return (
        !isLoading ? (
            image ? (
                <img
                    className={`p-1`}
                    height={size}
                    width={size}
                    src={image}
                    alt={appName}
                    style={{display: 'block' }}
                />
            ) : null
        ) : (
            <div className={`rounded-full animate-pulse bg-ghBlack4`}></div>
        )
    );
}
