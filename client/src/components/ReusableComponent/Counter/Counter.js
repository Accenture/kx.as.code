import React, { useState } from "react";
import Button from "../Button/button"
import "./counter.scss";

const CustomCounter = ({defaultValue}) => {
  const [count, setCount] = useState(defaultValue);

  const decrementCount = () => {
    if (count < 0) {
      setCount(count - 1);
    }
    else {
      setCount(0)
    }

  }
  const incrementCount = () => {
    setCount(count + 1);
  }

  return (
    <div>

      <div className="counter">
        <Button className="prof-counter-btn-duplicate" onClick={decrementCount}>-</Button>
        <div className="counter-center">{count}</div>
        <Button className="prof-counter-btn-duplicate" onClick={incrementCount}>+</Button>
      </div>
    </div>
  );
}

export default CustomCounter;