import { SET_STORAGE_CONFIG } from "../actionTypes";

export const initialStorageConfig = {
    "MainNode": {
        "GlusterFS Storage": "100 GB",
        "Local volumes": "100 GB"
    },
    "WorkerNode": {
        "Local volumes": "200 GB"
    },
    "TOTAL": {
        "OVERALLTOTAL": "400 GB"
    }
}

const initialState = {
    storageConfig: initialStorageConfig
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_STORAGE_CONFIG: {
            return Object.assign({}, state, {
                storageConfig: action.payload,
            })
        }
        default:
            return state;
    }
}