const mongoose = require('mongoose');
require('dotenv').config();

const uri = process.env.MONGO_URI || 'mongodb+srv://opg7386_db_user:tmZTuN7LUxxYGgbP@cluster0.h8hfawa.mongodb.net/gram_setu?retryWrites=true&w=majority';

async function checkConnection() {
    try {
        console.log('Connecting to MongoDB...');
        await mongoose.connect(uri);
        console.log('✅ Connected successfully!');
        
        const db = mongoose.connection.db;
        const collections = await db.listCollections().toArray();
        
        console.log('\n--- Database Stats ---');
        console.log(`Database Name: ${db.databaseName}`);
        console.log(`Collections Count: ${collections.length}`);
        
        if (collections.length > 0) {
            console.log('Collections:');
            for (const col of collections) {
                const count = await db.collection(col.name).countDocuments();
                console.log(` - ${col.name}: ${count} documents`);
            }
        } else {
            console.log('⚠️ No collections found. The database might be empty!');
        }
        
        await mongoose.disconnect();
        console.log('\nDisconnected.');
    } catch (error) {
        console.error('❌ Connection Error details:');
        console.error(error);
        process.exit(1);
    }
}

checkConnection();
