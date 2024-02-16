import { useEffect, useState } from "preact/hooks";

export function ConfigSectionHeader({sectionTitle, SectionDescription}) {

    return (
        <div className='px-5 py-3'>
            <h2 className='text-3xl font-semibold text-left'>{sectionTitle}</h2>
            <p className='text-sm dark:text-gray-400 text-justify'>{SectionDescription}</p>
        </div>
    )

}