const puppeteer = require('puppeteer');

(async () => {
    const browser = await puppeteer.launch({
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    const page = await browser.newPage();

    page.on('console', msg => console.log('BROWSER LOG:', msg.text()));
    page.on('pageerror', err => console.log('BROWSER ERROR:', err.toString()));

    console.log("Navigating...");
    await page.goto('http://localhost:5000', { waitUntil: 'load', timeout: 30000 });

    await new Promise(resolve => setTimeout(resolve, 5000));

    console.log("Entering credentials...");
    await page.mouse.click(200, 300);
    await new Promise(resolve => setTimeout(resolve, 500));
    await page.keyboard.type('demo@trustos.app');

    await page.mouse.click(200, 370);
    await new Promise(resolve => setTimeout(resolve, 500));
    await page.keyboard.type('demo1234');

    console.log("Clicking Login...");
    await page.mouse.click(200, 450);

    await new Promise(resolve => setTimeout(resolve, 5000));

    console.log("Taking screenshot...");
    await page.screenshot({ path: 'debug_after_login.png' });

    // Also try to dump the DOM to see if it's stuck on loading
    const content = await page.content();
    require('fs').writeFileSync('debug_dom.html', content);

    console.log("Done.");
    await browser.close();
})();
