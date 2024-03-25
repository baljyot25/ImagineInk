import React, { useState, useEffect } from 'react';
// import axios from 'axios';

const BackendTest = () => {
  const [data, setData] = useState([{}]);

  useEffect(() => {
    fetch("/members").then(
        res=> res.json()
    ).then(
        data=>{
            setData(data)
            console.log(data)
        }
    );
  }, []);

//   const fetchData = async () => {
//     try {
//       const response = await axios.get('http://localhost:5000/api/data');
//       setData(response.data);
//     } catch (error) {
//       console.error('Error fetching data:', error);
//     }
//   };

  return (
    <div>
      {/* <h1>Testing React and Flask Communication</h1>
      {data ? (
        <div>
          <h2>Data from Flask:</h2>
          <p>{data.message}</p>
        </div>
      ) : (
        <p>Loading...</p>
      )} */}
    </div>
  );
};

export default BackendTest;
