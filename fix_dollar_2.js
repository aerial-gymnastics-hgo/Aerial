const fs = require('fs');
const filePath = 'C:/Users/jorge/.gemini/antigravity/Aerial-Gimnastics/lib/screens/caja_dashboard.dart';
let content = fs.readFileSync(filePath, 'utf8');

// Replace the incorrect string with a raw Dart string
const target = "'+\\$\\' + payment.amount.toStringAsFixed(0)";
const replacement = "r'+$' + payment.amount.toStringAsFixed(0)";

if (content.includes(target)) {
  content = content.replace(target, replacement);
  fs.writeFileSync(filePath, content, 'utf8');
  console.log("Fixed string syntax to raw string successfully.");
} else {
  console.error("Could not find the target to fix.");
}
