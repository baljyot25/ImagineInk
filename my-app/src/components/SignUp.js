import React, { useState } from 'react';
import './SignUp.css'; // Import the created CSS file
import axios from 'axios';

const Signup = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      console.log("sign up called");
      const response = await axios.post('http://127.0.0.1:8000/customer/login', { 'email': email, 'password': password });
      // handle the response 
      console.log(response);
    } catch (error) {
      // handle the error
    }
  };

  return (
    <div className="container">
      <h1 className="signup-text">Sign Up</h1>
      <div>Already have an account? <a href="#">Log In</a></div>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="email">Email</label>
          <input type="text" className="form-control" id="email" placeholder="Email Address" value={email} onChange={e => setEmail(e.target.value)} />
        </div>
        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input type="password" className="form-control" id="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} />
        </div>
        <button type="submit" className="btn btn-danger">Sign Up</button>
      </form>
    </div>
  );
};

export default Signup;