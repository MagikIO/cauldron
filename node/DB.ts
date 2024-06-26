import sqlite3 from 'sqlite3'
import sql from 'sql-template-tag'
import { open, type Database } from 'sqlite'
import consola from 'consola';

interface createTableOptions { table: string, schema: string }
interface prepareJSONOptions { table: string, field: string }
interface insertJSONOptions { table: string, field: string, json: Record<any, unknown> | Array<unknown> }

interface TableData<
  T extends Record<string, unknown> | Array<unknown> = Record<string, unknown> | Array<unknown>
> {
  schema: string;
  data: T;
}

export default class DatabaseManager {
  public debug = false;
  public db: Database<sqlite3.Database, sqlite3.Statement>
  public tables = new Map<string, TableData>();

  private constructor({ db, debug }: { db: Database<sqlite3.Database, sqlite3.Statement>, debug?: boolean }) {
    this.db = db;
    this.debug = debug ?? false;
  }

  /** Loads the Tables names, schema, and current data */
  private async loadTableMetadata() {
    try {
      // Step 1: Load table names and schema
      const nameAndSchemaResponse = await this.db.all<{ name: string, sql: string }[]>(`
      SELECT name, sql FROM sqlite_master WHERE type='table'
    `);

      // Initialize a structure to hold the table data
      this.tables = new Map();

      // Step 2: Load data for each table
      for (const { name, sql: schema } of nameAndSchemaResponse) {
        // Fetch all rows from the table
        const rows = await this.db.all<Record<any, unknown>[]>(`SELECT * FROM "${name}"`);

        // The rows are already in the desired format (an array of objects),
        // so you can directly use them without needing to parse JSON.
        const data = rows;

        // Step 3: Store the name, schema, and data in the map
        this.tables.set(name, { schema, data });
      }

      if (this.debug) consola.success('Table metadata and data loaded');
    } catch (error) {
      console.error('[DB]', error);
    }
  }

  public toString(pretty = true) {
    return JSON.stringify(
      Object.fromEntries(this.tables),
      null,
      pretty ? 2 : undefined
    );
  }

  public async createTable({ table, schema }: createTableOptions) {
    try {
      if (this.tables.has(table)) {
        console.error(`Table ${table} already exists`);
        return;
      }

      await this.db.exec(`
        CREATE TABLE IF NOT EXISTS ${table} (
        id INTEGER PRIMARY KEY,
        ${schema}
      )`);

      if (this.debug) consola.success(`Table ${table} created`);

      // Update the table metadata
      await this.loadTableMetadata();

      return this.tables.get(table);
    } catch (error) { console.error('[DB]', error) }
  }

  private async prepareJSON({ table, field }: prepareJSONOptions) {
    return this.db.prepare(sql`INSERT INTO ${table} (${field}) VALUES (?)`)
  }

  public async insertJSON({ json, table, field }: insertJSONOptions) {
    try {
      const statement = await this.prepareJSON({ table, field })
      await statement.bind([JSON.stringify(json)])
      return await statement.run()
    } catch (error) { console.error('[DB]', error) }
  }

  public async close() {
    try {
      await this.db.close();
    } catch (error) {
      console.error('[DB]', error)
    } finally {
      console.info('Database closed');
    }
  }

  public static async init(databasePath: string, debug = false) {
    try {
      // Move into verbose mode
      if (debug) sqlite3.verbose();
      // Create connection to DB with cache
      const db = await open({ filename: databasePath, driver: sqlite3.cached.Database });
      // Add a listener for errors
      db.on('error', (err: unknown) => console.error('Database error', err));
      if (debug) db.on('trace', (s: unknown) => console.log('SQL Executed:', s));
      // Return a new instance of Database Manager
      const DB = new DatabaseManager({ db, debug });
      await DB.loadTableMetadata();
      return DB;
    } catch (error) { console.error('[DB]', error) }
  }
}
