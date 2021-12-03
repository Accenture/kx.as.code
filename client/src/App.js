import React, { useEffect } from 'react';
import Dashboard from './components/Dashboard';
import {
  Switch,
  Route,
  useLocation
} from 'react-router-dom';
import { focusHandling } from 'cruip-js-toolkit';

import "./css/style.scss"

function App() {
  const location = useLocation();

  useEffect(() => {
    document.querySelector('html').style.scrollBehavior = 'auto'
    window.scroll({ top: 0 })
    document.querySelector('html').style.scrollBehavior = ''
    focusHandling('outline');
  }, [location.pathname]); // triggered on route change

  return (
    <>
      <Switch>
        <Route exact path="/">
          <Dashboard />
        </Route>
      </Switch>
    </>
  );
}

export default App;
