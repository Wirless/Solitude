const fs = require('fs');
const path = require('path');

// Use the current directory as the folder path
const folderPath = __dirname;

// Function to capitalize the first letter of each word
function capitalizeWords(str) {
  return str.replace(/\b\w/g, char => char.toUpperCase());
}

// Read all files in the folder
fs.readdir(folderPath, (err, files) => {
  if (err) {
    console.error('Error reading directory:', err);
    return;
  }

  files.forEach(file => {
    const oldPath = path.join(folderPath, file);
    
    // Skip directories and the script file itself
    if (fs.statSync(oldPath).isDirectory() || file === path.basename(__filename)) {
      return;
    }

    const extension = path.extname(file);
    const fileNameWithoutExt = path.basename(file, extension);
    const newFileName = capitalizeWords(fileNameWithoutExt) + extension;
    const newPath = path.join(folderPath, newFileName);

    // Rename the file
    fs.rename(oldPath, newPath, err => {
      if (err) {
        console.error(`Error renaming file ${file}:`, err);
      } else {
        console.log(`Renamed: ${file} -> ${newFileName}`);
      }
    });
  });
});
