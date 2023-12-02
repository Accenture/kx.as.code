'use client';
import { useState } from "react";
import createCache from '@emotion/cache';
import { useServerInsertedHTML } from 'next/navigation';
import { CacheProvider } from '@emotion/react';
import CssBaseline from '@mui/material/CssBaseline';
import { ThemeProvider, createTheme } from "@mui/material/styles";


export default function ThemeRegistry(props: any) {
    const { options, children } = props;

    const [{ cache, flush }] = useState(() => {
        const cache = createCache(options);
        cache.compat = true;
        const prevInsert = cache.insert;
        let inserted: string[] = [];
        cache.insert = (...args) => {
            const serialized = args[1];
            if (cache.inserted[serialized.name] === undefined) {
                inserted.push(serialized.name);
            }
            return prevInsert(...args);
        };
        const flush = () => {
            const prevInserted = inserted;
            inserted = [];
            return prevInserted;
        };
        return { cache, flush };
    });

    useServerInsertedHTML(() => {
        const names = flush();
        if (names.length === 0) {
            return null;
        }
        let styles = '';
        for (const name of names) {
            styles += cache.inserted[name];
        }
        return (
            <style
                key={cache.key}
                data-emotion={`${cache.key} ${names.join(' ')}`}
                dangerouslySetInnerHTML={{
                    __html: styles,
                }}
            />
        );
    });

    const darkTheme = createTheme({
        components: {
            MuiButton: {
                styleOverrides: {
                },
            },
            MuiDrawer: {
                styleOverrides: {
                    paper: {
                        backgroundColor: "#161b22",
                        color: "white",
                        border: "none"
                    }
                }
            },
            MuiListItemIcon: {
                styleOverrides: {
                    root: {
                        backgroundcolor: 'blue',
                    },
                },
            },
            MuiTooltip: {
                styleOverrides: {
                    tooltip: {
                        backgroundColor: '#5a86ff',
                        color: 'white',
                        fontSize: "14px"
                    }
                },
            },
            MuiMenuItem: {
                styleOverrides: {
                    root: {
                        backgroundColor: "#161b22", 
                        borderWidth: "0"
                    }
                }
            },
            MuiSelect: {
                styleOverrides: {
                    root: {
                        // backgroundColor: "#161b22", 
                    }
                }
            }
        },
        palette: { mode: "dark" },
        shape: {
            borderRadius: 0,
        }
    });

    return (
        <CacheProvider value={cache}>
            <ThemeProvider theme={darkTheme}>
                <CssBaseline />
                {children}

            </ThemeProvider>
        </CacheProvider>
    );
}
