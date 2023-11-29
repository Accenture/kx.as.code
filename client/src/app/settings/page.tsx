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
    <div className="py-10 w-full bg-ghBlack text-white">
      <div className="text-white pb-10 px-3">
        <div className="text-xl font-bold italic text-white">SETTINGS</div>
      </div>
    </div>
  );
};

export default Settings;
