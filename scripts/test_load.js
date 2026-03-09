const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  console.log("Navigating...");
  try {
    // Wait until the initial HTML is parsed, don't wait for every JS file to finish executing
    await page.goto('http://localhost:5000', { waitUntil: 'domcontentloaded', timeout: 15000 });

    console.log("Waiting for Flutter target to appear...");
    await page.waitForFunction(() => !!document.querySelector('flutter-view'), { timeout: 30000 });

    console.log("Success! App is rendering.");
  } catch (e) {
    console.log("Error:", e.message);
  }

  await browser.close();
})();
