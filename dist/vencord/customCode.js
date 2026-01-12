
const muteActionFileName = 'mute';
const deafenActionFileName = 'deafen';

const muteButtonSelector = `
:is(
button.button__67645.enabled__67645.button__201d5.button__67645:has(g[clip-path="url(#__lottie_element_5)"]),
button:has(g[clip-path="url(#__lottie_element_5)"])
)
`;

const deafenButtonSelector = `
:is(
button.button__67645.enabled__67645.button__201d5.button__67645:has(g[clip-path="url(#__lottie_element_42)"]),
button:has(g[clip-path="url(#__lottie_element_42)"])
)
`;

const fs = require('fs');
const path = require('path');
const { BrowserWindow, app } = require('electron');

// === Unified Logger ===
const LOG_PREFIX = '[VesktopCustomCommands]';

// Queue for logs before window is ready
let pendingLogs = [];
let windowReady = false;

const sendLogToWindow = (win, level, escapedMessage) => {
    win.webContents.executeJavaScript(`console.${level}("${LOG_PREFIX}", "${escapedMessage}")`).catch(() => {});
};

const logToRenderer = (level, ...args) => {
    const message = args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' ');
    const escapedMessage = message.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n');

    if (!windowReady) {
        pendingLogs.push({ level, escapedMessage });
        return;
    }

    BrowserWindow.getAllWindows().forEach(win => {
        sendLogToWindow(win, level, escapedMessage);
    });
};

const flushPendingLogs = (win) => {
    pendingLogs.forEach(({ level, escapedMessage }) => {
        sendLogToWindow(win, level, escapedMessage);
    });
    pendingLogs = [];
};

// Wait for window to be ready before sending queued logs
app.on('browser-window-created', (event, win) => {
    win.webContents.on('did-finish-load', () => {
        if (!windowReady) {
            windowReady = true;
            flushPendingLogs(win);
        }
    });
});

const logger = {
    log: (...args) => { console.log(LOG_PREFIX, ...args); logToRenderer('log', ...args); },
    info: (...args) => { console.info(LOG_PREFIX, ...args); logToRenderer('info', ...args); },
    warn: (...args) => { console.warn(LOG_PREFIX, ...args); logToRenderer('warn', ...args); },
    error: (...args) => { console.error(LOG_PREFIX, ...args); logToRenderer('error', ...args); }
};

logger.info("Custom code executed from customCode.js");
logger.info("Made with ❤️ by NitramO");

// === Click in Renderer ===
const clickInRenderer = (selector) => {
    BrowserWindow.getAllWindows().forEach(win => {
        const escapedSelector = selector.replace(/`/g, '\\`').replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
        win.webContents.executeJavaScript(`
            (function() {
                const el = document.querySelector(\`${escapedSelector}\`);
                if (el) {
                    el.click();
                    console.log('${LOG_PREFIX}', 'Button clicked!');
                    return true;
                } else {
                    console.warn('${LOG_PREFIX}', 'Button not found');
                    return false;
                }
            })();
        `).then(result => {
            if (result) logger.log('Click successful');
        }).catch(() => {});
    });
};

// === File Monitor ===
const monitorFile = (filePath, action) => {
    const checkFile = () => {
        fs.stat(filePath, (err, stats) => {
            if (err) return; // File doesn't exist

            // Check if it's a file, not a directory
            if (!stats.isFile()) {
                logger.warn(`Ignored: ${filePath} is not a file (possibly a directory)`);
                return;
            }

            logger.log(`File found: ${filePath}`);
            fs.unlink(filePath, (unlinkErr) => {
                if (unlinkErr) {
                    logger.error(`Error deleting file ${filePath}:`, unlinkErr.message);
                    return;
                }
                logger.log(`Deleted file: ${filePath}`);
                action();
            });
        });
    };
    setInterval(checkFile, 350);
};

// === Define paths and actions ===
const muteFilePath = path.join(__dirname, muteActionFileName);
const deafenFilePath = path.join(__dirname, deafenActionFileName);

const muteAction = () => {
    logger.info('Action: Toggle mute triggered');
    clickInRenderer(muteButtonSelector);
};

const deafenAction = () => {
    logger.info('Action: Toggle deafen triggered');
    clickInRenderer(deafenButtonSelector);
};

// === Start monitoring ===
monitorFile(muteFilePath, muteAction);
monitorFile(deafenFilePath, deafenAction);

logger.info('Monitoring of mute and deafen files started.');
