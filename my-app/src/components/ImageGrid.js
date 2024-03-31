import React, { Component } from 'react';

class ImageGrid extends Component {
  constructor(props) {
    super(props);
    this.state = {
      imagePaths: props.imagePaths || [],
    };
  }

  componentDidMount() {
    // Log paths when component mounts
    this.state.imagePaths.forEach((path, index) => {
      console.log(path);
    });
  }

  render() {
    return (
      <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', padding: '0 20px' }}>
        {this.state.imagePaths.map((path, index) => (
          <div key={index} style={{ width: '30%', margin: '10px', textAlign: 'center' }}>
            <img src={path} alt={`Image ${index}`} style={{ maxWidth: '100%', height: 'auto' }} />
            <div style={{ marginTop: '10px' }}>
              <button>Button</button>
              <p>Some Text</p>
            </div>
          </div>
        ))}
      </div>
    );
  }
}

export default ImageGrid;
