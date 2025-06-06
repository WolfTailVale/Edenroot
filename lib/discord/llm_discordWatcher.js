// llm_discordWatcher.js (Standalone - No Dart Management)

require('dotenv').config();
const { Client, GatewayIntentBits, Partials } = require('discord.js');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

// --- Log File Setup ---
const LOG_FILE_PATH = path.join(__dirname, 'eden_discord_interactions.log');

function logToFile(message) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] ${message}\n\n`;
  fs.appendFile(LOG_FILE_PATH, logEntry, (err) => {
    if (err) {
      console.error('❌ Failed to write to log file:', err);
    }
  });
}

logToFile("🚀 llm_discordWatcher.js script started (standalone mode).");

// --- Configuration ---
const userConfigPath = path.join(__dirname, './edenBridgeUsers.json');
let knownUsers = [];
try {
    knownUsers = JSON.parse(fs.readFileSync(userConfigPath, 'utf-8'));
    logToFile(`✅ Loaded ${knownUsers.length} known users from ${userConfigPath}`);
} catch (err) {
    console.error(`❌ Error loading or parsing edenBridgeUsers.json from ${userConfigPath}:`, err);
    logToFile(`❌ Error loading or parsing edenBridgeUsers.json from ${userConfigPath}: ${err.message}`);
    process.exit(1);
}

const DISCORD_TOKEN = process.env.EDEN_BOT_TOKEN;
if (!DISCORD_TOKEN) {
  console.error("❌ Missing Discord token. Set EDEN_BOT_TOKEN in .env");
  logToFile("❌ Missing Discord token. EDEN_BOT_TOKEN not found in .env.");
  process.exit(1);
}

const LLM_ENDPOINT = 'http://localhost:1234/v1/chat/completions';
const PROMPT_SERVER_URL = 'http://localhost:4242/generate-prompt';
const LLM_MODEL = 'mistral-7b-instruct-v0.3';

// --- Discord Client Setup ---
const client = new Client({
  intents: [GatewayIntentBits.DirectMessages, GatewayIntentBits.MessageContent],
  partials: [Partials.Channel]
});

client.once('ready', () => {
  const readyMsg = `🟢 Discord bridge connected as ${client.user.tag} (standalone mode)`;
  console.log(readyMsg);
  logToFile(readyMsg);
  
  // Check if Dart server is running
  checkDartServerConnection();
});

async function checkDartServerConnection() {
  let attempts = 0;
  const maxAttempts = 10;
  
  while (attempts < maxAttempts) {
    try {
      const response = await axios.get('http://localhost:4242/status', { timeout: 3000 });
      const statusMsg = '✅ Eden\'s brain server is responding';
      console.log(statusMsg);
      logToFile(statusMsg);
      return;
    } catch (err) {
      attempts++;
      if (attempts >= maxAttempts) {
        const errorMsg = '❌ Cannot connect to Eden\'s brain server at localhost:4242. Please start prompt_server.dart first.';
        console.error(errorMsg);
        logToFile(errorMsg);
        console.log('Discord bridge will continue running and retry connections as needed.');
        logToFile('Discord bridge will continue running and retry connections as needed.');
        return;
      }
      
      // Wait a bit before retrying
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }
}

client.on('error', err => {
    const errorMsg = `❌ Discord client error: ${err.message}`;
    console.error(errorMsg, err);
    logToFile(errorMsg);
});

client.on('messageCreate', async (message) => {
  if (message.author.bot || message.channel.type !== 1) return;

  const userId = message.author.id;
  if (!knownUsers.some(u => u.id === userId && u.enabled)) {
    const ignoreMsg = `🔒 DM ignored from unknown or disabled user: ${message.author.tag} (${userId})`;
    console.log(ignoreMsg);
    logToFile(ignoreMsg);
    return;
  }

  const userInput = message.content.trim();
  if (!userInput) return;

  const incomingMsgLog = `📩 Message from ${message.author.tag} (${message.author.username}): ${userInput}`;
  console.log(incomingMsgLog);
  logToFile(incomingMsgLog);

  try {
    await message.channel.sendTyping();

    const promptRequestMsg = `  ➡️ Requesting system prompt from ${PROMPT_SERVER_URL} for user ${message.author.username}`;
    console.log(promptRequestMsg);
    logToFile(promptRequestMsg);
    
    const promptRes = await axios.post(PROMPT_SERVER_URL, {
      user: message.author.username, 
      message: userInput
    }, { timeout: 30000 });

    const systemPrompt = promptRes.data.prompt;
    if (!systemPrompt) {
      const noPromptErr = "❌ Eden's brain returned empty or no prompt.";
      console.error(noPromptErr);
      logToFile(noPromptErr);
      await message.reply("I wanted to think about that... but my thoughts feel scattered. Could you try again?");
      return;
    }
    
    const receivedPromptShortMsg = `  💬 Received system prompt (length: ${systemPrompt.length}): ${systemPrompt.substring(0,100)}...`;
    console.log(receivedPromptShortMsg);
    logToFile(receivedPromptShortMsg);

    logToFile(`  📋 FULL System Prompt for LLM (${systemPrompt.length} chars) for user ${message.author.username}:\n---START SYSTEM PROMPT---\n${systemPrompt}\n---END SYSTEM PROMPT---`);
    
    const sendingToLlmMsg = `  ➡️ Sending prompt to LLM at ${LLM_ENDPOINT} using model ${LLM_MODEL}`;
    console.log(sendingToLlmMsg);
    logToFile(sendingToLlmMsg);
    
    const llmRes = await axios.post(LLM_ENDPOINT, {
      model: LLM_MODEL, 
      messages: [
        { role: "user", content: systemPrompt + "\n\nUser: " + userInput }
      ],
      temperature: 0.7, 
      max_tokens: 1024
    }, { timeout: 45000 });

    const reply = llmRes.data?.choices?.[0]?.message?.content?.trim();
    if (!reply) {
      const noReplyMsg = "🤷 LLM returned no message content.";
      console.warn(noReplyMsg);
      logToFile(noReplyMsg);
      await message.reply("I wanted to say something… but it slipped away from me. Try again perhaps?");
      return;
    }

    await message.reply(reply);
    const repliedMsg = `  📤 Replied to ${message.author.tag}: ${reply.slice(0, 80)}...`;
    console.log(repliedMsg);
    logToFile(repliedMsg + (reply.length > 80 ? `\n     Full LLM Reply: ${reply}` : ""));

  } catch (err) {
    const errorHandlingMsg = `💥 Error handling DM from ${message.author.tag}: ${err.message}`;
    console.error(errorHandlingMsg, err);
    logToFile(errorHandlingMsg + (err.stack ? `\nStack: ${err.stack}` : ""));
    
    if (err.response) { 
        const axiosErrData = `  Axios error data: ${JSON.stringify(err.response.data)}`;
        const axiosErrStatus = `  Axios error status: ${err.response.status}`;
        console.error(axiosErrData);
        console.error(axiosErrStatus);
        logToFile(axiosErrData);
        logToFile(axiosErrStatus);
    }
    
    if (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND') {
      await message.reply("I can't reach my thoughts right now... is my brain server running? 🥺");
    } else {
      await message.reply("Oh dear, something went a bit fuzzy trying to think that through. Could you try again in a moment?");
    }
  }
});

client.login(DISCORD_TOKEN)
    .then(() => {
        const loginSuccessMsg = '✅ Discord Login successful (standalone mode).';
        console.log(loginSuccessMsg);
        logToFile(loginSuccessMsg);
    })
    .catch(err => {
        const loginFailMsg = `❌ Discord Login failed: ${err.message}`;
        console.error(loginFailMsg, err);
        logToFile(loginFailMsg + (err.stack ? `\nStack: ${err.stack}` : ""));
        process.exit(1);
    });

// --- Graceful Shutdown Handling ---
function cleanupAndExit(signal = 'UNKNOWN') {
    const shutdownMsg = `\n🔌 Discord bridge shutting down on signal: ${signal}...`;
    console.log(shutdownMsg);
    logToFile(shutdownMsg);
    
    client.destroy();
    
    setTimeout(() => {
        const exitMsg = '   Discord bridge exited.';
        console.log(exitMsg);
        logToFile(exitMsg);
        process.exit(0);
    }, 1000);
}

process.on('SIGINT', () => cleanupAndExit('SIGINT')); 
process.on('SIGTERM', () => cleanupAndExit('SIGTERM'));