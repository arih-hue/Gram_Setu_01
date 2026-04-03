const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const uri = process.env.MONGO_URI || 'mongodb+srv://opg7386_db_user:tmZTuN7LUxxYGgbP@cluster0.h8hfawa.mongodb.net/gram_setu?retryWrites=true&w=majority';
        const conn = await mongoose.connect(uri);
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    } catch (error) {
        console.error(`❌ Error connecting to MongoDB: ${error.message}`);
        console.log('\n--- Troubleshooting MongoDB Atlas Connection ---');
        console.log('1. Check if your current IP is whitelisted in Atlas (0.0.0.0/0 is recommended for testing).');
        console.log('2. Check if your network blocks outbound connection on port 27017 (Common in university/office Wi-Fi).');
        console.log('3. Solution: Use a mobile hotspot or a VPN.');
        console.log('4. Ensure your MONGO_URI in .env is correct and has no extra spaces.\n');
        process.exit(1);
    }
};

module.exports = connectDB;
