import React, { useState, useEffect } from 'react';
import logo from './assets/images/logo-universal.png';
import './App.css';
import { Greet } from "../wailsjs/go/main/App";

function App() {
    const [resultText, setResultText] = useState("Please enter your name below 👇");
    const [name, setName] = useState('');
    const updateName = (e) => setName(e.target.value);
    const updateResultText = (result) => setResultText(result);
    const [formData, setFormData] = useState({});

    function greet() {
        Greet(name).then(updateResultText);
    }

    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchData() {
            try {
                console.log('Calling window.backend.GetFormData()');
                const response = await window.backend.GetFormData();
                console.log('Form Data Response: -------- - - - - - - - - - ', response);
                setFormData(JSON.parse(response));
            } catch (error) {
                console.error('Error fetching form data:', error);
            }
        }
        fetchData();
    }, []);

    console.log('Loading:', loading);
    console.log('FormData:', formData);

    return (
        <div id="App">
            <h2>Profile Configuration Form</h2>
            <div>
                <form method="post" action="/submit">
                    {Object.entries(formData).map(([key, value]) => (
                        <div key={key}>
                            <label htmlFor={key}>{key}:</label>
                            {typeof value === 'boolean' ? (
                                <input type="checkbox" id={key} name={key} defaultChecked={value} />
                            ) : (
                                <input type="text" id={key} name={key} placeholder={value} />
                            )}
                        </div>
                    ))}
                    <input type="submit" value="Submit" />
                </form>
            </div>
        </div>
    )
}

export default App
