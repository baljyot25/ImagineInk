import React, { Component } from 'react'
import Navbar from './Navbar'
import unicorn from '../images/Design/Unicorn.png';
import { Link } from 'react-router-dom'

export default class Home extends Component {
  render() {
    return (
      <>
      <Navbar></Navbar>
      <div>Shop Designs</div>
      
      <Link to="/login">
      <img src={unicorn} alt="Description of the image" />
      </Link>
      </>
    )
  }
}
