import React, { Component } from 'react';
import './SignUp.css'; // Import the generated CSS file

export default class SignUp extends Component {
  render() {
    return (
      <div className="container"> {/* Wrap elements in the container class */}
        <div className="signup-text"> {/* Add class for signup text */}
          Sign Up
        </div>
        <form>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput">Email</label>
            <input type="text" className="form-control" id="formGroupExampleInput" placeholder="Email Address" />
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput2">Password</label>
            <input type="password" className="form-control" id="formGroupExampleInput2" placeholder="Password" />
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput3">Username</label>
            <input type="text" className="form-control" id="formGroupExampleInput3" placeholder="Username" />
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput4">Full Name</label>
            <input type="text" className="form-control" id="formGroupExampleInput4" placeholder="Full Name" />
          </div>
          <div className="form-group">
            <label htmlFor="paymentMethod">Payment Method</label>
            <select className="form-control" id="paymentMethod">
              <option value="credit-card">Credit Card</option>
              <option value="paytm">PayTM</option>
              <option value="google-pay">Google Pay</option>
              <option value="bank-transfer">Bank Transfer</option>
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput6">Address</label>
            <input type="text" className="form-control" id="formGroupExampleInput6" placeholder="Address" />
          </div>
        </form>
        <button type="button" className="btn-primary">Sign Up</button> {/* Use btn-primary for blue button */}
        <div>
          Already have an account? <a href="#">Log In</a>
        </div>
      </div>
    );
  }
}
