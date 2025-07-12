// BasicFigure.js
import React from 'react';

// Component that displays a single figure with image and caption
const BasicFigure = ({ imageUrl, caption }) => {
  return (
    <div className="figure">
      {/* Image element with source and alt text */}
      <img src={imageUrl} alt={caption} className="figure-image" />
      {/* Caption for the image */}
      <p className="figure-caption">{caption}</p>
    </div>
  );
};

export default BasicFigure;

// FigureList.js
import React, { useState } from 'react';
import BasicFigure from './BasicFigure';

// Component that manages and displays a list of figures
const FigureList = () => {
    // State to store the array of figures
    const [figures, setFigures] = useState([
        { imageUrl: 'https://picsum.photos/400', caption: 'Random Image 1' },
        { imageUrl: 'https://picsum.photos/400', caption: 'Random Image 2' },
        { imageUrl: 'https://picsum.photos/400', caption: 'Random Image 3' },
        { imageUrl: 'https://picsum.photos/400', caption: 'Random Image 4' },
    ]);

    // Function to add a new figure to the list
    const addFigure = () => {
        const newFigure = {
            imageUrl: `https://picsum.photos/400?random=${figures.length + 1}`,
            caption: `Random Image ${figures.length + 1}`,
        };
        setFigures([...figures, newFigure]);
    };

    // Function to remove the last figure from the list
    const removeFigure = () => {
        const updatedFigures = figures.slice(0, -1);
        setFigures(updatedFigures);
    };

    return (
        <div className="figure-list-container">
            {/* Container for action buttons */}
            <div className='button-box'>
                <button onClick={addFigure} className="action-button">Add Image</button>
                <button onClick={removeFigure} className="action-button">Remove Image</button>
            </div>
            {/* Container for the list of figures */}
            <div className="figure-list">
                {/* Map through figures array and render BasicFigure for each */}
                {figures.map((figure, index) => (
                    <BasicFigure key={index} imageUrl={figure.imageUrl} caption={figure.caption} />
                ))}
            </div>
        </div>
    );
};

export default FigureList;

// App.js
import React from 'react';
import FigureList from './components/FigureList';
import './App.css';

// Main application component
const App = () => {
  return (
    <div className="app">
      {/* Application title */}
      <h1>Dynamic Image Gallery</h1>
      {/* Render the FigureList component */}
      <FigureList />
    </div>
  );
};

export default App;

/* CSS styles for the application */
*{
  /* Reset default padding and margin */
  padding: 0;
  margin: 0;
  /* Use border-box sizing model */
  box-sizing: border-box;
}

/* Style for h1 heading */
h1 {
  background: #000;
  color: #fff;
  padding: 10px;
  text-align: center;
}

/* Container for the figure list */
.figure-list-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 20px;
}

/* Container for action buttons */
.button-box {
  display: block;
  text-align: center;
  padding: 10px;
  margin-bottom: 20px;
}

/* Style for action buttons */
.action-button {
  padding: 10px 20px;
  margin: 10px;
  background-color: #4CAF50;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 16px;
  transition: background-color 0.3s ease;
}

/* Hover effect for action buttons */
.action-button:hover {
  background-color: #45a049;
}

/* Container for the list of figures */
.figure-list {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 15px;
}

/* Style for images in figure list */
.figure-list img {
  max-width: 200px;
  max-height: 200px;
  border: 2px solid #ccc;
  border-radius: 8px;
}

/* Style for figure element */
figure {
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* Style for figure caption */
figcaption {
  margin-top: 8px;
  font-size: 14px;
  color: #555;
}

/* Style for individual figure container */
.figure {
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 2px solid #ddd;
  border-radius: 8px;
  padding: 10px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

/* Hover effect for figure */
.figure:hover {
  transform: translateY(-5px);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.2);
}

/* Style for figure image */
.figure-image {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  object-fit: cover;
}

/* Style for figure caption text */
.figure-caption {
  margin-top: 10px;
  font-size: 14px;
  color: #555;
  text-align: center;
}
