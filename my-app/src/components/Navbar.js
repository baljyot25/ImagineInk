import React, { Component } from 'react'
import './Navbar.css';
import logo from '../images/logo.png';
import { Link } from 'react-router-dom'
export default class Navbar extends Component {
  render() {
    return (
      <>
      <div id ="header">
        
        <div className="header1">
            <div className="logos">
                
            {/* <img className="header1-Items" id="images/logo" src="static/images/webpage/logo.png" alt="ImagineInk Logo" width="30" height="30" /> */}
            <img className="header1-Items" id="images/logo" src={logo} alt="" width="30" height="30"/>    
            <a id="name" href="/">ImagineInk</a>
   
            </div>
            
            <div className="search-container">
                <input type="search" className="search-input" placeholder="Search designs and products"/>
                <div className="search-icon">
                    <i className="fa fa-search"></i>
                </div>
            </div>

            <div className="suggestion-list"></div>

            <ul className="navlinks">
                <li><a href="/">Sell your art</a></li>
                <li><Link to="/login">Login</Link></li>
                <li><a href="/">Signup</a></li>
                <li><a href="/">Cart</a></li>
            </ul>
           
            
        </div>

        <ul className="header2">
            <li><a href="/">Clothing</a></li>
            <li><a href="/">Phone cases</a></li>
            <li><a href="/">Stationery</a></li>
            <li><a href="/">Explore Designs</a></li>
            <li><a href="/">Others</a></li>
        </ul>
         
    </div>
      
    </>
    )
  }
}
