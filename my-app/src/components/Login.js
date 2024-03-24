import React, { Component } from 'react'
import './Login.css';
export default class Login extends Component {
  render() {
    return (
        <div>
        <div>Log In</div>
        <div>Need an account? <a href="#">Sign Up</a></div>
        <form>
            <div className="form-group">
                <label for="formGroupExampleInput">Email</label>
                <input type="text" className="form-control" id="formGroupExampleInput" placeholder="Email Address"/>
            </div>
            <div className="form-group">
                <label for="formGroupExampleInput2">Password</label>
                <input type="password" className="form-control" id="formGroupExampleInput2" placeholder="Password"/>
            </div>

        </form>
        <button type="button" className="btn btn-danger">Log In</button>
    </div>
    )
  }
}
