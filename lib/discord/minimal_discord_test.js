// minimal_discord_test.js
require('dotenv').config();
const { Client, GatewayIntentBits, Partials } = require('discord.js');
const DISCORD_TOKEN = process.env.EDEN_BOT_TOKEN;

if (!DISCORD_TOKEN) {
    console.error("❌ Missing Discord token. Set EDEN_BOT_TOKEN in .env");
    process.exit(1);
}

const client = new Client({
    intents: [
        GatewayIntentBits.DirectMessages, 
        GatewayIntentBits.MessageContent 
        // Add GatewayIntentBits.Guilds and GatewayIntentBits.GuildMessages if you expect it to work in servers too
    ],
    partials: [Partials.Channel]
});

client.once('ready', () => {
    console.log(`🟢 Minimal bot connected as ${client.user.tag}`);
    client.destroy(); // Optional: close connection after successful test
});

client.on('error', err => {
    console.error('❌ Discord client error:', err);
});

client.login(DISCORD_TOKEN)
    .then(() => {
        console.log('✅ Login successful with minimal script.');
    })
    .catch(err => {
        console.error('❌ Login failed with minimal script:', err);
    });