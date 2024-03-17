import { useEffect, useState } from "preact/hooks";

export function ConfigSectionHeader({ sectionTitle, SectionDescription, activeConfigTab, setActiveConfigTab, contentName }) {

    return (
        <div className='px-5 pt-2 pb-0 grid grid-cols-12'>
            <div className="col-span-6 pb-2">
                <h2 className='text-2xl font-semibold text-left'>{sectionTitle}</h2>
                <p className='text-sm dark:text-gray-400 text-justify'>{SectionDescription}</p>
            </div>
            <div className="col-span-6 relative">
                {/* JSON View Toggle */}
                <div className="flex justify-end bottom-0 right-0 absolute">
                    <div className='flex itmes-center text-sm '>
                        <button
                            onClick={() => { setActiveConfigTab("config-tab1") }}
                            className={` ${activeConfigTab == "config-tab1" ? 'border-kxBlue border-b-3 bg-ghBlack3 text-white' : 'border-ghBlack4 hover:border-ghBlack4 border-b-3 '} px-4 py-2 text-gray-400 hover:text-white rounded-tr-sm rounded-tl-sm`}
                        >
                            {contentName} - Config UI
                        </button>
                        <button
                            onClick={() => { setActiveConfigTab("config-tab2") }}
                            className={` ${activeConfigTab == "config-tab2" ? 'border-kxBlue border-b-3 bg-ghBlack3 text-white' : 'border-ghBlack4 border-b-3 hover:border-ghBlack4 '} px-4 py-2 text-gray-400 hover:text-white rounded-tr-sm rounded-tl-sm`}
                        >
                            {contentName} - JSON
                        </button>
                    </div>
                </div>
            </div>
        </div>
    )

}