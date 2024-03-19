import React, { useState, useEffect, useRef } from 'react';



export function ApplicationDetails({ }) {

    const { id } = useParams();

    return (
     <div>Applications details: {id}</div>
    )
}