const fs = require('fs');
const path = require('path');

console.log('=== VERIFYING WEBSITE LINKS AND RESOURCES ===');

const indexPath = path.join(__dirname, 'index.html');
if (!fs.existsSync(indexPath)) {
    console.error('ERROR: index.html not found!');
    process.exit(1);
}

const html = fs.readFileSync(indexPath, 'utf8');

// Find all src="..." and href="..."
const srcRegex = /(src|href)=["']([^"']+)["']/g;
let match;
const links = [];

while ((match = srcRegex.exec(html)) !== null) {
    const url = match[2];
    // We only care about local assets/files, not external CDNs or hashes
    if (!url.startsWith('http') && !url.startsWith('#') && !url.startsWith('mailto:')) {
        links.push(url);
    }
}

console.log(`Found ${links.length} local resource links in index.html.`);

let missingCount = 0;
links.forEach(link => {
    // Clean query parameters if any (like ?v=1)
    const cleanLink = link.split('?')[0];
    const fullPath = path.join(__dirname, cleanLink);
    
    if (fs.existsSync(fullPath)) {
        console.log(`[OK]   Found: ${link}`);
    } else {
        console.error(`[FAIL] MISSING: ${link} (resolved path: ${fullPath})`);
        missingCount++;
    }
});

if (missingCount === 0) {
    console.log('\n🌟 ALL LOCAL RESOURCE LINKS ARE RESOLVED SUCCESSFULLY! 🌟');
} else {
    console.error(`\n❌ FAILED: ${missingCount} resource links are missing!`);
}
