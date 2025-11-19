function __ensure_builtin_personalities --description "Ensure all built-in personalities exist in the database"
    # Define all 6 built-in personalities with their data
    # Using INSERT OR IGNORE to safely handle existing entries

    # Execute the builtin personalities SQL file
    sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/builtin_personalities.sql" 2>/dev/null
end
