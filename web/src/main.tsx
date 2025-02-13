import React from 'react';
import ReactDOM from 'react-dom/client';
import { MantineProvider, } from '@mantine/core';
import App from './components/App';
import { LangProvider } from './utils/LangContext';



ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <MantineProvider theme={{ colorScheme: 'dark' }}>
      <LangProvider>
        <App />
      </LangProvider>
    </MantineProvider>
  </React.StrictMode >
);
