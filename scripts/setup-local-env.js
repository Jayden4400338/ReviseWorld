#!/usr/bin/env node
/**
 * Local development script to generate env-config.js from .env.local
 * Run this script when setting up local development
 * Usage: node scripts/setup-local-env.js
 */

const fs = require('fs');
const path = require('path');

// Try to read .env.local
const envLocalPath = path.join(__dirname, '..', '.env.local');
let SUPABASE_URL = 'https://qqbyxydxxcuklakvjlfr.supabase.co';
let SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYnl4eWR4eGN1a2xha3ZqbGZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMjg2MTYsImV4cCI6MjA4NDYwNDYxNn0.2I-uy7ghGa6Ou7uuzDfpYbd75qrNivlBEQBthilYHxw';

if (fs.existsSync(envLocalPath)) {
  const envContent = fs.readFileSync(envLocalPath, 'utf8');
  const lines = envContent.split('\n');
  
  lines.forEach(line => {
    const trimmed = line.trim();
    if (trimmed && !trimmed.startsWith('#')) {
      const [key, ...valueParts] = trimmed.split('=');
      const value = valueParts.join('=').trim().replace(/^["']|["']$/g, '');
      
      if (key === 'SUPABASE_URL' || key === 'NEXT_PUBLIC_SUPABASE_URL') {
        SUPABASE_URL = value;
      } else if (key === 'SUPABASE_ANON_KEY' || key === 'NEXT_PUBLIC_SUPABASE_ANON_KEY') {
        SUPABASE_ANON_KEY = value;
      }
    }
  });
  
  console.log('📖 Read environment variables from .env.local');
} else {
  console.log('⚠️  .env.local not found. Using default values.');
  console.log('   Create .env.local with:');
  console.log('   SUPABASE_URL=your-url-here');
  console.log('   SUPABASE_ANON_KEY=your-key-here');
}

// Generate the env-config.js content
const envConfigContent = `// Environment Configuration
// This file is auto-generated from environment variables
// DO NOT EDIT MANUALLY - it will be overwritten during build

window.__ENV__ = window.__ENV__ || {
  SUPABASE_URL: '${SUPABASE_URL}',
  SUPABASE_ANON_KEY: '${SUPABASE_ANON_KEY}'
};
`;

// Write to assets/js/env-config.js
const outputPath = path.join(__dirname, '..', 'assets', 'js', 'env-config.js');
fs.writeFileSync(outputPath, envConfigContent, 'utf8');

console.log('✅ Generated env-config.js for local development');
console.log(`   SUPABASE_URL: ${SUPABASE_URL.substring(0, 30)}...`);
console.log(`   SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY.substring(0, 20)}...`);
