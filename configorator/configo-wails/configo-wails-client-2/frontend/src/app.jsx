import { useState } from "preact/hooks";
import './app.css';
import { Header } from "./Header";
import { Form2 } from "./Form2";
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';

export function App() {

    return (
        <div>
            <Header />
            <Router>
                <Routes>
                    <Route exact path="/" element={<Form2 />} />
                    {/* <Route path="/about" component={<About />} /> */}
                </Routes>
            </Router>
        </div>
    );
}
