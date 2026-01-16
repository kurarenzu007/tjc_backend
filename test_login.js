// Test script to verify login logic
const bcrypt = require('bcryptjs');

async function testLogin() {
  try {
    // Test password comparison logic
    const testPassword = 'admin'; // or whatever the actual password should be
    const testHash = await bcrypt.hash(testPassword, 10);
    console.log('Test hash:', testHash);
    
    const isValid = await bcrypt.compare(testPassword, testHash);
    console.log('Password comparison result:', isValid);
    
    // Test with different variations
    const comparisons = [
      'admin',
      'password',
      '123456',
      'admin123'
    ];
    
    for (const pwd of comparisons) {
      const result = await bcrypt.compare(pwd, testHash);
      console.log(`'${pwd}' matches:`, result);
    }
    
  } catch (error) {
    console.error('Test error:', error);
  }
}

testLogin();
