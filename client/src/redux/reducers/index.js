import { combineReducers } from "redux";
import viewsReducer from "./viewsReducer";
import generalConfigReducer from "./generalConfigReducer";
import optionalConfigReducer from "./optionalConfigReducer";
import networkConfigReducer from "./networkConfigReducer";
import storageConfigReducer from "./storageConfigReducer"


export default combineReducers({ viewsReducer, generalConfigReducer, optionalConfigReducer, networkConfigReducer, storageConfigReducer });