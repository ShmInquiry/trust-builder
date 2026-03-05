const puppeteer = require('puppeteer-core');

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/chromium',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-web-security']
  });
  
  const page = await browser.newPage();
  page.on('console', msg => console.log('LOG:', msg.text()));
  
  console.log("Navigating to http://localhost:5000...");
  await page.goto('http://localhost:5000', { waitUntil: 'load', timeout: 15000 });
  
  try {
    const result = await page.evaluate(async () => {
      console.log('1. Loading Entrypoint...');
      const initEngine = await _flutter.loader.loadEntrypoint({ serviceWorker: { serviceWorkerVersion: null } });
      console.log('2. Entrypoint Loaded. Initializing Engine...');
      const appRunner = await initEngine.initializeEngine({});
      console.log('3. Engine Initialized. Running App...');
      await appRunner.runApp();
      console.log('4. App Running!');
      return "SUCCESS";
    });
    console.log("Final State:", result);
  } catch (e) {
    console.log("Exception:", e.message);
  }

  await browser.close();
})();
