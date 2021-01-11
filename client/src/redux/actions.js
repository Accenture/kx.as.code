import { SET_NEXT_VIEW, SET_LAST_VIEW, SET_DEFAULT_VIEW, SET_GENERAL_CONFIG, SET_OPTIONAL_CONFIG, SET_PRIMARY_COLOR, SET_NETWORK_CONFIG, SET_STORAGE_CONFIG } from "./actionTypes"

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
export const setOptionalConfig = (optionalConfig) => ({
  type: SET_OPTIONAL_CONFIG,
  payload: optionalConfig,
});
export const setNetworkConfig = (networkConfig) => ({
  type: SET_NETWORK_CONFIG,
  payload: networkConfig,
});
export const setStorageConfig = (storageConfig) => ({
  type: SET_STORAGE_CONFIG,
  payload: storageConfig,
});
export const setPrimaryColor = (primaryColor) => ({
  type: SET_PRIMARY_COLOR,
  payload: primaryColor,
});

