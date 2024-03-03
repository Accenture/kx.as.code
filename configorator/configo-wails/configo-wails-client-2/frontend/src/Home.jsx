import React, { useState, useEffect } from 'react';


export default function Home() {
    const initialData = [
        {
            "action_queues": {
                "install": [
                    {
                        "install_folder": "cicd",
                        "name": "argocd"
                    }
                ]
            },
            "description": "New Group Description",
            "title": "New Group 3"
        },
        {
            "action_queues": {
                "install": []
            },
            "description": "New Group Description",
            "title": "New Group 2"
        },
        {
            "action_queues": {
                "install": []
            },
            "description": "New Group Description",
            "title": "New Group 1"
        },
        {
            "action_queues": {
                "install": [
                    {
                        "install_folder": "examples",
                        "name": "hipster-shop"
                    },
                    {
                        "install_folder": "cicd",
                        "name": "artifactory"
                    }
                ]
            },
            "description": "Group used to show specific use cases and for debugging changes and enhancements to the framework",
            "title": "Examples Group 1"
        }
    ];

    const [data, setData] = useState(initialData);
    const [selectedItem, setSelectedItem] = useState(null);
    const [windowHeight, setWindowHeight] = useState(window.innerHeight);

    const handleItemClick = (index) => {
        setSelectedItem(index);
    };

    const handleInputChange = (field, value) => {
        setData((prevData) => {
            const newData = [...prevData];
            newData[selectedItem][field] = value;
            return newData;
        });
    };

    const handleAddNewItem = () => {
        setData((prevData) => {
            const newData = [...prevData, { action_queues: { install: [] }, description: '', title: '' }];
            setSelectedItem(newData.length - 1);
            return newData;
        });
    };

    const handleAddApplication = () => {
        setData((prevData) => {
            const newData = [...prevData];
            newData[selectedItem].action_queues.install.push({ install_folder: '', name: '' });
            return newData;
        });
    };

    const handleDeleteItem = (index) => {
        setData((prevData) => {
            const newData = [...prevData];
            newData.splice(index, 1);
            if (selectedItem === index) {
                setSelectedItem(null);
            }
            return newData;
        });
    };

    useEffect(() => {
        const handleResize = () => {
            setWindowHeight(window.innerHeight);
        };
        window.addEventListener('resize', handleResize);

        const listElement = document.getElementById('list');
        listElement.scrollTop = selectedItem * 50;

        return () => {
            window.removeEventListener('resize', handleResize);
        };
    }, [selectedItem, windowHeight]);

    return (
        <div className='flex flex-col bg-blue-700' style={{ minHeight: `${windowHeight - 100 - 67}px` }}>
            <div className='h-[100px] bg-orange-500'>
                Hallo 1 {windowHeight}
            </div>
            <div className='flex-1 bg-violet-500'>
                <div className="flex flex-1" id="main">
                    <div className={`w-1/2 p-4 overflow-y-auto bg-gray-500`} style={{ height: `${windowHeight - 100 - 67 - 67}px` }} id="list">
                        <button className="bg-blue-500 text-white p-2 mb-4" onClick={handleAddNewItem}>
                            Add new List Item
                        </button>
                        {data.map((item, index) => (
                            <div
                                key={index}
                                className={`p-2 cursor-pointer ${selectedItem === index ? 'bg-orange-500' : ''}`}
                                onClick={() => handleItemClick(index)}
                            >
                                {item.title}
                                <button
                                    className="ml-2 text-red-500"
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        handleDeleteItem(index);
                                    }}
                                >
                                    Delete
                                </button>
                            </div>
                        ))}
                    </div>
                    <div className="w-1/2 p-4 overflow-y-auto bg-gray-600" style={{ height: `${windowHeight - 100 - 67 - 67}px` }}>
                        {selectedItem !== null && data[selectedItem] && (
                            <>
                                <div>
                                    <label>Title:</label>
                                    <input
                                        className='text-black'
                                        type="text"
                                        value={data[selectedItem].title}
                                        onChange={(e) => handleInputChange('title', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <label>Description:</label>
                                    <input
                                        className='text-black'
                                        type="text"
                                        value={data[selectedItem].description}
                                        onChange={(e) => handleInputChange('description', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <button className="bg-green-500 text-white p-2" onClick={handleAddApplication}>
                                        Add Application
                                    </button>
                                </div>
                                <div>
                                    <h2>Applications:</h2>
                                    {data[selectedItem].action_queues.install.map((app, appIndex) => (
                                        <div key={appIndex}>
                                            <label>Install Folder:</label>
                                            <input
                                                className='text-black'
                                                type="text"
                                                value={app.install_folder}
                                                onChange={(e) => {
                                                    const newApps = [...data[selectedItem].action_queues.install];
                                                    newApps[appIndex].install_folder = e.target.value;
                                                    setData((prevData) => {
                                                        const newData = [...prevData];
                                                        newData[selectedItem].action_queues.install = newApps;
                                                        return newData;
                                                    });
                                                }}
                                            />
                                            <label>Name:</label>
                                            <input
                                                className='text-black'
                                                type="text"
                                                value={app.name}
                                                onChange={(e) => {
                                                    const newApps = [...data[selectedItem].action_queues.install];
                                                    newApps[appIndex].name = e.target.value;
                                                    setData((prevData) => {
                                                        const newData = [...prevData];
                                                        newData[selectedItem].action_queues.install = newApps;
                                                        return newData;
                                                    });
                                                }}
                                            />
                                            <button
                                                className="ml-2 text-red-500"
                                                onClick={() => {
                                                    const newApps = [...data[selectedItem].action_queues.install];
                                                    newApps.splice(appIndex, 1);
                                                    setData((prevData) => {
                                                        const newData = [...prevData];
                                                        newData[selectedItem].action_queues.install = newApps;
                                                        return newData;
                                                    });
                                                }}
                                            >
                                                Delete
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            </>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );

};