import { useEffect, useState } from "preact/hooks";

export function ConfigSectionHeader({sectionTitle, SectionDescription}) {

    return (
        <div className='px-5 py-2 h-[65px]'>
            <h2 className='text-2xl font-semibold text-left'>{sectionTitle}</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>{SectionDescription}</p>
        </div>
    )

}