import React, { useState, useEffect } from 'react';
import { HiMiniCube } from "react-icons/hi2";

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
                setImage(null)
                console.error('Error loading image:', error);
                if (isMounted) {
                    setIsLoading(false);
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
                    style={{ display: 'block' }}
                />
            ) : (
                <HiMiniCube size={size} className={`text-white p-1.5`} />
            )
        ) : (
            <div className={`rounded-full animate-pulse bg-ghBlack4`} style={{ width: size, height: size }}></div>
        )
    );
}
