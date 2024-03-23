import { useEffect, useState } from "preact/hooks";
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import { KeyboardArrowUp } from "@mui/icons-material";

export function ConfigSectionHeader({ sectionTitle, SectionDescription, activeConfigTab, setActiveConfigTab, contentName }) {
    const [showDescription, setShowDescription] = useState(false)

    return (
        <div className="p-1 bg-ghBlack4">
            <div className='px-5 bg-ghBlack3 text-gray-400'>
                <div className="flex justify-between items-center py-2">
                    <div>
                        <h2 className='text-lg text-left font-semibold'>{sectionTitle}</h2>
                    </div>
                    <span>
                        <button onClick={() => {
                            setShowDescription(!showDescription)
                        }} className={`hover:text-white items-center flex justify-center`}>
                            {showDescription ? (
                                <KeyboardArrowUp fontSize="small" />
                            ) : (
                                <KeyboardArrowDownIcon fontSize="small" />
                            )}
                        </button>
                    </span>
                </div>
                {showDescription && (
                    <div className="pb-3">
                        <p className='text-sm dark:text-gray-400 text-justify'>{SectionDescription}</p>
                    </div>
                )}
            </div>
        </div>
    )

}