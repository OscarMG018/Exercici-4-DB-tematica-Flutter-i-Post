const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Function to convert image to base64
async function putImageBase64(imagePath) {
    try {
        const image = await fs.readFile(imagePath);
        const base64Image = image.toString('base64');
        return `data:image/png;base64,${base64Image}`;
    } catch (error) {
        console.error(`Error reading image ${imagePath}:`, error);
        return null;
    }
}

// Function to get item with base64 image
async function getItemWithBase64Image(item) {
    const imagePath = path.join(__dirname, item.image);
    const base64Image = await putImageBase64(imagePath);
    return {
        ...item,
        image: base64Image || item.image
    };
}

// Function to read JSON file
async function readJsonFile(filePath) {
    try {
        const data = await fs.readFile(filePath, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error(`Error reading JSON file ${filePath}:`, error);
        return null;
    }
}

// Get items by category
app.get('/api/items/category/:category', async (req, res) => {
    const category = req.params.category;
    const itemsData = await readJsonFile(path.join(__dirname, 'assets/json/items.json'));
    
    if (!itemsData) {
        return res.status(500).json({
            success: false,
            error: 'Failed to read items data'
        });
    }

    const filteredItems = itemsData.items.filter(item => 
        item.category === category
    );
    
    // Convert all images to base64
    const itemsWithBase64 = await Promise.all(
        filteredItems.map(item => getItemWithBase64Image(item))
    );
    
    res.json({
        success: true,
        data: itemsWithBase64
    });
});

// Get items by search term
app.get('/api/items/search/:term', async (req, res) => {
    const searchTerm = req.params.term.toLowerCase();
    const itemsData = await readJsonFile(path.join(__dirname, 'assets/json/items.json'));
    
    if (!itemsData) {
        return res.status(500).json({
            success: false,
            error: 'Failed to read items data'
        });
    }

    const filteredItems = itemsData.items.filter(item => 
        item.name?.toLowerCase().includes(searchTerm) ||
        item.createdWith?.toLowerCase().includes(searchTerm)
    );
    
    // Convert all images to base64
    const itemsWithBase64 = await Promise.all(
        filteredItems.map(item => getItemWithBase64Image(item))
    );
    
    res.json({
        success: true,
        data: itemsWithBase64
    });
});

// Get all categories
app.get('/api/categories', async (req, res) => {
    const categoriesData = await readJsonFile(path.join(__dirname, 'assets/json/categories.json'));
    
    if (!categoriesData) {
        return res.status(500).json({
            success: false,
            error: 'Failed to read categories data'
        });
    }

    res.json({
        success: true,
        data: categoriesData.categories
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 

