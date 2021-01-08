import { SET_GENERAL_CONFIG } from "../actionTypes";

export const initialGeneralConfig = {
    profileName: "",
    teamName: "",
    profileType: "",
    kubernetesSeesionTimeout: false,
    profileSubType: "",
    baseDomain: "",
    defaultUser: "",
    defaultPassword: "",
    certificationMode: false,
}

const initialState = {
    generalConfig: initialGeneralConfig
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_GENERAL_CONFIG: {
            return Object.assign({}, state, {
                generalConfig: action.payload,
            })
        }
        default:
            return state;
    }
}