import { SET_NEXT_VIEW, SET_LAST_VIEW, SET_DEFAULT_VIEW } from "./actionTypes"

export const setNextView = () => ({
  type: SET_NEXT_VIEW
});
export const setLastView = () => ({
  type: SET_LAST_VIEW,
});
export const setDefaultView = () => ({
  type: SET_DEFAULT_VIEW,
});
