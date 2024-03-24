import React, { Component } from 'react'

export default class Login extends Component {
  render() {
    return (
        <div>
        <div>Log In</div>
        <div>Need an account? <a href="#">Sign Up</a></div>
        <form>
            <div class="form-group">
                <label for="formGroupExampleInput">Email</label>
                <input type="text" class="form-control" id="formGroupExampleInput" placeholder="Email Address"/>
            </div>
            <div class="form-group">
                <label for="formGroupExampleInput2">Password</label>
                <input type="password" class="form-control" id="formGroupExampleInput2" placeholder="Password"/>
            </div>

        </form>
        <button type="button" class="btn btn-danger">Log In</button>
    </div>
    )
  }
}
