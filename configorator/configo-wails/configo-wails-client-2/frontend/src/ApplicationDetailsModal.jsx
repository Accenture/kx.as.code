import { Modal } from '@mui/material';
import { Box } from '@mui/system';
import React, { useState, useEffect, useRef } from 'react';
import InputField from './InputField';


export function ApplicationDetailsModal({ open, handleClose, handleInputChange }) {

    const modalStyle = {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        width: 700,
        border: '0',
        boxShadow: 24,
        p: 4
    };

    return (
        <Modal
            open={open}
            onClose={handleClose}
            aria-labelledby="modal-modal-title"
            aria-describedby="modal-modal-description"
        >
            <Box sx={modalStyle} className="text-white bg-ghBlack2 focus:outline-none rounded-sm">
                <h2 className='mb-3'>Create a new Application</h2>

                <div className="bg-ghBlack3 h-[100px] w-[100px] rounded-sm mb-3 mx-auto"></div>
                <InputField inputType={"input"} type={"text"} placeholder={"Add an Application name"} dataKey={"application_name"} label={"Application Name"} />

                <InputField inputType={"textarea"} type={"text"} placeholder={"Add an Application Description"} dataKey={"application_desc"} label={"Application Description"} />

                <InputField inputType={"input"} type={"text"} placeholder={"Add a Namespace"} dataKey={"application_namespace"} label={"Namespace"} />

                <InputField inputType={"input"} type={"text"} placeholder={"Add an Installation Type"} dataKey={"application_installation_type"} label={"Installation Type"} />

                <InputField inputType={"input"} type={"text"} placeholder={"Add an Installation Group Folder"} dataKey={"application_installation_group_folder"} label={"Installation Group Folder"} />

            </Box>
        </Modal>
    )
}