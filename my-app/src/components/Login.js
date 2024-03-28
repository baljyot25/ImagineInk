import React from 'react';
import './Login.css'; // Import the created CSS file
import axios from 'axios';
const Login = () => {
  return (
    <div className="container">
      <h1 className="login-text">Log In</h1>
      <div>Need an account? <a href="#">Sign Up</a></div>
      <form>
        <div className="form-group">
          <label for="email">Email</label>
          <input type="text" className="form-control" id="email" placeholder="Email Address" />
        </div>
        <div className="form-group">
          <label for="password">Password</label>
          <input type="password" className="form-control" id="password" placeholder="Password" />
        </div>
      </form>
      <button type="button" className="btn btn-danger">Log In</button>
    </div>
  );
};
export default Login;
