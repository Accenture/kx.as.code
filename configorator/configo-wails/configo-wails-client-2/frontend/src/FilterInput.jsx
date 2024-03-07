import { Add, Clear, FilterList } from '@mui/icons-material';
import { IconButton } from '@mui/material';
import React, { useState, useEffect, useRef } from 'react';
import Autocomplete from '@mui/material/Autocomplete';
import TextField from '@mui/material/TextField';
import Checkbox from '@mui/material/Checkbox';
import CheckBoxOutlineBlankIcon from '@mui/icons-material/CheckBoxOutlineBlank';
import CheckBoxIcon from '@mui/icons-material/CheckBox';

const icon = <CheckBoxOutlineBlankIcon fontSize="small" />;
const checkedIcon = <CheckBoxIcon fontSize="small" />;

export function FilterInput({ setSearchTerm, searchTerm, itemName, itemsCount, hasActionButton, actionFunction }) {

    const options = [
        { title: 'Option 1' },
        { title: 'Option 2' },
        { title: 'Option 3' },
    ];

    const [isFilterSectionActive, setIsFilterSectionActive] = useState(false);

    const handleClearSearch = () => {
        setSearchTerm('');
    };

    const toggleFilterSectionActive = () => {
        setIsFilterSectionActive((prevState) => !prevState);
    };

    return (

        <div className='top-0 sticky bg-ghBlack2 p-2 shadow-lg'>
            <div className='flex'>

                <div className="items-center w-full pr-1">
                    {/* Search Input Field with filter button */}
                    <div className=''>

                        {/* Search Input Section */}
                        <div className='flex items-center'>
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
                                    placeholder="Filter..."
                                    className="focus:ring-1 focus:ring-kxBlue focus:outline-none bg-ghBlack3 focus:bg-ghBlack4 py-1 placeholder-blueGray-300 text-blueGray-600 text-md border-0 shadow outline-none pl-10 pr-8 rounded-sm w-full"
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
                            <button className={`text-gray-400 p-1 ${isFilterSectionActive ? "bg-white text-black " : "text-black hover:bg-ghBlack3"} rounded-sm ml-1 h-full`}
                                onClick={() => {
                                    toggleFilterSectionActive()
                                }}>
                                <FilterList fontSize='small' />
                            </button>

                            {hasActionButton && (
                                <button
                                    className='p-1.5 bg-kxBlue hover:text-white rounded-sm items-center font-semibold flex h-full ml-1'
                                    onClick={() => {
                                        actionFunction()
                                    }}
                                >
                                    <Add fontSize='small' />
                                </button>
                            )}
                        </div>

                        {/* Filter Section */}
                        {isFilterSectionActive && (
                            <div className='bg-ghBlack2 rounded-sm p-1 mt-1 text-xs h-20'>
                                {/* <Autocomplete
                        multiple
                        limitTags={1}
                        size="small"
                        id="size-small-standard-multi"
                        options={options}
                        disableCloseOnSelect
                        getOptionLabel={(option) => option.title}
                        renderOption={(props, option, { selected }) => (
                            <li {...props} style={{ padding: 0, margin: 0, fontSize: 14 }}>
                                <Checkbox
                                    icon={icon}
                                    checkedIcon={checkedIcon}
                                    style={{ marginRight: 8 }}
                                    checked={selected}
                                />
                                {option.title}
                            </li>
                        )}
                        renderInput={(params) => (
                            <TextField {...params} placeholder="Filter..." />
                        )}
                        /> */}
                            </div>
                        )}

                        <div className='text-gray-400 flex justify-between pt-1 items-center text-sm'>
                            <div>
                                <span className='mr-1'>{itemName}</span>
                                <span className='p-1.5 py-0 bg-ghBlack3 text-gray-400 rounded-sm text-center mr-1'>{itemsCount}</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </div>


    )
}