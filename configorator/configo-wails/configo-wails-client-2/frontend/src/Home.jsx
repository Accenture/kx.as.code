import React, { useState, useEffect } from 'react';


const Home = () => {

    const initialData = [
        {
            name: 'Item 1',
            description: 'Description 1',
            groupName: 'Group 1',
            members: [{ firstName: 'John', lastName: 'Doe' }]
        },
        {
            name: 'Item 2',
            description: 'Description 2',
            groupName: 'Group 2',
            members: [{ firstName: 'Jane', lastName: 'Doe' }]
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
            const newData = [...prevData, { name: '', description: '', groupName: '', members: [] }];
            setSelectedItem(newData.length - 1);
            return newData;
        });
    };

    const handleAddMember = () => {
        setData((prevData) => {
            const newData = [...prevData];
            newData[selectedItem].members.push({ firstName: 'Peter', lastName: 'Mueller' });
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

        // Detach event listener on component unmount
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
                    <div className={`w-1/2 p-4 overflow-y-auto bg-gray-500`}  style={{ height: `${windowHeight - 100 - 67 - 67}px` }} id="list">
                        <button className="bg-blue-500 text-white p-2 mb-4" onClick={handleAddNewItem}>
                            Add new List Item
                        </button>
                        {data.map((item, index) => (
                            <div
                                key={index}
                                className={`p-2 cursor-pointer ${selectedItem === index ? 'bg-orange-500' : ''
                                    }`}
                                onClick={() => handleItemClick(index)}
                            >
                                {item.name} - {item.groupName}
                            </div>
                        ))}
                    </div>
                    <div className="w-1/2 p-4 overflow-y-auto bg-gray-600" style={{ height: `${windowHeight - 100 - 67 - 67}px` }}>
                        {selectedItem !== null && (
                            <>
                                <div>
                                    <label>Name:</label>
                                    <input
                                        className='text-black'
                                        type="text"
                                        value={data[selectedItem].name}
                                        onChange={(e) => handleInputChange('name', e.target.value)}
                                    />
                                </div>
                                <div>
                                    <label>Group Name:</label>
                                    <input
                                        className='text-black'
                                        type="text"
                                        value={data[selectedItem].groupName}
                                        onChange={(e) => handleInputChange('groupName', e.target.value)}
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
                                    <button className="bg-green-500 text-white p-2" onClick={handleAddMember}>
                                        Add Member
                                    </button>
                                </div>
                                <div>
                                    <h2>Members:</h2>
                                    {data[selectedItem].members.map((member, index) => (
                                        <div key={index}>
                                            {member.firstName} {member.lastName}
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

export default Home;
