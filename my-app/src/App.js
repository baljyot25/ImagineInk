// import './App.css';
import { lazy,Suspense } from 'react';
import "bootstrap/dist/css/bootstrap.min.css";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Login from './components/Login';
import Navbar from './components/Navbar';
import Homepage from './components/Homepage';
import Footer from './components/Footer/Footer';
import Loader from './components/Loader/Loader';

import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import SignUp from './components/SignUp';

function App() {

  const router = createBrowserRouter([
    {
      path: "/",
      element: <><Homepage /></>
    },
    {
      path: "/login",
      element: <><Login /></>
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
    <Suspense fallback={<Loader />}>
    {/* <SignUp
    ></SignUp> */}
    {/* <Homepage></Homepage> */}
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
    <Footer />
    </Suspense>


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
