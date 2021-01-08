import { combineReducers } from "redux";
import viewsReducer from "./viewsReducer";
import generalConfigReducer from "./generalConfigReducer";
import optionalConfigReducer from "./optionalConfigReducer";


export default combineReducers({ viewsReducer, generalConfigReducer, optionalConfigReducer });