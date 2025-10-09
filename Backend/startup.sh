#!/bin/bash
echo "🎯 Starting Backend Initialization..."

# Wait for MongoDB
echo "⏳ Waiting for MongoDB..."
sleep 15

# Run initialization scripts
echo "🔧 Running initialization scripts..."
node scripts/createAdmin.js
node scripts/addEmployee.js
node check-employee.js

# Start the main server
echo "🚀 Starting Node.js server..."
npm start
