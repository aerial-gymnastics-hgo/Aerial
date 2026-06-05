const fs = require('fs');
const path = require('path');

const file = 'c:/Users/jorge/.gemini/antigravity/Aerial-Gimnastics/lib/screens/caja_dashboard.dart';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(
  "pw.Center(child: pw.Text('AERIAL GYMNASTICS', style: pw.TextStyle(fontSize: 14))),",
  "pw.Center(child: pw.Text('GIMNASIA ARTÍSTICA', style: pw.TextStyle(fontSize: 14))),"
);

fs.writeFileSync(file, content, 'utf8');
console.log('Adjusted duplicate name to GIMNASIA ARTÍSTICA in caja_dashboard.dart');
