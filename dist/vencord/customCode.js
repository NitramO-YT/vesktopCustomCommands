
const muteActionFileName = 'mute';
const deafenActionFileName = 'deafen';

//button_adca65 enabled_adca65 button_dd4f85 lookBlank_dd4f85 colorBrand_dd4f85 grow_dd4f85 button_adca65 :has <g clip-path="url(#__lottie_element_5)"></g>
const muteButtonSelector = `button.button_adca65.button_dd4f85.button_adca65:has(g[clip-path="url(#__lottie_element_5)"])`;

//button_adca65 enabled_adca65 button_dd4f85 lookBlank_dd4f85 colorBrand_dd4f85 grow_dd4f85 button_adca65 :has <g clip-path="url(#__lottie_element_42)"></g>
const deafenButtonSelector = `button.button_adca65.button_dd4f85.button_adca65:has(g[clip-path="url(#__lottie_element_42)"])`;



const awaitForElement = (selector, callback, options = {}) => {
    if (!selector) {
        throw new Error('awaitForElement: selector is required');
    }
    if (!callback) {
        throw new Error('awaitForElement: callback is required');
    }
    if (typeof callback !== 'function') {
        throw new Error('awaitForElement: callback must be a function');
    }
    if (typeof options !== 'object') {
        throw new Error('awaitForElement: options must be an object');
    }
    if (options.timeout !== undefined && typeof options.timeout !== 'number') {
        throw new Error('awaitForElement: options.timeout must be a number');
    }
    if (options.interval !== undefined && typeof options.interval !== 'number') {
        throw new Error('awaitForElement: options.interval must be a number');
    }
    if (options.timeout !== undefined && options.timeout < 0) {
        throw new Error('awaitForElement: options.timeout must be a positive number');
    }
    if (options.interval !== undefined && options.interval < 0) {
        throw new Error('awaitForElement: options.interval must be a positive number');
    }
    if (options.timeout && options.interval && options.timeout < options.interval) {
        throw new Error('awaitForElement: options.timeout must be greater than options.interval');
    }

    const timeout = options.timeout || 5000; // Default timeout: 5000ms
    const interval = options.interval || 100; // Default interval: 100ms

    let elapsedTime = 0;

    const checkElement = () => {
        const element = document.querySelector(selector);
        if (element) {
            callback(element);
        } else if (elapsedTime < timeout) {
            elapsedTime += interval;
            setTimeout(checkElement, interval);
        } else {
            console.error(`awaitForElement: Timeout reached while waiting for selector: ${selector}`);
        }
    };

    checkElement();
};

const getElement = (selector, options = {}) => {
    if (!selector) {
        throw new Error('getElement: selector is required');
    }
    if (typeof options !== 'object') {
        throw new Error('getElement: options must be an object');
    }
    if (options.timeout !== undefined && typeof options.timeout !== 'number') {
        throw new Error('getElement: options.timeout must be a number');
    }
    if (options.interval !== undefined && typeof options.interval !== 'number') {
        throw new Error('getElement: options.interval must be a number');
    }
    if (options.timeout !== undefined && options.timeout < 0) {
        throw new Error('getElement: options.timeout must be a positive number');
    }
    if (options.interval !== undefined && options.interval < 0) {
        throw new Error('getElement: options.interval must be a positive number');
    }
    if (options.timeout && options.interval && options.timeout < options.interval) {
        throw new Error('getElement: options.timeout must be greater than options.interval');
    }

    return new Promise((resolve, reject) => {
        const timeout = options.timeout || 5000; // Default timeout: 5000ms
        const interval = options.interval || 100; // Default interval: 100ms

        let elapsedTime = 0;

        const checkElement = () => {
            const element = document.querySelector(selector);
            if (element) {
                resolve(element);
            } else if (elapsedTime < timeout) {
                elapsedTime += interval;
                setTimeout(checkElement, interval);
            } else {
                reject(new Error(`getElement: Timeout reached while waiting for selector: ${selector}`));
            }
        };

        checkElement();
    });
};





console.info("Custom code executed from customCode.js");
console.info("Made with ❤️ by NitramO");



const fs = require('fs');
const path = require('path');

// Function to monitor and execute an action if the file exists
const monitorFile = (filePath, action) => {
    const checkFile = () => {
        fs.access(filePath, fs.constants.F_OK, (err) => {
            if (!err) {
                console.log(`File found: ${filePath}`);
                
                // Delete the file
                fs.unlink(filePath, (err) => {
                    if (err) {
                        console.error(`Error while deleting file ${filePath}:`, err);
                        return;
                    }
                    console.log(`Deleted file: ${filePath}`);
                    
                    // Execute the action
                    action();
                    // console.info(`Action executed for file: ${filePath}`);
                });
            }
        });
    };

    // Check the file regularly
    setInterval(checkFile, 350);
};

// Define the mute and deafen file paths
const muteFilePath = path.join(__dirname, muteActionFileName);
const deafenFilePath = path.join(__dirname, deafenActionFileName);

// Actions to toggle mute
const muteAction = () => {
    console.info('Action : Toggle mute triggered');
    getElement(muteButtonSelector).then((element) => {
        element.click();
    }).catch((error) => {
        console.error('Error while searching for the mute button:', error.message);
    });
};

// Actions to toggle deafen
const deafenAction = () => {
    console.info('Action : Toggle deafen triggered');
    getElement(deafenButtonSelector).then((element) => {
        element.click();
    }).catch((error) => {
        console.error('Error while searching for the deafen button:', error.message);
    });
};

// Monitor the mute and deafen files
monitorFile(muteFilePath, muteAction);
monitorFile(deafenFilePath, deafenAction);

console.info('Monitoring of mute and deafen files started.');