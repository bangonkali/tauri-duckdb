import { invoke } from '@tauri-apps/api/core'

export async function ping(value: string): Promise<string | null> {
  return await invoke<{value?: string}>('plugin:duckdb|ping', {
    payload: {
      value,
    },
  }).then((r) => (r.value ? r.value : null));
}

export interface ExecuteResult {
  success: boolean;
  message: string;
  rowsAffected?: number;
}

export async function execute(query: string): Promise<ExecuteResult> {
  return await invoke<ExecuteResult>('plugin:duckdb|execute', {
    payload: {
      query,
    },
  });
}

export interface QueryResult {
  success: boolean;
  data: any[];
  message?: string;
}

export async function query(query: string): Promise<QueryResult> {
  return await invoke<QueryResult>('plugin:duckdb|query', {
    payload: {
      query,
    },
  });
}
