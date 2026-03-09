const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();

    page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
    page.on('response', response => {
        if (response.url().includes('/api/')) {
            console.log('API RESPONSE:', response.url(), response.status());
        }
    });

    console.log("Navigating...");
    await page.goto('http://localhost:5000', { waitUntil: 'load', timeout: 30000 });

    // Wait for the app to initialize
    await new Promise(resolve => setTimeout(resolve, 5000));

    console.log("Entering credentials...");
    await page.mouse.click(200, 300); // Email
    await new Promise(resolve => setTimeout(resolve, 500));
    await page.keyboard.type('demo@trustos.app');

    await page.mouse.click(200, 370); // Password
    await new Promise(resolve => setTimeout(resolve, 500));
    await page.keyboard.type('demo1234');

    console.log("Clicking Login...");
    await page.mouse.click(200, 450); // Login button

    // Wait for 10 seconds to collect logs
    await new Promise(resolve => setTimeout(resolve, 10000));

    console.log("Done.");
    await browser.close();
})();
