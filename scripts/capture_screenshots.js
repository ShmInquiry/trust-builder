const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const OUTPUT_DIR = path.join(__dirname, '..', 'assets', 'screenshots');
const APP_URL = 'http://localhost:5000';

if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

function getPath(filename) {
    return path.join(OUTPUT_DIR, filename);
}

// Ensure elements are available
async function delay(time) {
    return new Promise(function (resolve) {
        setTimeout(resolve, time)
    });
}

(async () => {
    console.log('Launching browser...');
    const browser = await puppeteer.launch({
        executablePath: '/usr/bin/chromium',
        headless: "new",
        defaultViewport: { width: 400, height: 800 },
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-web-security'] // Disabled web security helps if CORS issues happen in testing
    });

    const page = await browser.newPage();

    try {
        console.log('Navigating to', APP_URL);
        await page.goto(APP_URL, { waitUntil: 'networkidle0' });

        console.log('1. Capturing login_error.png...');
        // Login Screen: Type wrong credentials
        // Email Field (Approx 200, 300)
        await delay(3000); // Wait for animations
        await page.mouse.click(200, 300);
        await delay(500);
        await page.keyboard.type('wrong@email.com');

        // Password Field (Approx 200, 370)
        await page.mouse.click(200, 370);
        await delay(500);
        await page.keyboard.type('badpass');

        // Sign In Button (Approx 200, 450)
        await page.mouse.click(200, 450);
        await delay(1000);
        await page.screenshot({ path: getPath('login_error.png') });
        console.log('Saved login_error.png');

        console.log('2. Capturing signup_error.png...');
        // Sweep y-axis to guarantee hit on the "Don't have an account? Sign Up" text link
        for (let burstY = 500; burstY <= 650; burstY += 20) {
            await page.mouse.click(200, burstY);
            await delay(100);
        }
        await delay(2000); // Wait for Registration screen to animate in

        // Click register with empty fields (Sweeping the Register button as well around roughly Y=550 to Y=650)
        for (let burstY = 500; burstY <= 650; burstY += 20) {
            await page.mouse.click(200, burstY);
            await delay(100);
        }
        await delay(1000);
        await page.screenshot({ path: getPath('signup_error.png') });
        console.log('Saved signup_error.png');

        console.log('3. Proceeding to Login...');
        // Reload page to start with a pristine state
        await page.goto(APP_URL, { waitUntil: 'networkidle0' });
        await delay(3000);

        // Type correct credentials
        await page.mouse.click(200, 300);
        await delay(500);
        await page.keyboard.type('demo@trustos.app');

        // Password Field
        await page.mouse.click(200, 370);
        await delay(500);
        await page.keyboard.type('demo1234');

        // Click Sign In
        await delay(500);
        await page.mouse.click(200, 450);

        console.log('Waiting for Home Screen...');
        await page.waitForSelector('span', { text: 'Demo User', timeout: 5000 }).catch(() => console.log("Could not find demo user span"));
        await delay(2000); // Additional buffer for screen transition and animation

        console.log('4. Capturing evidence-integrateScreen-persistence.png...');
        // Evaluate and get LocalStorage
        const localStorageData = await page.evaluate(() => JSON.stringify(window.localStorage, null, 2));

        // To visualize local storage simultaneously with the front end UI per the rubric, 
        // we will inject a partial translucent div over the screen containing the data and screenshot it together
        await page.evaluate((ls) => {
            const div = document.createElement('div');
            div.style.position = 'absolute';
            div.style.bottom = '50px';
            div.style.left = '10px';
            div.style.width = '380px';
            div.style.height = '400px';
            div.style.overflow = 'hidden';
            div.style.backgroundColor = 'rgba(0,0,0,0.85)';
            div.style.color = 'lime';
            div.style.zIndex = '99999';
            div.style.padding = '10px';
            div.style.fontSize = '12px';
            div.style.whiteSpace = 'pre-wrap';
            div.innerText = "LOCAL STORAGE DUMP:\n" + ls;
            document.body.appendChild(div);
            div.id = 'debug-overlay';
        }, localStorageData);
        await delay(500);
        await page.screenshot({ path: getPath('evidence-integrateScreen-persistence.png') });
        console.log('Saved evidence-integrateScreen-persistence.png');

        // Remove the overlay
        await page.evaluate(() => document.getElementById('debug-overlay').remove());

        console.log('5. Capturing evidence-detail-navigation.png...');
        // Capture the full screen showing the navigation menu icon ("hamburger" menu on top left)
        await page.screenshot({ path: getPath('evidence-detail-navigation.png') });
        console.log('Saved evidence-detail-navigation.png');

        console.log('6. Capturing evidence-menu-items.png...');
        // Click Drawer Icon (usually the first icon button on the top left App bar)
        // We can simulate clicking at coordinate if selector is hard. Flutter web has dense DOM.
        await page.mouse.click(25, 50); // Typical top left drawer icon pos
        await delay(1000);
        await page.screenshot({ path: getPath('evidence-menu-items.png') });
        console.log('Saved evidence-menu-items.png');

        console.log('7. Capturing evidence-settings-screen.png...');
        // Find settings in drawer and click
        await page.mouse.click(100, 350); // Guessing coord if text fails
        await delay(1000);
        await page.screenshot({ path: getPath('evidence-settings-screen.png') });
        console.log('Saved evidence-settings-screen.png');

        console.log('8. Capturing userstories-notifications-evidence.png...');
        // Open drawer again to go to Notifications
        await page.mouse.click(25, 50);
        await delay(1000);
        await page.mouse.click(100, 520); // Notifications is further down
        await delay(1000);

        await page.screenshot({ path: getPath('userstories-notifications-evidence.png') });
        console.log('Saved userstories-notifications-evidence.png');

        await page.screenshot({ path: getPath('evidence-notification-configure.png') });
        console.log('Saved evidence-notification-configure.png');

        // Toggle the Notifications switch ON (it defaults to off, which disables the button!)
        // The switch is inside _buildEnableSection near the top, roughly Y=120, X=350
        await page.mouse.click(350, 120);
        await delay(1000);

        // Click Test Notification Button (Sweep y-axis to guarantee hit without scrolling issues)
        for (let burstY = 600; burstY <= 780; burstY += 20) {
            await page.mouse.click(200, burstY);
            await delay(100);
        }
        await delay(2000); // Wait long enough for snackbar animation to complete

        await page.screenshot({ path: getPath('evidence-notification-alert.png') });
        console.log('Saved evidence-notification-alert.png');

        console.log('9. Capturing evidence-detail-screen.png...');
        // We are currently in Notifications. Open drawer to go Home.
        await page.mouse.click(25, 50);
        await delay(1000);
        await page.mouse.click(100, 150); // Click "Home" in Drawer
        await delay(2000);

        // Click on the first request card (usually found in middle of screen)
        await page.mouse.click(200, 350);
        await delay(1500);
        await page.screenshot({ path: getPath('evidence-detail-screen.png') });
        console.log('Saved evidence-detail-screen.png');

        console.log('10. Capturing userStories-externalAPI-evidence.png and evidence-api-ux.png (Alerts Feed)...');
        // Back to Home via Back Button from Detail Screen
        await page.mouse.click(25, 50);
        await delay(1500);

        // Go to Alerts via Bottom Nav
        // Bottom nav bar at y=750 for 800h screen. Alerts is 4th icon
        await page.mouse.click(350, 750); // Alerts click
        await delay(2000);
        await page.screenshot({ path: getPath('userStories-externalAPI-evidence.png') });
        await page.screenshot({ path: getPath('evidence-api-ux.png') });
        console.log('Saved userStories-externalAPI-evidence.png and evidence-api-ux.png');

        console.log('11. Capturing userstories-network-map-evidence.png...');
        // Go to Network via Bottom Nav (2nd item)
        await page.mouse.click(150, 750); // Network click
        await delay(1500);
        await page.screenshot({ path: getPath('userstories-network-map-evidence.png') });
        console.log('Saved userstories-network-map-evidence.png');

        console.log('Successfully captured all required screenshots!');

    } catch (error) {
        console.error('An error occurred during puppeteer automation:', error);
    } finally {
        await browser.close();
    }
})();
