import React, { useState, useEffect, useRef } from 'react';
import { useParams } from 'react-router-dom';


export function ApplicationDetails({ }) {

    const { id } = useParams();

    return (
     <div>Applications details: {id}</div>
    )
}