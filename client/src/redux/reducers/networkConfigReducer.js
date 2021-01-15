import { SET_NETWORK_CONFIG } from "../actionTypes";

export const initialNetworkConfig = {
    "MainNodeIP": "",
    "WorkerNode1IP": "",
    "WorkerNode2IP": "",
    "Gateway": "",
    "SecondaryDNS": "",
    "end": "",
    "HTTPProxy": "not defined",
    "HTTPSProxy": "not defined",
    "NoProxy": "not defined"  
}

const initialState = {
    networkConfig: initialNetworkConfig
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_NETWORK_CONFIG: {
            return Object.assign({}, state, {
                networkConfig: action.payload,
            })
        }
        default:
            return state;
    }
}