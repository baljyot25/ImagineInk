import React, { Component } from 'react';
import Navbar from './Navbar';
import ImageGrid from './ImageGrid';

// import { Link } from 'react-router-dom';
import axios from 'axios';

export default class Home extends Component {
  async componentDidMount() {
    try {
      console.log("home page called called");
      const response = await axios.post('http://127.0.0.1:8000/customer/view_designs');
      // handle the response 
      
      console.log(response.data);
    } catch (error) {
      // handle error
      console.error('Error fetching products:', error);
    }
  }

  render() {

    console.log('Component rendered');

    const imagePaths = [
      '../iamges/design/1.jpg'
      // '../images/design/2.jpg',
      // Add paths for other images here
    ];
    return (
      <>
        <Navbar />
        <div>Shop Designs</div>
        {/* <Link to="/login">
          <img src={unicorn} alt="Description of the image" />
        </Link> */}


      <h1>Image Grid</h1>
      <ImageGrid imagePaths={imagePaths} />
      </>
    );
  }
}
