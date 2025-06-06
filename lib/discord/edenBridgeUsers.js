// A:\Standalone\scheduler-companion\edenBridgeUsers.js

const path = require("path");
const fs = require("fs");
const userConfigPath = path.join(__dirname, "config/edenBridgeUsers.json"); //

let userList = [];
try {
  const data = fs.readFileSync(userConfigPath, "utf-8");
  userList = JSON.parse(data); //
  // ++ NEW LOGGING ++
  console.log("Loaded userList from edenBridgeUsers.json:", JSON.stringify(userList, null, 2));
  // ++ END NEW LOGGING ++
  if (!Array.isArray(userList)) { //
    throw new Error("edenBridgeUsers.json is not an array"); //
  }
} catch (error) {
  console.error("❌ Failed to load edenBridgeUsers.json:", error); //
  userList = []; //
}

function getNameFromDiscordId(id) {
  const user = userList.find(u => u.id === id);
  return user?.name || null; //
}

function getIdFromName(name) {
  const user = userList.find(u => u.name.toLowerCase() === name.toLowerCase());
  return user?.id || null; //
}

// ++ NEW FUNCTION ++
function getUserByName(name) {
  if (!name) return null;
  return userList.find(u => u.name.toLowerCase() === name.toLowerCase()) || null;
}
// ++ END NEW FUNCTION ++

function getAllActiveUsers() {
  return userList.filter(u => u.enabled !== false); //
}
function updateLastSeen(name) {
  const userConfigPath = path.join(__dirname, "config/edenBridgeUsers.json");
  try {
    const raw = JSON.parse(fs.readFileSync(userConfigPath, "utf-8")); //
    const updated = raw.map(user =>
      user.name.toLowerCase() === name.toLowerCase()
        ? { ...user, lastSeen: new Date().toISOString() }
        : user
    ); //
    fs.writeFileSync(userConfigPath, JSON.stringify(updated, null, 2), "utf-8"); //
    console.log(`📌 Updated lastSeen for ${name}`); //
  } catch (err) {
    console.error("❌ Failed to update lastSeen:", err.message); //
  }
}

module.exports = {
  getNameFromDiscordId,
  getIdFromName,
  getUserByName, // ++ EXPORT NEW FUNCTION ++
  getAllActiveUsers,
  updateLastSeen
};