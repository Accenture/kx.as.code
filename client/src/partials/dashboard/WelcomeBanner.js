import React from 'react';

function WelcomeBanner() {
  return (
    <div className="relative bg-gradient-to-r from-vier via-statusGreen to-fuenf p-4 sm:p-6 rounded-lg overflow-hidden mb-8">

      {/* Background illustration */}
      
      {/* Content */}
      <div className="relative">
        <h1 className="text-2xl md:text-3xl text-gray-800 font-bold mb-1">Good afternoon, John. 👋</h1>
        <p>Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt:</p>
      </div>

    </div>
  );
}

export default WelcomeBanner;
