# =========================================================================
# EpiTxDb schema
# -------------------------------------------------------------------------
#
# Nothing in this file is exported.
#
# 9 tables:
#   - modification
#   - seqnames
#   - reaction
#   - specifier
#   - reference
#   - modification2reaction
#   - modification2specifier
#   - modification2reference
#   - metadata (not described here)

DB_TYPE_NAME <- "Db type"
DB_TYPE_VALUE <- "EpiTxDb"
DB_SCHEMA_VERSION <- "1.0"

# Return the *effective* schema version.
EpiTxDb_schema_version <- function(epitxdb)
{
    conn <- if (is(epitxdb, "EpiTxDb")) dbconn(epitxdb) else epitxdb
    version <- AnnotationDbi:::.getMetaValue(conn, "DBSCHEMAVERSION")
    numeric_version(version)
}


# Table columns ----------------------------------------------------------------

# 'modification' table

EPITXDB_MOD_COLDEFS <- c(
    `_mod_id` = "INTEGER PRIMARY KEY",
    mod_type = "TEXT NOT NULL",
    mod_name = "TEXT NULL",
    mod_start = "INTEGER NOT NULL",
    mod_end = "INTEGER NOT NULL",
    mod_strand = "TEXT NOT NULL",
    `_sn_id` = "INTEGER NOT NULL"
)
EPITXDB_MOD_COLUMNS <- names(EPITXDB_MOD_COLDEFS)

# 'seqnames' table

EPITXDB_SN_COLDEFS <- c(
    `_sn_id` = "INTEGER NOT NULL",
    sn_name = "TEXT NOT NULL"
)
EPITXDB_SN_COLUMNs <- names(EPITXDB_SN_COLDEFS)

# 'reaction' table

EPITXDB_RX_COLDEFS <- c(
    `_rx_id` = "INTEGER PRIMARY KEY",
    rx_genename = "TEXT NULL",
    rx_rank = "INTEGER NULL",
    rx_ensembl = "TEXT NULL",
    rx_ensembltrans = "TEXT NULL",
    rx_entrezid = "TEXT NULL"
)
EPITXDB_RX_COLUMNS <- names(EPITXDB_RX_COLDEFS)

# 'specifier' table

EPITXDB_SPEC_COLDEFS <- c(
    `_spec_id` = "INTEGER NOT NULL",
    spec_type = "TEXT NOT NULL",
    spec_genename = "TEXT NOT NULL",
    spec_ensembl = "TEXT NULL",
    spec_ensembltrans = "TEXT NULL",
    spec_entrezid = "TEXT NULL"
)

EPITXDB_SPEC_COLUMNS <- names(EPITXDB_SPEC_COLDEFS)

# 'reference' table

EPITXDB_REF_COLDEFS <- c(
    `_ref_id` = "INTEGER NOT NULL",
    ref_type = "TEXT NULL",
    ref = "TEXT NULL"
)

EPITXDB_REF_COLUMNS <- names(EPITXDB_REF_COLDEFS)

# modification2* tables

EPITXDB_MOD2RX_COLDEFS <- c(
    `_mod_id` = "INTEGER NOT NULL",
    `_rx_id` = "INTEGER NOT NULL"
)

EPITXDB_MOD2RX_COLUMNS <- names(EPITXDB_MOD2RX_COLDEFS)

EPITXDB_MOD2SPEC_COLDEFS <- c(
    `_mod_id` = "INTEGER NOT NULL",
    `_spec_id` = "INTEGER NOT NULL"
)

EPITXDB_MOD2SPEC_COLUMNS <- names(EPITXDB_MOD2SPEC_COLDEFS)

EPITXDB_MOD2REF_COLDEFS <- c(
    `_mod_id` = "INTEGER NOT NULL",
    `_ref_id` = "INTEGER NOT NULL"
)

EPITXDB_MOD2REF_COLUMNS <- names(EPITXDB_MOD2REF_COLDEFS)

#

EPITXDB_COLUMNS <- list(
    seqnames = EPITXDB_SN_COLUMNs,
    modification = EPITXDB_MOD_COLUMNS,
    reaction = EPITXDB_RX_COLUMNS,
    specifier = EPITXDB_SPEC_COLUMNS,
    reference = EPITXDB_REF_COLUMNS,
    modification2reaction = EPITXDB_MOD2RX_COLUMNS,
    modification2specifier = EPITXDB_MOD2SPEC_COLUMNS,
    modification2reference = EPITXDB_MOD2REF_COLUMNS
)


# Build CREATE TABLE statements ------------------------------------------------

.build_SQL_CREATE_TABLE <- function(table, coldefs, constraints = NULL)
{
    SQL <- "CREATE TABLE %s (%s\n)"
    coldefs <- c(paste(names(coldefs), coldefs), constraints)
    coldefs <- paste("\n  ", coldefs, collapse = ",")
    sprintf(SQL, table, coldefs)
}

