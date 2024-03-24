import { useEffect, useState } from "react";
import { Link } from "react-router-dom"
import { CreateWorkspaceFile } from "../wailsjs/go/main/App"
import { ConfigSectionHeader } from "./ConfigSectionHeader";
import { Add } from '@mui/icons-material';
import { BiSolidCommentError } from "react-icons/bi";
import { WorkspacesListAndDetail } from "./WorkspacesListAndDetail";



export function Workspaces({ isJsonView }) {
    const [workspaceDetailTab, setWorkspaceDetailTab] = useState("config-ui");
    const [windowHeight, setWindowHeight] = useState(window.innerHeight);

    const [workspaces, setWorkspaces] = useState([
        // {
        //     name: "Workspace 1",
        //     location_path: ""
        // },
        // {
        //     name: "Workspace 2",
        //     location_path: ""
        // },
        // {
        //     name: "Workspace 3",
        //     location_path: ""
        // }
    ]);

    const handleAddNewWorkspace = async () => {
        CreateWorkspaceFile("test")
    };

    useEffect(() => {

    }, []);

    return (
        <div className="">
            <ConfigSectionHeader sectionTitle={"My Workspaces"} SectionDescription={"More details about this section here."} />
            <NoWorkspaces />

            {/* <div className="grid grid-cols-12 gap-2 p-5 bg-ghBlack2">
                {workspaces.map((workspace, i) => {
                    return <WorkspaceCard name={workspace.name} />
                })}
                {workspaces.length < 1 && (<NoWorkspaces />)}
            </div> */}

            {/* <WorkspacesListAndDetail workspaceDetailTab={workspaceDetailTab} setWorkspaceDetailTab={setWorkspaceDetailTab} windowHeight={windowHeight} isJsonView={isJsonView}/> */}
        </div>
    );
}


const WorkspaceCard = ({ name }) => {
    return (
        <div className="col-span-2 bg-ghBlack3 p-1 h-[150px] cursor-pointer hover:bg-ghBlack4 flex items-center justify-center text-sm rounded-sm">
            {name}
        </div>
    )
}


const NoWorkspaces = () => {
    return (
        <div className="bg-ghBlack2 py-[100px] text-center text-gray-400">
            <div className="mx-auto border border-ghBlack4 rounded p-5 w-[400px]">
                <BiSolidCommentError className="text-[30px] mx-auto" />
                <div className="py-2">No Workspace created yet.</div>
                <button className="mx-auto flex justify-center items-center text-gray-400 hover:text-white hover:bg-ghBlack4 bg-ghBlack3 p-1 rounded-sm">
                    <Add />
                </button>
            </div>
        </div>
    )
}