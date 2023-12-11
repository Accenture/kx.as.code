import { useState } from "preact/hooks";
import './app.css';
import { Greet } from "../wailsjs/go/main/App";
import config from './assets/profile-config-template.json';

export function Form2() {
    const [formData, setFormData] = useState({});

    const handleChange = (key, value) => {
        setFormData({
            ...formData,
            [key]: value,
        });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        // Handle form submission with formData
        console.log('Form Data:', formData);
    };

    const renderFields = (fields) => {
        return Object.entries(fields).map(([key, value]) => {
            if (typeof value === 'string' || typeof value === 'boolean' || typeof value === 'number') {
                return (
                    <div key={key}>
                        <label htmlFor={key}>{key}:</label>
                        {typeof value === 'boolean' ? (
                            <input
                                type="checkbox"
                                id={key}
                                name={key}
                                checked={value}
                                onChange={(e) => handleChange(key, e.target.checked)}
                            />
                        ) : typeof value === 'number' ? (
                            <input
                                type="number"
                                id={key}
                                name={key}
                                placeholder={value}
                                onChange={(e) => handleChange(key, e.target.value)}
                            />
                        ) : (
                            <input
                                type="text"
                                id={key}
                                name={key}
                                placeholder={value}
                                onChange={(e) => handleChange(key, e.target.value)}
                            />
                        )}
                    </div>
                );
            } else if (Array.isArray(value)) {
                // If value is a string array, create a dropdown select field
                return (
                    <div key={key}>
                        <label htmlFor={key}>{key}:</label>
                        <select id={key} name={key} onChange={(e) => handleChange(key, e.target.value)}>
                            {value.map((item, index) => (
                                <option key={index} value={item}>
                                    {item}
                                </option>
                            ))}
                        </select>
                    </div>
                );
            } else if (typeof value === 'object') {
                // If value is a nested map, recurse into it
                return (
                    <div key={key} style={{}} className="">
                        <h3>{key}</h3>
                        {renderFields(value)}
                    </div>
                );
            }

            return null;
        });
    };

    return (
        <div>
            <form method="post" action="/submit" onSubmit={handleSubmit}>
                {renderFields(config)}
                <input type="submit" value="Submit" />
            </form>
        </div>
    );
}
