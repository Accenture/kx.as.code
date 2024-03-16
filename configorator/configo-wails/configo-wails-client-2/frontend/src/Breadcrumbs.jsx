import React, { useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';

export function Breadcrumbs() {
    const location = useLocation();
    const pathnames = location.pathname.split('/').filter((x) => x);

    useEffect(() => {
        console.log("location: ", location)

    }, []);

    return (
        <nav aria-label="breadcrumb" className="h-[40px] flex items-center dark:bg-ghBlack4 px-5 pt-2 capitalize text-sm text-gray-400">
            <ul className="flex items-center">
                <li className="breadcrumb-item">
                    <Link to="/" className="hover:underline hover:cursor-pointer">Home</Link>
                    <span className="text-gray-400 mx-2">/</span>
                </li>
                {pathnames.map((name, index) => {
                    const routeTo = `/${pathnames.slice(0, index + 1).join('/')}`;
                    const isLast = index === pathnames.length - 1;
                    return (
                        <li key={name} className="breadcrumb-item flex items-center">
                            {!isLast && <span className="text-gray-400">/</span>}
                            {isLast ? (
                                <span className="text-white">{name}</span>
                            ) : (
                                <React.Fragment>
                                    <Link to={routeTo} className="hover:underline hover:cursor-pointer">{name}</Link>
                                    <span className="mx-2">/</span>
                                </React.Fragment>
                            )}
                        </li>
                    );
                })}
            </ul>
        </nav>
    );
};