const mongoose = require('mongoose');
const fs = require('fs');
require('dotenv').config();

const uri = process.env.MONGO_URI || 'mongodb+srv://opg7386_db_user:tmZTuN7LUxxYGgbP@cluster0.h8hfawa.mongodb.net/gram_setu?retryWrites=true&w=majority';

async function checkConnection() {
    let log = '';
    const logFile = 'db_log.txt';
    
    try {
        log += 'Connecting to MongoDB...\n';
        await mongoose.connect(uri);
        log += '✅ Connected successfully!\n';
        
        const db = mongoose.connection.db;
        const collections = await db.listCollections().toArray();
        
        log += '\n--- Database Stats ---\n';
        log += `Database Name: ${db.databaseName}\n`;
        log += `Collections Count: ${collections.length}\n`;
        
        if (collections.length > 0) {
            log += 'Collections:\n';
            for (const col of collections) {
                const count = await db.collection(col.name).countDocuments();
                log += ` - ${col.name}: ${count} documents\n`;
            }
        } else {
            log += '⚠️ No collections found. The database might be empty!\n';
        }
        
        await mongoose.disconnect();
        log += '\nDisconnected.\n';
    } catch (error) {
        log += '❌ Connection Error details:\n';
        log += error.stack || error.message || error;
    }
    
    fs.writeFileSync(logFile, log);
    console.log(`Log written to ${logFile}`);
}

checkConnection();
