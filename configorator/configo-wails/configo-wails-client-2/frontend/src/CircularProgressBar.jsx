import React, { useState, useEffect } from 'react';

export function CircularProgressbar({ percentage }) {
  const [animatedPercentage, setAnimatedPercentage] = useState(0);
  const viewBoxSize = 100;
  const radius = (viewBoxSize - 2 * 10) / 2;
  const circumference = 2 * Math.PI * radius;
  const strokeWidth = 10;

  useEffect(() => {
    let animationInterval;
    if (animatedPercentage < percentage) {
      animationInterval = setInterval(() => {
        setAnimatedPercentage((prevPercentage) => {
          const nextPercentage = prevPercentage + 2 <= percentage ? prevPercentage + 2 : percentage;
          return nextPercentage <= 100 ? nextPercentage : 100;
        });
      }, 10);
    }
    return () => clearInterval(animationInterval);
  }, [animatedPercentage, percentage]);

  const progress = (animatedPercentage / 100) * circumference;

  return (
    <div className="relative w-24 h-24">
      <svg className="absolute top-0 left-0 w-full h-full" viewBox={`0 0 ${viewBoxSize} ${viewBoxSize}`} xmlns="http://www.w3.org/2000/svg">
        <circle className="stroke-kxBlue" cx={viewBoxSize / 2} cy={viewBoxSize / 2} r={radius} strokeWidth={strokeWidth} fill="transparent" />
        {percentage > 0 && (
          <circle
            className="stroke-ghBlack4"
            cx={viewBoxSize / 2}
            cy={viewBoxSize / 2}
            r={radius}
            strokeWidth={strokeWidth}
            fill="transparent"
            strokeDasharray={circumference}
            strokeDashoffset={progress}
            transform={`rotate(-90 ${viewBoxSize / 2} ${viewBoxSize / 2})`}
          />
        )}
      </svg>
      <div className="absolute inset-0 flex items-center justify-center text-gray-400 font-semibold">
        {animatedPercentage == 100 && percentage > 100 ? percentage : animatedPercentage}%
      </div>
    </div>
  );
}