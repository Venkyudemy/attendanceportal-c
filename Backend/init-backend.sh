#!/bin/bash
echo "🔧 Running backend initialization..."

# Wait for MongoDB
echo "⏳ Waiting for MongoDB..."
sleep 10

# Run initialization scripts
echo "🏃 Running initialization scripts..."
node scripts/createAdmin.js
node scripts/addEmployee.js
node check-employee.js

echo "✅ Initialization complete!"
