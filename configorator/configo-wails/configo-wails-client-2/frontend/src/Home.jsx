import React, { useState, useEffect } from 'react';
import homeImg from "./assets/media/svg/home-image-animate.svg"

export default function Home() {
   
    useEffect(() => {
       
    }, []);

    return (
        <div className='bg-ghBlack4 flex justify-center p-10'>
            <img src={homeImg} height={500} width={500}/>
        </div>
    );

};