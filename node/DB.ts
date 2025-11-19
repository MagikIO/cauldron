import Database from 'better-sqlite3'
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
  public db: Database.Database
  public tables = new Map<string, TableData>();

  private constructor({ db, debug }: { db: Database.Database, debug?: boolean }) {
    this.db = db;
    this.debug = debug ?? false;
  }

  /** Loads the Tables names, schema, and current data */
  private async loadTableMetadata() {
    try {
      // Step 1: Load table names and schema
      const nameAndSchemaResponse = this.db.prepare(`
        SELECT name, sql FROM sqlite_master WHERE type='table'
      `).all() as { name: string, sql: string }[];

      // Initialize a structure to hold the table data
      this.tables = new Map();

      // Step 2: Load data for each table
      for (const { name, sql: schema } of nameAndSchemaResponse) {
        // Fetch all rows from the table
        const rows = this.db.prepare(`SELECT * FROM "${name}"`).all() as Record<any, unknown>[];

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

      this.db.exec(`
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

  private prepareJSON({ table, field }: prepareJSONOptions) {
    return this.db.prepare(`INSERT INTO ${table} (${field}) VALUES (?)`)
  }

  public async insertJSON({ json, table, field }: insertJSONOptions) {
    try {
      const statement = this.prepareJSON({ table, field })
      return statement.run(JSON.stringify(json))
    } catch (error) { console.error('[DB]', error) }
  }

  public async close() {
    try {
      this.db.close();
    } catch (error) {
      console.error('[DB]', error)
    } finally {
      console.info('Database closed');
    }
  }

  public static async init(databasePath: string, debug = false) {
    try {
      // Create connection to DB
      const db = new Database(databasePath, debug ? { verbose: console.log } : undefined);

      // Return a new instance of Database Manager
      const DB = new DatabaseManager({ db, debug });
      await DB.loadTableMetadata();
      return DB;
    } catch (error) { console.error('[DB]', error) }
  }
}
