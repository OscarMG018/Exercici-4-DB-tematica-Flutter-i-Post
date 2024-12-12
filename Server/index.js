const express = require('express');
const cors = require('cors');
const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Local data
const items = [
    {
        id: '1',
        image: 'assets/images/terra_blade.png',
        name: 'Terra Blade',
        description: 'A powerful sword forged from the essence of light and night. Shoots sword beams at full health.',
        damage: 95,
        autoAttack: true,
        knockback: 6,
        critChance: 4,
        useTime: 20,
        buyPrice: 20000,
        sellPrice: 10000,
        createdWith: 'True Night\'s Edge + True Excalibur',
        updatedAt: '2023-05-15',
        category: 'Swords'
    },
    {
        id: '2',
        image: 'assets/images/megashark.png',
        name: 'Megashark',
        description: 'A high-speed gun that turns bullets into a deadly rain. Very low knockback but extremely fast.',
        damage: 50,
        autoAttack: true,
        knockback: 1,
        critChance: 4,
        useTime: 7,
        buyPrice: 35000,
        sellPrice: 17500,
        createdWith: 'Minishark + Illegal Gun Parts + Souls of Might',
        updatedAt: '2023-05-15',
        category: 'Guns'
    },
    {
        id: '3',
        image: 'assets/images/last_prism.png',
        name: 'Last Prism',
        description: 'Channels a devastating prismatic beam of light that grows in power. Consumes mana rapidly.',
        damage: 110,
        autoAttack: false,
        knockback: 2,
        critChance: 4,
        useTime: 10,
        buyPrice: 450000,
        sellPrice: 225000,
        createdWith: 'Lunar Fragments + Luminite Bars',
        updatedAt: '2023-05-15',
        category: 'Magic'
    },
    {
        id: '4',
        image: 'assets/images/stardust_dragon.png',
        name: 'Stardust Dragon Staff',
        description: 'Summons a celestial dragon that grows longer with each segment. Follows enemies and attacks automatically.',
        damage: 90,
        autoAttack: true,
        knockback: 3,
        critChance: 4,
        useTime: 30,
        buyPrice: 400000,
        sellPrice: 200000,
        createdWith: 'Stardust Fragments + Luminite Bars',
        updatedAt: '2023-05-15',
        category: 'Summon'
    }
];

const categories = ['Swords', 'Guns', 'Magic', 'Summon'];

// Get items by category
app.get('/api/items/category/:category', (req, res) => {
    const category = req.params.category;
    const filteredItems = items.filter(item => 
        item.category === category
    );
    
    res.json({
        success: true,
        data: filteredItems
    });
});

// Get items by search term
app.get('/api/items/search/:term', (req, res) => {
    const searchTerm = req.params.term.toLowerCase();
    const filteredItems = items.filter(item => 
        item.name.toLowerCase().includes(searchTerm) ||
        item.createdWith.toLowerCase().includes(searchTerm)
    );
    
    res.json({
        success: true,
        data: filteredItems
    });
});

// Get all categories
app.get('/api/categories', (req, res) => {
    res.json({
        success: true,
        data: categories
    });
});

app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
}); 