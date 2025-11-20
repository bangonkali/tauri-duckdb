<script>
  import { ping } from 'tauri-plugin-duckdb-api'

	let response = $state('')
	let loading = $state(false)

	function updateResponse(returnValue) {
		const timestamp = new Date().toLocaleTimeString()
		const message = typeof returnValue === 'string' ? returnValue : JSON.stringify(returnValue, null, 2)
		response = `[${timestamp}] ${message}\n\n${response}`
		loading = false
	}

	function handleError(error) {
		const timestamp = new Date().toLocaleTimeString()
		response = `[${timestamp}] ERROR: ${error}\n\n${response}`
		loading = false
	}

	async function testPing() {
		loading = true
		try {
			const result = await ping({ value: "Hello from DuckDB plugin!" })
			updateResponse(result)
		} catch (error) {
			handleError(error)
		}
	}

	function clearLog() {
		response = ''
	}
</script>

<main class="container">
  <div class="header">
    <h1>🦆 Tauri + DuckDB</h1>
    <p class="subtitle">Mobile Database Demo</p>
  </div>

  <div class="demo-section">
    <h2>Plugin Test</h2>
    <div class="button-group">
      <button class="primary-btn" onclick={testPing} disabled={loading}>
        {loading ? '⏳ Loading...' : '🔌 Test Connection'}
      </button>
      <button class="secondary-btn" onclick={clearLog}>
        🗑️ Clear Log
      </button>
    </div>
  </div>

  <div class="log-section">
    <h3>Event Log</h3>
    <div class="log-output">
      {#if response}
        <pre>{response}</pre>
      {:else}
        <p class="placeholder">No events yet. Try testing the connection!</p>
      {/if}
    </div>
  </div>

  <div class="footer">
    <p>Built with Tauri v2 + DuckDB</p>
  </div>
</main>

<style>
  :global(body) {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  }

  .container {
    max-width: 100%;
    padding: 1rem;
    box-sizing: border-box;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }

  .header {
    text-align: center;
    margin-bottom: 2rem;
  }

  .header h1 {
    font-size: 2.5rem;
    margin: 0.5rem 0;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  }

  .subtitle {
    font-size: 1.2rem;
    opacity: 0.9;
    margin: 0;
  }

  .demo-section {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .demo-section h2 {
    margin-top: 0;
    font-size: 1.5rem;
  }

  .button-group {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
  }

  button {
    padding: 0.8rem 1.5rem;
    font-size: 1rem;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s ease;
    font-weight: 600;
    flex: 1;
    min-width: 140px;
  }

  button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .primary-btn {
    background: #4CAF50;
    color: white;
  }

  .primary-btn:hover:not(:disabled) {
    background: #45a049;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  .secondary-btn {
    background: #f44336;
    color: white;
  }

  .secondary-btn:hover:not(:disabled) {
    background: #da190b;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }

  .log-section {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .log-section h3 {
    margin-top: 0;
    font-size: 1.3rem;
  }

  .log-output {
    background: rgba(0, 0, 0, 0.3);
    border-radius: 8px;
    padding: 1rem;
    max-height: 300px;
    overflow-y: auto;
    font-family: 'Courier New', monospace;
  }

  .log-output pre {
    margin: 0;
    white-space: pre-wrap;
    word-wrap: break-word;
    font-size: 0.9rem;
    line-height: 1.5;
  }

  .placeholder {
    opacity: 0.6;
    font-style: italic;
    text-align: center;
    margin: 2rem 0;
  }

  .footer {
    text-align: center;
    padding: 1rem;
    opacity: 0.8;
    font-size: 0.9rem;
  }

  @media (max-width: 768px) {
    .header h1 {
      font-size: 2rem;
    }

    .subtitle {
      font-size: 1rem;
    }

    .button-group {
      flex-direction: column;
    }

    button {
      width: 100%;
    }
  }
</style>
