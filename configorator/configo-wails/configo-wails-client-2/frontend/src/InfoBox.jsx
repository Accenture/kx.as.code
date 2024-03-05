import React, { useState, useEffect, useRef } from 'react';
import { Info } from '@mui/icons-material';


export function InfoBox({ children }) {

    return (
        <div className='p-2 border rounded border-ghBlack4 text-gray-400 text-sm flex items-center w-auto' style={{ overflow: 'hidden', whiteSpace: 'nowrap'}}>
            <Info fontSize='small' />
            {children}
        </div>
    )
}