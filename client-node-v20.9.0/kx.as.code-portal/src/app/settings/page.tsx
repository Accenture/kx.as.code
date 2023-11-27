'use client';
import { useEffect, useState } from "react";
import AddIcon from "@mui/icons-material/Add";
import axios from "axios";
import { DndProvider, useDrag, useDrop } from "react-dnd";
import { HTML5Backend } from "react-dnd-html5-backend";
import Button from "@mui/material/Button";
import RemoveIcon from "@mui/icons-material/Remove";
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import Tooltip from "@mui/material/Tooltip";



const Settings: React.FC = () => {
 

  return (
    <div className="px-4 sm:px-6 lg:px-24 py-8 w-full max-w-9xl mx-auto bg-ghBlack">
      <div className="text-white text-xl font-bold py-5 italic">SETTINGS</div>

    </div>
  );
};

export default Settings;
