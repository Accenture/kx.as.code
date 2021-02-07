import { SET_OPTIONAL_CONFIG, SET_PRIMARY_COLOR} from "../actionTypes";

export const initialOptionalConfig = {
    dockerHubUserName: "",
    dockerHubPassword: "",
}

const initialState = {
    primaryColor: "#3290d1",
    optionalConfig: initialOptionalConfig
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_OPTIONAL_CONFIG: {
            return Object.assign({}, state, {
                optionalConfig: action.payload,
            })
        }
        case SET_PRIMARY_COLOR: {
            return Object.assign({}, state, {
                primaryColor: action.payload,
            })
        }
        default:
            return state;
    }
}
