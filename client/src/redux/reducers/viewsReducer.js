import { SET_NEXT_VIEW, SET_LAST_VIEW, SET_DEFAULT_VIEW } from "../actionTypes";

export const UIView = {
    Welcome: 1,
    General: 2,
    Resource: 3,
    Storage: 4,
    Optional: 5,
    Review: 6,
    ReviewA: 7,
    Installation: 8,
    ListApplication: 9
}

const initialState = {
    currentView: UIView.Welcome,
};

export default function (state = initialState, action) {
    switch (action.type) {
        case SET_NEXT_VIEW: {
            return Object.assign({}, state, {
                currentView: state.currentView + 1
            })
        }
        case SET_LAST_VIEW: {
            return Object.assign({}, state, {
                currentView: state.currentView - 1
            })
        }
        case SET_DEFAULT_VIEW: {
            return Object.assign({}, state, {
                currentView: 1
            })
        }
        default:
            return state;
    }
}
