import { useState } from "preact/hooks";
import './app.css';
import { Header } from "./Header";
import { Form2 } from "./Form2";
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import TabMenu from "./TabMenu";
import { createTheme, ThemeProvider, styled } from '@mui/material/styles';
import { ConsoleOutput } from "./ConsoleOutput";

const theme = createTheme({
    components: {},
    shape: {
        borderRadius: 0,
    },
    palette: {
      mode: 'dark',
      primary: {
        main: '#5a86ff',
      }
    },
  });


export function App() {

    return (

        <ThemeProvider theme={theme}>
            <div className="bg-ghBlack2">
                <Header />
                <Router>
                    <Routes>
                        <Route exact path="/" element={<TabMenu />} />
                        <Route path="/console-output" element={<ConsoleOutput />} />
                    </Routes>
                </Router>
            </div>
        </ThemeProvider>

    );
}
