import { Clear, FilterList } from '@mui/icons-material';
import { IconButton } from '@mui/material';
import React, { useState, useEffect, useRef } from 'react';

export function SearchInput({ setSearchTerm, searchTerm }) {

    const handleClearSearch = () => {
        setSearchTerm('');
    };

    return (
        <div className='flex justify-center'>
            <div className="group relative w-full">
                <svg
                    width="20"
                    height="20"
                    fill="currentColor"
                    className="absolute left-3 top-1/2 -mt-2.5 text-gray-500 pointer-events-none group-focus-within:text-kxBlue"
                    aria-hidden="true"
                >
                    <path
                        fillRule="evenodd"
                        clipRule="evenodd"
                        d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z"
                    />
                </svg>
                <input
                    value={searchTerm}
                    type="text"
                    placeholder="Search..."
                    className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack4 py-1 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none pl-10 pr-8 rounded w-full"
                    onChange={(e) => {
                        setSearchTerm((e.target.value))
                    }}
                />
                {searchTerm !== "" && (
                    <IconButton
                        size="small"
                        onClick={handleClearSearch}
                        style={{ position: 'absolute', right: '0', top: '50%', transform: 'translateY(-50%)' }}
                    >
                        <Clear fontSize='small' />
                    </IconButton>
                )}
            </div>
            <button className='text-gray-400 p-1 hover:text-white hover:bg-ghBlack3 rounded ml-1'>
                <FilterList />
            </button>
        </div>
    )
}