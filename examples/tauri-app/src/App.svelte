<script>
  import { ping, execute, query } from 'tauri-plugin-duckdb-api'

	let response = $state('')
	let loading = $state(false)
	let queryResults = $state([])

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
			updateResponse({ action: 'Ping Test', result })
		} catch (error) {
			handleError(error)
		}
	}

	async function initializeDatabase() {
		loading = true
		try {
			const result = await execute({ 
				query: "CREATE TABLE users (id INTEGER, name VARCHAR, email VARCHAR)" 
			})
			updateResponse({ action: 'Create Table', result })
		} catch (error) {
			handleError(error)
		}
	}

	async function insertSampleData() {
		loading = true
		try {
			const users = [
				{ id: 1, name: 'Alice Johnson', email: 'alice@example.com' },
				{ id: 2, name: 'Bob Smith', email: 'bob@example.com' },
				{ id: 3, name: 'Carol White', email: 'carol@example.com' }
			]

			for (const user of users) {
				await execute({ 
					query: `INSERT INTO users VALUES (${user.id}, '${user.name}', '${user.email}')` 
				})
			}

			updateResponse({ action: 'Insert Data', result: { success: true, count: users.length } })
		} catch (error) {
			handleError(error)
		}
	}

	async function queryAllUsers() {
		loading = true
		try {
			const result = await query({ query: "SELECT * FROM users" })
			queryResults = result.data || []
			updateResponse({ action: 'Query Users', result, rowCount: queryResults.length })
		} catch (error) {
			handleError(error)
		}
	}

	async function runFullDemo() {
		loading = true
		try {
			// Step 1: Create table
			updateResponse({ step: 1, action: 'Creating table...' })
			await initializeDatabase()
			await new Promise(resolve => setTimeout(resolve, 500))

			// Step 2: Insert data
			updateResponse({ step: 2, action: 'Inserting sample data...' })
			await insertSampleData()
			await new Promise(resolve => setTimeout(resolve, 500))

			// Step 3: Query data
			updateResponse({ step: 3, action: 'Querying all users...' })
			await queryAllUsers()

			updateResponse({ status: 'Complete', message: '✅ Full demo completed successfully!' })
		} catch (error) {
			handleError(error)
		}
	}

	function clearLog() {
		response = ''
		queryResults = []
	}
</script>

<main class="container">
  <div class="header">
    <h1>🦆 Tauri + DuckDB</h1>
    <p class="subtitle">Mobile Database Demo</p>
  </div>

  <div class="demo-section">
    <h2>🚀 Quick Demo</h2>
    <div class="button-group">
      <button class="demo-btn" onclick={runFullDemo} disabled={loading}>
        {loading ? '⏳ Running...' : '▶️ Run Full Demo'}
      </button>
    </div>
    <p class="demo-desc">Creates table, inserts data, and queries results</p>
  </div>

  <div class="demo-section">
    <h2>📋 Manual Operations</h2>
    <div class="button-group">
      <button class="primary-btn" onclick={testPing} disabled={loading}>
        🔌 Test Connection
      </button>
      <button class="primary-btn" onclick={initializeDatabase} disabled={loading}>
        🗄️ Create Table
      </button>
      <button class="primary-btn" onclick={insertSampleData} disabled={loading}>
        ➕ Insert Data
      </button>
      <button class="primary-btn" onclick={queryAllUsers} disabled={loading}>
        🔍 Query Users
      </button>
      <button class="secondary-btn" onclick={clearLog}>
        🗑️ Clear Log
      </button>
    </div>
  </div>

  {#if queryResults.length > 0}
  <div class="results-section">
    <h3>📊 Query Results ({queryResults.length} rows)</h3>
    <div class="table-container">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Email</th>
          </tr>
        </thead>
        <tbody>
          {#each queryResults as row}
          <tr>
            <td>{row.id}</td>
            <td>{row.name}</td>
            <td>{row.email}</td>
          </tr>
          {/each}
        </tbody>
      </table>
    </div>
  </div>
  {/if}

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

  .demo-btn {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    color: white;
    width: 100%;
  }

  .demo-btn:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
  }

  .demo-desc {
    text-align: center;
    margin-top: 0.5rem;
    opacity: 0.9;
    font-size: 0.9rem;
    font-style: italic;
  }

  .results-section {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(10px);
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .results-section h3 {
    margin-top: 0;
    font-size: 1.3rem;
  }

  .table-container {
    overflow-x: auto;
    background: rgba(0, 0, 0, 0.3);
    border-radius: 8px;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    color: white;
  }

  thead {
    background: rgba(255, 255, 255, 0.1);
  }

  th, td {
    padding: 0.8rem;
    text-align: left;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  th {
    font-weight: 600;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  td {
    font-size: 0.95rem;
  }

  tbody tr:hover {
    background: rgba(255, 255, 255, 0.05);
  }

  tbody tr:last-child td {
    border-bottom: none;
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
