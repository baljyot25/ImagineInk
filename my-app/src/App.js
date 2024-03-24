
import './App.css';
import Login from './components/Login';
import Navbar from './components/Navbar';

import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import SignUp from './components/SignUp';

function App() {

  const router = createBrowserRouter([
    {
      path: "/",
      element: <><Navbar /></>
    },
    {
      path: "/login",
      element: <><Login/></>
    },
    {
      path: "/signup",
      element: <><SignUp/></>
    }
    // {
    //   path: "/user/:username",
    //   element: <><Navbar /><User /></>
    // },
  ])
  return (
    <>
    {/* <SignUp
    ></SignUp> */}

  <RouterProvider router={router} />




    {/* <Router>
      <Switch>
        <Route path="/login">
          <Login />
        </Route>
          
        <Route path="/">
          <Navbar/>
        </Route>
      </Switch>
    </Router> */}
    </>


// <>
// <BrowserRouter>
//   <Navbar
//     title="TextUtils2"
//     aboutText="TextAbouts"
//     mode={mode}
//     toggleMode={toggleMode}
//   />
//   <Alert alert={alert} />
//   <div className="container my-4" mode={mode}>
//     <Routes>
//       <Route exact path="/about" element={<About />}></Route>
//       <Route
//         exact path="/"
//         element={
//           <Textbox
//             showAlert={showAlert}
//             heading="Enter Text to analyze "
//             mode={mode}
//           />
//         }
//       ></Route>
//     </Routes>
//   </div>
// </BrowserRouter>
// </>
  );
}

export default App;
