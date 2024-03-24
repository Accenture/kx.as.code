import { ChevronLeft, ChevronRight } from '@mui/icons-material';
import React, { useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { useNavigate } from 'react-router-dom';

export function Breadcrumbs() {
    const location = useLocation();
    const pathnames = location.pathname.split('/').filter((x) => x);

    const navigate = useNavigate();

    const handleGoBack = () => {
        navigate(-1)
    };

    const handleGoForward = () => {
        navigate(+1)
    };

    useEffect(() => {
        console.log("location: ", location)

    }, []);

    return (
        <nav aria-label="breadcrumb" className="flex items-center dark:bg-ghBlack2 capitalize text-sm text-gray-400">
            <div className="flex items-center">
                <button onClick={handleGoBack} className="p-1 hover:bg-ghBlack3 text-gray-400 hover:text-white flex items-center justify-center">
                    <ChevronLeft fontSize="small" />
                </button>
                <button onClick={handleGoForward} className="p-1 hover:bg-ghBlack3 text-gray-400 hover:text-white flex items-center justify-center">
                    <ChevronRight fontSize="small" />
                </button>
            </div>
            <ul className="flex items-center ml-2">
                <li className="breadcrumb-item">
                    <Link to="/" className="hover:underline hover:cursor-pointer">Home</Link>
                    <span className="text-gray-400 mx-2">/</span>
                </li>
                {pathnames.map((name, index) => {
                    const routeTo = `/${pathnames.slice(0, index + 1).filter(Boolean).join('/')}`; // Filter out empty strings
                    const isLast = index === pathnames.length - 1;
                    const isHome = index === 0;

                    return (
                        <li key={name} className="breadcrumb-item flex items-center">
                            {!isHome && !isLast && <span className="text-gray-400 mx-2">/</span>}
                            {!isLast ? (
                                <React.Fragment>
                                    <Link to={routeTo} className="hover:underline hover:cursor-pointer">{name}</Link>
                                    <span className="mx-2">/</span>
                                </React.Fragment>
                            ) : (
                                <span className="text-white">{name}</span>
                            )}
                        </li>
                    );
                })}
            </ul>
        </nav>
    );
};