import React, { Component } from 'react';
import './SignUp.css';
export default class SignUp extends Component {
  render() {
    return (
      <div>
        <div>Sign Up</div>
        <form>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput">Email</label>
            <input type="text" className="form-control" id="formGroupExampleInput" placeholder="Email Address"/>
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput2">Password</label>
            <input type="password" className="form-control" id="formGroupExampleInput2" placeholder="Password"/>
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput3">Username</label>
            <input type="text" className="form-control" id="formGroupExampleInput3" placeholder="Username"/>
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput4">Full Name</label>
            <input type="text" className="form-control" id="formGroupExampleInput4" placeholder="Full Name"/>
          </div>
          <div className="form-group">
            <label htmlFor="paymentMethod">Payment Method</label>
            <select className="form-control" id="paymentMethod">
              {/* <option value="">Select Payment Method</option> */}
              <option value="credit-card">Credit Card</option>
              <option value="paytm">PayTM</option>
              <option value="google-pay">Google Pay</option>
              <option value="bank-transfer">Bank Transfer</option>
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="formGroupExampleInput6">Address</label>
            <input type="text" className="form-control" id="formGroupExampleInput6" placeholder="Address"/>
          </div>
        </form>
        <button type="button" className="btn btn-danger">Sign Up</button>
        <div>Already have an account?<a href="#"> Log In</a></div>
      </div>
    );
  }
}
