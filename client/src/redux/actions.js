import { SET_NEXT_VIEW, SET_LAST_VIEW, SET_DEFAULT_VIEW, SET_GENERAL_CONFIG } from "./actionTypes"

export const setNextView = () => ({
  type: SET_NEXT_VIEW
});
export const setLastView = () => ({
  type: SET_LAST_VIEW,
});
export const setDefaultView = () => ({
  type: SET_DEFAULT_VIEW,
});
export const setGeneralConfig = (generalConfig) => ({
  type: SET_GENERAL_CONFIG,
  payload: generalConfig,
});