build_SQL_CREATE_modification_table <- function()
{
    unique_key <- "UNIQUE (_mod_id, _sn_id)"
    foreign_key <- "FOREIGN KEY (_sn_id) REFERENCES seqnames"
    constraints <- c(unique_key, foreign_key)
    .build_SQL_CREATE_TABLE("modification", EPITXDB_MOD_COLDEFS, constraints)
}

build_SQL_CREATE_seqnames_table <- function()
{
    unique_key <- "UNIQUE (_sn_id)"
    constraints <- c(unique_key)
    .build_SQL_CREATE_TABLE("seqnames", EPITXDB_SN_COLDEFS, constraints)
}

build_SQL_CREATE_reaction_table <- function()
{
    unique_key <- "UNIQUE (_rx_id)"
    constraints <- c(unique_key)
    .build_SQL_CREATE_TABLE("reaction", EPITXDB_RX_COLDEFS, constraints)
}

build_SQL_CREATE_specifier_table <- function()
{
    unique_key <- "UNIQUE (_spec_id)"
    constraints <- c(unique_key)
    .build_SQL_CREATE_TABLE("specifier", EPITXDB_SPEC_COLDEFS, constraints)
}

build_SQL_CREATE_reference_table <- function()
{
    unique_key <- "UNIQUE (_ref_id)"
    constraints <- c(unique_key)
    .build_SQL_CREATE_TABLE("reference", EPITXDB_REF_COLDEFS, constraints)
}

build_SQL_CREATE_modification2reaction_table <- function(){
    unique_key <- "UNIQUE (_mod_id, _rx_id)"
    foreign_key <- paste("FOREIGN KEY (_mod_id) REFERENCES modification",
                         "FOREIGN KEY (_rx_id) REFERENCES reaction")
    constraints <- c(unique_key, foreign_key)
    .build_SQL_CREATE_TABLE("modification2reaction", EPITXDB_MOD2RX_COLDEFS,
                            constraints)
}

build_SQL_CREATE_modification2specifier_table <- function(){
    unique_key <- "UNIQUE (_mod_id, _spec_id)"
    foreign_key <- paste("FOREIGN KEY (_mod_id) REFERENCES modification",
                         "FOREIGN KEY (_spec_id) REFERENCES specifier")
    constraints <- c(unique_key, foreign_key)
    .build_SQL_CREATE_TABLE("modification2specifier", EPITXDB_MOD2SPEC_COLDEFS,
                            constraints)
}

build_SQL_CREATE_modification2reference_table <- function(){
    unique_key <- "UNIQUE (_mod_id, _ref_id)"
    foreign_key <- paste("FOREIGN KEY (_mod_id) REFERENCES modification",
                         "FOREIGN KEY (_ref_id) REFERENCES reference")
    constraints <- c(unique_key, foreign_key)
    .build_SQL_CREATE_TABLE("modification2reference", EPITXDB_MOD2REF_COLDEFS,
                            constraints)
}

# helper functions -------------------------------------------------------------

EPITXDB_tables <- function() names(EPITXDB_COLUMNS)

EPITXDB_table_columns <- function(table, schema_version = NA){
    columns <- EPITXDB_COLUMNS[[table]]
    columns
}

EPITXDB_column2table <- function(columns, from_table = NA, schema_version = NA){
    if (length(columns) == 0L)
        return(character(0))
    table_columns <- lapply(EPITXDB_tables(), EPITXDB_table_columns,
                            schema_version = schema_version)
    names(table_columns) <- EPITXDB_tables()
    table_columns <- unlist(IRanges::CharacterList(table_columns))
    if(any(!(columns %in% table_columns))){
        if (is.na(schema_version)) {
            in_schema <- ""
        } else {
            in_schema <- c(" in db schema ", as.character(schema_version))
        }
        stop(columns[!(columns %in% table_columns)], ": no such column",
             in_schema)
    }
    tables <- names(table_columns[match(columns,table_columns)])
    names(tables) <- columns
    if (!is.na(from_table)) {
        table_columns <- EPITXDB_table_columns(from_table,
                                               schema_version = schema_version)
        tables[columns %in% table_columns] <- from_table
    }
    tables
}

EPITXDB_table2joinColumns <- function(tables, schema_version = NA){
    if (length(tables) == 0L)
        return(character(0))
    f <- tables %in% EPITXDB_tables()
    if(any(!f)){
        if (is.na(schema_version)) {
            in_schema <- ""
        } else {
            in_schema <- c(" in db schema ", as.character(schema_version))
        }
        stop(tables[!f], ": no such table", in_schema)
    }
    columns <- vapply(lapply(tables, EPITXDB_table_columns,
                             schema_version = schema_version),
                      "[[",character(1),1L)
    names(columns) <- tables
    columns
}
