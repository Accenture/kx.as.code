import { SET_CURRENT_VIEW } from "./actionTypes";

export const setCurrentView = selectedView => ({
  type: SET_CURRENT_VIEW,
  payload: {
    selectedView
  }
});