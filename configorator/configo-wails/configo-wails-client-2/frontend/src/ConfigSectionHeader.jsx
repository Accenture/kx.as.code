import { useEffect, useState } from "preact/hooks";
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import { KeyboardArrowUp } from "@mui/icons-material";

export function ConfigSectionHeader({ sectionTitle, SectionDescription }) {
    const [showDescription, setShowDescription] = useState(false)

    return (
        <div className="p-1 bg-ghBlack4">
            <div className='px-5 bg-ghBlack2 text-white'>
                <div className="flex justify-between items-center py-2 hover:cursor-pointer" onClick={() => { setShowDescription((prev) => !prev) }}>
                    <div>
                        <h2 className='text-left'>{sectionTitle}</h2>
                    </div>
                    <span>
                        <button onClick={() => { }}
                            className={`hover:text-white text-gray-400 items-center flex justify-center p-1 hover:bg-ghBlack3 rounded-sm`}>
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
        </div >
    )

}