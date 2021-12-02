import React, { useState } from "react";
import Button from "../Button/button"
import "./counter.scss";

const CustomCounter = ({ min, max,label }) => {
  const [count, setCount] = useState(min);

  const decrementCount = () => {
    if (count > min) {
      setCount(count - 1);
    }
    else if (count === min) {
      setCount(min)
    }
  }
  const incrementCount = () => {
    if (count === max) {
      setCount(max)
    }
    else {
      setCount(count + 1);
    }

  }

  return (

      <div className="counter">
        {label?<label id='labeltext'>{label}</label>:''}
        <Button className="prof-counter-btn-duplicate" onClick={decrementCount}>-</Button>
        <div className="counter-center">{count}</div>
        <Button className="prof-counter-btn-duplicate" onClick={incrementCount}>+</Button>
      </div>
  );
}

export default CustomCounter;
