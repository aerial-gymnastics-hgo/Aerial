const fs = require('fs');
const filePath = 'C:/Users/jorge/.gemini/antigravity/Aerial-Gimnastics/lib/screens/caja_dashboard.dart';
let content = fs.readFileSync(filePath, 'utf8');

// Replace the string concatenation with escaped dollar sign
const target = "'+$' + payment.amount.toStringAsFixed(0)";
const replacement = "'+\\$\\' + payment.amount.toStringAsFixed(0)";

if (content.includes(target)) {
  content = content.replace(target, replacement);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log("Fixed dollar sign syntax error successfully.");
} else {
  console.error("Could not find the target concatenation to fix.");
}
