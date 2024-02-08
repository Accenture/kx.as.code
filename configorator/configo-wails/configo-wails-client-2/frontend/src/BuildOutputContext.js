import React, { createContext, useContext, useReducer } from 'react';
import buildOutput from './assets/buildOutput.txt';

const BuildOutputContext = createContext();

const initialState = {
  buildOutput: '',
  intervalId: null,
};

const buildOutputReducer = (state, action) => {
  switch (action.type) {
    case 'UPDATE_BUILD_OUTPUT':
      return { ...state, buildOutput: action.payload };
    case 'SET_INTERVAL_ID':
      return { ...state, intervalId: action.payload };
    case 'CLEAR_INTERVAL':
      clearInterval(state.intervalId);
      return { ...state, intervalId: null };
    default:
      return state;
  }
};

export const BuildOutputProvider = ({ children }) => {
  const [state, dispatch] = useReducer(buildOutputReducer, initialState);

  const startInterval = () => {
    const intervalId = setInterval(() => {
      fetch(buildOutput)
        .then(response => response.text())
        .then(text => dispatch({ type: 'UPDATE_BUILD_OUTPUT', payload: text }));
    }, 1000);

    dispatch({ type: 'SET_INTERVAL_ID', payload: intervalId });
  };

  const clearInterval = () => {
    dispatch({ type: 'CLEAR_INTERVAL' });
  };

  return (
    <BuildOutputContext.Provider value={{ state, dispatch, startInterval, clearInterval }}>
      {children}
    </BuildOutputContext.Provider>
  );
};

export const useBuildOutput = () => {
  const context = useContext(BuildOutputContext);
  if (!context) {
    throw new Error('useBuildOutput must be used within a BuildOutputProvider');
  }
  return context;
};
