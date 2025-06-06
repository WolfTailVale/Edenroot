// llm_discordWatcher.js (With File Logging)

require('dotenv').config();
const { Client, GatewayIntentBits, Partials } = require('discord.js');
const axios = require('axios');
const fs = require('fs'); // Already here, good!
const path = require('path');
const { spawn } = require('child_process');

// --- Log File Setup ---
const LOG_FILE_PATH = path.join(__dirname, 'eden_discord_interactions.log');

function logToFile(message) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] ${message}\n\n`; // Add extra newline for readability between entries
  fs.appendFile(LOG_FILE_PATH, logEntry, (err) => {
    if (err) {
      console.error('❌ Failed to write to log file:', err);
    }
  });
}
// Initial log entry for script start
logToFile("🚀 llm_discordWatcher.js script started.");

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
const LLM_MODEL = 'llama-2-13b-hf';

// --- Dart Prompt Server Configuration & Launch ---
const EDENROOT_PROJECT_ROOT = path.join(__dirname, '../../');
const DART_SCRIPT_RELATIVE_PATH = path.join('lib', 'discord', 'prompt_server.dart');
let promptServerProcess = null;

function startDartPromptServer() {
    logToFile('🚀 Attempting to start prompt_server.dart...');
    console.log('🚀 Attempting to start prompt_server.dart...');
    promptServerProcess = spawn('dart', ['run', DART_SCRIPT_RELATIVE_PATH], {
        cwd: EDENROOT_PROJECT_ROOT,
        stdio: 'inherit',
        shell: process.platform === 'win32'
    });

    promptServerProcess.on('spawn', () => {
        const spawnMsg = 'ℹ️ prompt_server.dart process spawned. It should be starting up...';
        console.log(spawnMsg);
        logToFile(spawnMsg);
    });

    promptServerProcess.on('error', (err) => {
        const errorMsg = `❌ Failed to start or run prompt_server.dart: ${err.message}`;
        console.error(errorMsg, err);
        logToFile(errorMsg);
    });

    promptServerProcess.on('close', (code) => {
        const closeMsg = `🔔 prompt_server.dart exited (code ${code}).`;
        console.log(closeMsg);
        logToFile(closeMsg);
        if (code !== 0 && code !== null) {
             console.error(`   You may need to restart it manually or check Dart server logs for errors.`);
             logToFile(`   Error: prompt_server.dart exited with error code ${code}.`);
        }
        promptServerProcess = null;
    });
}
startDartPromptServer();

// --- Discord Client Setup ---
const client = new Client({
  intents: [GatewayIntentBits.DirectMessages, GatewayIntentBits.MessageContent],
  partials: [Partials.Channel]
});

client.once('ready', () => {
  const readyMsg = `🟢 llm_discordWatcher.js connected as ${client.user.tag}`;
  console.log(readyMsg);
  logToFile(readyMsg);
});

client.on('error', err => {
    const errorMsg = `❌ Discord client error in llm_discordWatcher.js: ${err.message}`;
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
    });

    const systemPrompt = promptRes.data.prompt;
    if (!systemPrompt) {
      const noPromptErr = "❌ PromptServer returned empty or no prompt.";
      console.error(noPromptErr);
      logToFile(noPromptErr);
      throw new Error("PromptServer returned empty prompt.");
    }
    
    const receivedPromptShortMsg = `  💬 Received system prompt (length: ${systemPrompt.length}): ${systemPrompt.substring(0,100)}...`;
    console.log(receivedPromptShortMsg); // Keep console preview
    logToFile(receivedPromptShortMsg); // Log preview to file too

    // ✨ LOG FULL SYSTEM PROMPT TO FILE ✨
    logToFile(`  📋 FULL System Prompt for LLM (${systemPrompt.length} chars) for user ${message.author.username}:\n---START SYSTEM PROMPT---\n${systemPrompt}\n---END SYSTEM PROMPT---`);
    
    const sendingToLlmMsg = `  ➡️ Sending prompt to LLM at ${LLM_ENDPOINT} using model ${LLM_MODEL}`;
    console.log(sendingToLlmMsg);
    logToFile(sendingToLlmMsg);
    const llmRes = await axios.post(LLM_ENDPOINT, {
      model: LLM_MODEL, 
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userInput }
      ],
      temperature: 0.7, 
      max_tokens: 1024 // Increased max_tokens a bit, adjust if needed
    }, {
      headers: { "Content-Type": "application/json" }
    });

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
    logToFile(repliedMsg + (reply.length > 80 ? `\n     Full LLM Reply: ${reply}` : "")); // Log full reply if long

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
    await message.reply("Oh dear, something went a bit fuzzy trying to think that through. Could you try again in a moment?");
  }
});

client.login(DISCORD_TOKEN)
    .then(() => {
        const loginSuccessMsg = '✅ Discord Login successful.';
        console.log(loginSuccessMsg);
        logToFile(loginSuccessMsg);
    })
    .catch(err => {
        const loginFailMsg = `❌ Discord Login failed: ${err.message}`;
        console.error(loginFailMsg, err);
        logToFile(loginFailMsg + (err.stack ? `\nStack: ${err.stack}` : ""));
        if (promptServerProcess && !promptServerProcess.killed) {
            const stopDartMsg = 'Attempting to stop Dart server due to Discord login failure...';
            console.log(stopDartMsg);
            logToFile(stopDartMsg);
            promptServerProcess.kill();
        }
    });

// --- Graceful Shutdown Handling ---
function cleanupAndExit(signal = 'UNKNOWN') {
    const shutdownMsg = `\n🔌 Shutting down on signal: ${signal}...`;
    console.log(shutdownMsg);
    logToFile(shutdownMsg);
    if (promptServerProcess && !promptServerProcess.killed) {
        const stoppingDartMsg = '   Stopping prompt_server.dart...';
        console.log(stoppingDartMsg);
        logToFile(stoppingDartMsg);
        const killed = promptServerProcess.kill(); 
        const killedMsg = `   Dart server kill signal sent: ${killed}`;
        console.log(killedMsg);
        logToFile(killedMsg);
    }
    
    // Give child process a moment to exit, then force exit this script
    setTimeout(() => {
        const exitNodeMsg = '   Exiting Node.js script.';
        console.log(exitNodeMsg);
        logToFile(exitNodeMsg);
        process.exit(0);
    }, 1500); // Increased timeout slightly
}

process.on('SIGINT', () => cleanupAndExit('SIGINT')); 
process.on('SIGTERM', () => cleanupAndExit('SIGTERM'));