import { h, render } from 'preact';
import { App } from './app';
import './style.css';
import { HashRouter } from "react-router-dom";


render(
    <HashRouter basename={"/"}>
        <App />
    </HashRouter>
    , document.getElementById('app'));