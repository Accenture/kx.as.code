'use client';
import React from 'react';
import { useEffect, useState } from "react";

const Dashboard: React.FC = () => {

  const [name, setName] = useState<string>("John");

  return (
    <div> Hello  {name}
    </div>
  );
};

export default Dashboard;