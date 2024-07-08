import DatabaseManager from './DB';

export default class Cauldron {
  public debug = false;
  public sql: DatabaseManager;
  public version = '1.0.6';

  public dependencies = {
    "apt": [
      "bat", "cbonsai", "cowsay",
      "fortune", "jp2a", "linuxlogo", "pv",
      "hyfetch", "build-essential", "procps",
      "curl", "git", "rig", "toilet", "sqlite3"
    ],
    "brew": ["glow", "fzf", "timg", "watchman", "lsd", "fx", "navi"],
    "snap": [
      "lolcat-c"
    ],
  }

  constructor({ db, debug: boolean }: { db: DatabaseManager, debug: boolean }) {
    this.sql = db;
    this.debug = boolean;
  }

  public toString(pretty = true) {
    return JSON.stringify(this.dependencies, null, pretty ? 2 : undefined);
  }

  public info() {
    console.info('[DB]', this.sql.toString())
    console.info('[Cauldron]', this.toString())
  }

  static async init(debug = false) {
    try {
      const db = await DatabaseManager.init('./data/cauldron.db', debug);
      if (!db) { throw new Error('Database not initialized') }
      const cauldron = new Cauldron({ db, debug });
      return cauldron;
    } catch (error) { console.error('Cauldron', error) }
  }
}
