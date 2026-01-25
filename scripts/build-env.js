#!/usr/bin/env node
/**
 * Build script to generate env-config.js from environment variables
 * This script reads from process.env and generates the config file
 * Used by Vercel during build time
 */

const fs = require('fs');
const path = require('path');

// Get environment variables (Vercel will provide these)
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || 'https://qqbyxydxxcuklakvjlfr.supabase.co';
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFxYnl4eWR4eGN1a2xha3ZqbGZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkwMjg2MTYsImV4cCI6MjA4NDYwNDYxNn0.2I-uy7ghGa6Ou7uuzDfpYbd75qrNivlBEQBthilYHxw';

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

console.log('✅ Generated env-config.js from environment variables');
console.log(`   SUPABASE_URL: ${SUPABASE_URL.substring(0, 30)}...`);
console.log(`   SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY.substring(0, 20)}...`);
