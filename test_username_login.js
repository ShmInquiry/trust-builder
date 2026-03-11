const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();
    
    page.on('console', msg => console.log('BROWSER LOG:', msg.text()));

    console.log("Navigating...");
    await page.goto('http://localhost:5000', { waitUntil: 'load', timeout: 30000 });
    
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    console.log("Entering credentials (Username)...");
    await page.focus('input[type="text"]');
    await page.keyboard.type('Demo User');
    
    // click on password field
    await page.mouse.click(200, 370); 
    await new Promise(resolve => setTimeout(resolve, 500));
    await page.keyboard.type('demo1234');
    
    console.log("Clicking Login...");
    await page.mouse.click(200, 480); // Adjusted from 450 because of added content?
    
    await new Promise(resolve => setTimeout(resolve, 5000));
    const url = page.url();
    console.log("Final URL:", url);
    await browser.close();
})();
