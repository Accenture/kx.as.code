import React from "react";
import { useState, useEffect } from "react";

export default function DashboardCard(props) {
  useEffect(() => {
    return () => {};
  }, []);

  return (
    <div>
      <div>{props.title}</div>
    </div>
  );
}
