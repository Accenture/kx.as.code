'use client'
import React, { ReactNode } from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import {transformName} from "../utils/application"


type TBreadCrumbProps = {
    homeElement?: ReactNode,
    separator?: ReactNode,
    containerClasses?: string,
    listClasses?: string,
    activeClasses?: string,
    capitalizeLinks?: boolean
}

const Breadcrumb = ({homeElement, separator, containerClasses, listClasses, activeClasses, capitalizeLinks}: TBreadCrumbProps) => {

    const paths = usePathname()
    const pathNames = paths.split('/').filter( path => path )

    return (
        pathNames.length !== 0 ? ( <div
            className="z-20 sticky top-0 p-2.5 bg-ghBlack2 text-white shadow-md"
            role="presentation"
          >
                <ul className="flex">
                    <li className="mr-2 hover:underline"><Link href={'/'}>
                        Home
                        </Link></li>
                    {pathNames.length > 0 && <span className='mr-2'>/</span>}
                {
                    pathNames.map( (link, index) => {
                        let href = `/${pathNames.slice(0, index + 1).join('/')}`
                        let itemClasses = paths === href ? `${listClasses} ${activeClasses}` : listClasses
                        let itemLink = capitalizeLinks ? link[0].toUpperCase() + link.slice(1, link.length) : link
                        
                        return (
                            <React.Fragment key={index}>
                                <li className="mr-2 hover:underline" >
                                    <Link href={href}>{transformName(itemLink)}</Link>
                                </li>
                                {pathNames.length !== index + 1 &&  <span className='mr-2'>/</span>}
                            </React.Fragment>
                        )
                    })
                }
                </ul>
            </div>):(<></>)
       
    )
}

export default Breadcrumb