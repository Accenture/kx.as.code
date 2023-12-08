import React, { useState, useEffect } from 'react';

function App() {
    const [formData, setFormData] = useState(null);

    useEffect(() => {
        async function fetchData() {
            try {
                const response = await window.backend.getFormData();
                console.log('Form Data Response:', response);
                setFormData(JSON.parse(response));
            } catch (error) {
                console.error('Error fetching form data:', error);
            }
        }
        fetchData();
    }, []);
    if (!formData) {
        return <div>Loading...</div>;
    }

    return (
        <div id="App">
            <h2>Profile Configuration Form</h2>
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
    );
}

export default App;
