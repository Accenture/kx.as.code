import { combineReducers } from "redux";
import viewsReducer from "./viewsReducer";
import generalConfigReducer from "./generalConfigReducer";


export default combineReducers({ viewsReducer, generalConfigReducer });