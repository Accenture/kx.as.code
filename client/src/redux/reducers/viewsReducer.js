import { SET_CURRENT_VIEW } from "../actionTypes";
const initialState = {
    currentView: 0,
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_CURRENT_VIEW: {
            return Object.assign({}, state, {
                currentView: action.payload.selectedView
              })
        }
        default:
            return state;
    }
}