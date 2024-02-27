import React from 'react';

const ContextMenu = ({ children, top, left, onClose }) => {

  const handleClick = (e) => {
    e.stopPropagation();
    onClose();
  };

  return (
    <div
      className='text-sm'
      style={{
        position: 'fixed',
        top: `${top}px`,
        left: `${left}px`,
        backgroundColor: '#161b22',
        border: 'none',
        padding: '5px',
        zIndex: 1000,
        borderRadius: "5px",
        width: "auto"
      }}
      onClick={() => { handleClick() }}
    >
      {children}
    </div>
  );
};

export default ContextMenu;