/**
 * It provides information about a database as a whole.
 *
 * @version 1.0  Spet. 28 1999
 * @author Quansheng Jia
 * @see
 */

package sanchez.jdbc.driver;

import java.sql.*;

import sanchez.jdbc.dbaccess.ScDBError;

public class ScDatabaseMetaData implements DatabaseMetaData {

    ScConnection connection;

    int procedureResultUnknown;
    int procedureNoResult;
    int procedureReturnsResult;
    int procedureColumnUnknown;
    int procedureColumnIn;
    int procedureColumnInOut;
    int procedureColumnOut;
    int procedureColumnReturn;
    int procedureColumnResult;
    int procedureNoNulls;
    int procedureNullable;
    int procedureNullableUnknown;
    int columnNoNulls;
    int columnNullable;
    int columnNullableUnknown;
    static final int bestRowTemporary = 0;
    static final int bestRowTransaction = 1;
    static final int bestRowSession = 2;
    static final int bestRowUnknown = 0;
    static final int bestRowNotPseudo = 1;
    static final int bestRowPseudo = 2;
    int versionColumnUnknown;
    int versionColumnNotPseudo;
    int versionColumnPseudo;
    int importedKeyCascade;
    int importedKeyRestrict;
    int importedKeySetNull;
    int typeNoNulls;
    int typeNullable;
    int typeNullableUnknown;
    int typePredNone;
    int typePredChar;
    int typePredBasic;
    int typeSearchable;
    short tableIndexStatistic;
    short tableIndexClustered;
    short tableIndexHashed;
    short tableIndexOther;
    int versionColumnuUnknown;

    public ScDatabaseMetaData(ScConnection conn) {

        procedureNoResult = 1;
        procedureReturnsResult = 2;
        procedureColumnIn = 1;
        procedureColumnInOut = 2;
        procedureColumnOut = 4;
        procedureColumnReturn = 5;
        procedureColumnResult = 3;
        procedureNullable = 1;
        procedureNullableUnknown = 2;
        columnNullable = 1;
        columnNullableUnknown = 2;
        versionColumnuUnknown = 0;
        versionColumnNotPseudo = 1;
        versionColumnPseudo = 2;
        importedKeyRestrict = 1;
        importedKeySetNull = 2;
        typeNullable = 1;
        typeNullableUnknown = 2;
        typePredChar = 1;
        typePredBasic = 2;
        typeSearchable = 3;
        tableIndexClustered = 1;
        tableIndexHashed = 2;
        tableIndexOther = 3;

        connection = conn;
    }

    public boolean allProceduresAreCallable() throws SQLException {
        connection.log("ScDatabaseMetaData.allProceduresAreCallable");
        return false;
    }

    public boolean allTablesAreSelectable() throws SQLException {
        connection.log("ScDatabaseMetaData.allTablesAreSelectable");
        return false;
    }

    public String getURL() throws SQLException {
        connection.log("ScDatabaseMetaData.getURL");
        return connection.i_sUrl;
    }

    public String getUserName() throws SQLException {
        connection.log("ScDatabaseMetaData.getUserName");
        return connection.i_sUser;
    }

    public boolean isReadOnly() throws SQLException {
        connection.log("ScDatabaseMetaData.isReadOnly");
        return false;
    }

    public boolean nullsAreSortedHigh() throws SQLException {
        connection.log("ScDatabaseMetaData.nullsAreSortedHigh");
        return false;
    }

    public boolean nullsAreSortedLow() throws SQLException {
        connection.log("ScDatabaseMetaData.nullsAreSortedLow");
        return true;
    }

    public boolean nullsAreSortedAtStart() throws SQLException {
        connection.log("ScDatabaseMetaData.nullsAreSortedAtStart");
        return false;
    }

    public boolean nullsAreSortedAtEnd() throws SQLException {
        connection.log("ScDatabaseMetaData.nullsAreSortedAtEnd");
        return false;
    }

    public String getDatabaseProductName() throws SQLException {
        connection.log("ScDatabaseMetaData.getDatabaseProductName");
        return "Profile/Anyware";
    }

    public String getDatabaseProductVersion() throws SQLException {

        connection.log("ScDatabaseMetaData.getDatabaseProductVersion");
        Statement stmt = connection.createStatement();
        ResultSet rs = stmt.executeQuery("select %vn from cuvar");

        String databaseVer = "";
        if (rs.next())
            databaseVer = rs.getString(1);
        rs.close();
        stmt.close();
        return databaseVer;
    }

    public String getDriverName() throws SQLException {
        connection.log("ScDatabaseMetaData.getDriverName");
        return "Fidelity Profile JDBC driver 3.0.1";
    }

    public String getDriverVersion() throws SQLException {
        connection.log("ScDatabaseMetaData.getDriverVersion");
        return "3.0.2 Build 5 (Open Source)";
    }

    public int getDriverMajorVersion() {
        return 3;
    }

    public int getDriverMinorVersion() {
        return 1;
    }

    public boolean usesLocalFiles() throws SQLException {
        connection.log("ScDatabaseMetaData.usesLocalFiles");
        return false;
    }

    public boolean usesLocalFilePerTable() throws SQLException {
        connection.log("ScDatabaseMetaData.usesLocalFilePerTable");
        return false;
    }

    public boolean supportsMixedCaseIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMixedCaseIdentifiers");
        return false;
    }

    public boolean storesUpperCaseIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesUpperCaseIdentifiers");
        return true;
    }

    public boolean storesLowerCaseIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesLowerCaseIdentifiers");
        return false;
    }

    public boolean storesMixedCaseIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesMixedCaseIdentifiers");
        return false;
    }

    public boolean supportsMixedCaseQuotedIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMixedCaseQuotedIdentifiers");
        return true;
    }

    public boolean storesUpperCaseQuotedIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesUpperCaseQuotedIdentifiers");
        return false;
    }

    public boolean storesLowerCaseQuotedIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesLowerCaseQuotedIdentifiers");
        return false;
    }

    public boolean storesMixedCaseQuotedIdentifiers() throws SQLException {
        connection.log("ScDatabaseMetaData.storesMixedCaseQuotedIdentifiers");
        return true;
    }

    public String getIdentifierQuoteString() throws SQLException {
        connection.log("ScDatabaseMetaData.getIdentifierQuoteString");
        return "\"";
    }

    public String getSQLKeywords() throws SQLException {
        connection.log("ScDatabaseMetaData.getSQLKeywords");
        return "ACCESS, ADD, ALTER, AUDIT, CLUSTER, COLUMN, COMMENT, COMPRESS, CONNECT, DATE, DROP, EXCLUSIVE, FILE, IDENTIFIED, IMMEDIATE, INCREMENT, INDEX, INITIAL, INTERSECT, LEVEL, LOCK, LONG, MAXEXTENTS, MINUS, MODE, NOAUDIT, NOCOMPRESS, NOWAIT, NUMBER, OFFLINE, ONLINE, PCTFREE, PRIOR, all_PL_SQL_reserved_ words";
    }

    public String getNumericFunctions() throws SQLException {
        connection.log("ScDatabaseMetaData.getNumericFunctions");
        return "";
    }

    public String getStringFunctions() throws SQLException {
        connection.log("ScDatabaseMetaData.getStringFunctions");
        return "";
    }

    public String getSystemFunctions() throws SQLException {
        connection.log("ScDatabaseMetaData.getSystemFunctions");
        return "";
    }

    public String getTimeDateFunctions() throws SQLException {
        connection.log("ScDatabaseMetaData.getTimeDateFunctions");
        return "";
    }

    public String getSearchStringEscape() throws SQLException {
        connection.log("ScDatabaseMetaData.getSearchStringEscape");
        return "";
    }

    public String getExtraNameCharacters() throws SQLException {
        connection.log("ScDatabaseMetaData.getExtraNameCharacters");
        return "$#";
    }

    public boolean supportsAlterTableWithAddColumn() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsAlterTableWithAddColumn");
        return true;
    }

    public boolean supportsAlterTableWithDropColumn() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsAlterTableWithDropColumn");
        return false;
    }

    public boolean supportsColumnAliasing() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsColumnAliasing");
        return true;
    }

    public boolean nullPlusNonNullIsNull() throws SQLException {
        connection.log("ScDatabaseMetaData.nullPlusNonNullIsNull");
        return true;
    }

    public boolean supportsConvert() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsConvert");
        return true;
    }

    public boolean supportsConvert(int fromType, int toType) throws SQLException {
        connection.log("ScDatabaseMetaData.supportsConvert");
        if (fromType == toType || fromType == 1 || fromType == 12 || fromType == -1 || toType == 1 || toType == 12 || toType == -1)
            return true;
        switch (fromType) {
            case 2:
            case 3:
                if (toType != 92 && toType != 93 && toType != 91)
                    return false;
                else
                    return true;

            case 91:
            case 92:
            case 93:
                if (toType != 2 && toType != 3)
                    return false;
                else
                    return true;

            default:
                return false;
        }
    }

    public boolean supportsTableCorrelationNames() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsTableCorrelationNames");
        return true;
    }

    public boolean supportsDifferentTableCorrelationNames() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsDifferentTableCorrelationNames");
        return true;
    }

    public boolean supportsExpressionsInOrderBy() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsExpressionsInOrderBy");
        return true;
    }

    public boolean supportsOrderByUnrelated() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOrderByUnrelated");
        return true;
    }

    public boolean supportsGroupBy() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsGroupBy");
        return true;
    }

    public boolean supportsGroupByUnrelated() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsGroupByUnrelated");
        return true;
    }

    public boolean supportsGroupByBeyondSelect() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsGroupByBeyondSelect");
        return true;
    }

    public boolean supportsLikeEscapeClause() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsLikeEscapeClause");
        return true;
    }

    public boolean supportsMultipleResultSets() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMultipleResultSets");
        return false;
    }

    public boolean supportsMultipleTransactions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMultipleTransactions");
        return true;
    }

    public boolean supportsNonNullableColumns() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsNonNullableColumns");
        return true;
    }

    public boolean supportsMinimumSQLGrammar() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMinimumSQLGrammar");
        return true;
    }

    public boolean supportsCoreSQLGrammar() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCoreSQLGrammar");
        return true;
    }

    public boolean supportsExtendedSQLGrammar() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsExtendedSQLGrammar");
        return true;
    }

    public boolean supportsANSI92EntryLevelSQL() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsANSI92EntryLevelSQL");
        return false;
    }

    public boolean supportsANSI92IntermediateSQL() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsANSI92IntermediateSQL");
        return false;
    }

    public boolean supportsANSI92FullSQL() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsANSI92FullSQL");
        return false;
    }

    public boolean supportsIntegrityEnhancementFacility() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsIntegrityEnhancementFacility");
        return true;
    }

    public boolean supportsOuterJoins() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOuterJoins");
        return true;
    }

    public boolean supportsFullOuterJoins() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOuterJoins");
        return true;
    }

    public boolean supportsLimitedOuterJoins() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsLimitedOuterJoins");
        return true;
    }

    public String getSchemaTerm() throws SQLException {
        connection.log("ScDatabaseMetaData.getSchemaTerm");
        return "schema";

    }

    public String getProcedureTerm() throws SQLException {
        connection.log("ScDatabaseMetaData.getProcedureTerm");
        return "procedure";
    }

    public String getCatalogTerm() throws SQLException {
        connection.log("ScDatabaseMetaData.getCatalogTerm");
        return "";
    }

    public boolean isCatalogAtStart() throws SQLException {
        connection.log("ScDatabaseMetaData.isCatalogAtStart");
        return false;
    }

    public String getCatalogSeparator() throws SQLException {
        connection.log("ScDatabaseMetaData.getCatalogSeparator");
        return "";
    }

    public boolean supportsSchemasInDataManipulation() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSchemasInDataManipulation");
        return false;
    }

    public boolean supportsSchemasInProcedureCalls() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSchemasInProcedureCalls");
        return false;
    }

    public boolean supportsSchemasInTableDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSchemasInTableDefinitions");
        return false;
    }

    public boolean supportsSchemasInIndexDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSchemasInIndexDefinitions");
        return false;
    }

    public boolean supportsSchemasInPrivilegeDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSchemasInPrivilegeDefinitions");
        return false;
    }

    public boolean supportsCatalogsInDataManipulation() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCatalogsInDataManipulation");
        return false;
    }

    public boolean supportsCatalogsInProcedureCalls() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCatalogsInProcedureCalls");
        return false;
    }

    public boolean supportsCatalogsInTableDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCatalogsInTableDefinitions");
        return false;

    }

    public boolean supportsCatalogsInIndexDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCatalogsInIndexDefinitions");
        return false;
    }

    public boolean supportsCatalogsInPrivilegeDefinitions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCatalogsInPrivilegeDefinitions");
        return false;
    }

    public boolean supportsPositionedDelete() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsPositionedDelete");
        return true;
    }

    public boolean supportsPositionedUpdate() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsPositionedUpdate");
        return true;
    }

    public boolean supportsSelectForUpdate() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSelectForUpdate");
        return false;
    }

    public boolean supportsStoredProcedures() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsStoredProcedures");
        return true;
    }

    public boolean supportsSubqueriesInComparisons() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSubqueriesInComparisons");
        return true;
    }

    public boolean supportsSubqueriesInExists() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSubqueriesInExists");
        return true;
    }

    public boolean supportsSubqueriesInIns() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSubqueriesInIns");
        return true;
    }

    public boolean supportsSubqueriesInQuantifieds() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSubqueriesInQuantifieds");
        return true;
    }

    public boolean supportsCorrelatedSubqueries() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsCorrelatedSubqueries");
        return true;
    }

    public boolean supportsUnion() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsUnion");
        return true;
    }

    public boolean supportsUnionAll() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsUnionAll");
        return true;
    }

    public boolean supportsOpenCursorsAcrossCommit() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOpenCursorsAcrossCommit");
        return false;
    }

    public boolean supportsOpenCursorsAcrossRollback() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOpenCursorsAcrossRollback");
        return false;
    }

    public boolean supportsOpenStatementsAcrossCommit() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOpenStatementsAcrossCommit");
        return false;
    }

    public boolean supportsOpenStatementsAcrossRollback() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsOpenStatementsAcrossRollback");
        return false;
    }

    public int getMaxBinaryLiteralLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxBinaryLiteralLength");
        return 1000;
    }

    public int getMaxCharLiteralLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxCharLiteralLength");
        return 2000;
    }

    public int getMaxColumnNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnNameLength");
        return 30;
    }

    public int getMaxColumnsInGroupBy() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnsInGroupBy");
        return 0;
    }

    public int getMaxColumnsInIndex() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnsInIndex");
        return 16;
    }

    public int getMaxColumnsInOrderBy() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnsInOrderBy");
        return 0;
    }

    public int getMaxColumnsInSelect() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnsInSelect");
        return 0;
    }

    public int getMaxColumnsInTable() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxColumnsInTable");
        return 0;
    }

    public int getMaxConnections() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxConnections");
        return 0;
    }

    public int getMaxCursorNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxCursorNameLength");
        return 0;
    }

    public int getMaxIndexLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxIndexLength");
        return 0;
    }

    public int getMaxSchemaNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxSchemaNameLength");
        return 30;
    }

    public int getMaxProcedureNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxProcedureNameLength");
        return 30;
    }

    public int getMaxCatalogNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxCatalogNameLength");
        return 0;
    }

    public int getMaxRowSize() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxRowSize");
        return 0;
    }

    public boolean doesMaxRowSizeIncludeBlobs() throws SQLException {
        connection.log("ScDatabaseMetaData.doesMaxRowSizeIncludeBlobs");
        return true;
    }

    public int getMaxStatementLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxStatementLength");
        return 1048575;
    }

    public int getMaxStatements() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxStatements");
        return 0;
    }

    public int getMaxTableNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxTableNameLength");
        return 12;
    }

    public int getMaxTablesInSelect() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxTablesInSelect");
        return 0;
    }

    public int getMaxUserNameLength() throws SQLException {
        connection.log("ScDatabaseMetaData.getMaxUserNameLength");
        return 12;
    }

    public int getDefaultTransactionIsolation() throws SQLException {
        connection.log("ScDatabaseMetaData.getDefaultTransactionIsolation");
        return 1;
    }

    public boolean supportsTransactions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsTransactions");
        return true;
    }

    public boolean supportsTransactionIsolationLevel(int level) throws SQLException {
        connection.log("ScDatabaseMetaData.supportsTransactionIsolationLevel");
        if (level != 1)
            return false;
        else
            return true;
    }

    public boolean supportsDataDefinitionAndDataManipulationTransactions() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsDataDefinitionAndDataManipulationTransactions");
        return false;
    }

    public boolean supportsDataManipulationTransactionsOnly() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsDataManipulationTransactionsOnly");
        return true;
    }

    public boolean dataDefinitionCausesTransactionCommit() throws SQLException {
        connection.log("ScDatabaseMetaData.dataDefinitionCausesTransactionCommit");
        return true;
    }

    public boolean dataDefinitionIgnoredInTransactions() throws SQLException {
        connection.log("ScDatabaseMetaData.dataDefinitionIgnoredInTransactions");
        return false;
    }

    public synchronized ResultSet getProcedures(String catalog, String schemaPattern, String procedureNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getProcedures(" + catalog + "|" + schemaPattern + "|" + procedureNamePattern + ")");

        String query;
        String whereCluse = "";
        String where = " %LIBS='SYSDEV'";

        if ((procedureNamePattern == null) || (procedureNamePattern.equalsIgnoreCase("%")))
            whereCluse = "WHERE" + where;
        else if ((procedureNamePattern.charAt(0) == '%') || (procedureNamePattern.charAt(procedureNamePattern.length() - 1) == '%'))
            whereCluse = "WHERE FID LIKE '" + procedureNamePattern + "' \n" + "AND" + where;
        else
            whereCluse = "WHERE PROCID ='" + procedureNamePattern + "' \n" + "AND" + where;

        String tableSchem = ".";
    /*[DBTBL25]
     %LIBS         %LIBS                                  T     12  1*           SILV
     DES           Description                            T     40  PROCID    1  CHIA
     LTD           Last Modified                          D     10  PROCID    3  SPIE
     MPLUS         PSL Format                             L      1  PROCID    9  CHIA
     PFID          Access Files                           U     50  PROCID    8  CHIA
     PGM           Run-time Routine                       U      8  PROCID    2  CHIA
     PROCID        Procedure Name                         U     12  3*           SILV
     RPCVAR        List of variable names (RPC call)      T    250  PROCID    6  CHIA
     RPCVAR1       List of variable names                 T    250  PROCID    7  CHIA
     TIME          Time Last Updated                      C     10  PROCID    5  CHIA
     USER          By User
     */

        query = "SELECT '','" + tableSchem + "',PROCID,PFID,RPCVAR,RPCVAR1,DES,'0' FROM DBTBL25 " + whereCluse;
        Statement s = connection.createStatement();

        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        ScStatement ss = (ScStatement) s;

        String[] colName = {"PROCEDURE_CAT", "PROCEDURE_SCHEM", "PROCEDURE_NAME", "PFID", "RPCVAR", "RPCVAR1", "REMARKS", "PROCEDURE_TYPE"};
        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    /**
     * Retrieves a description of the given catalog's stored procedure parameter and result columns.
     * Only descriptions matching the schema, procedure and parameter name criteria are returned. They are ordered by PROCEDURE_SCHEM and PROCEDURE_NAME. Within this, the return value, if any, is first. Next are the parameter descriptions in call order. The column descriptions follow in column number order.
     *
     * Each row in the ResultSet is a parameter description or column description with the following fields:
     *
     * PROCEDURE_CAT String => procedure catalog (may be null)
     * PROCEDURE_SCHEM String => procedure schema (may be null)
     * PROCEDURE_NAME String => procedure name
     * COLUMN_NAME String => column/parameter name
     * COLUMN_TYPE Short => kind of column/parameter:
     * 	procedureColumnUnknown - nobody knows
     * 	procedureColumnIn - IN parameter
     * 	procedureColumnInOut - INOUT parameter
     * 	procedureColumnOut - OUT parameter
     * 	procedureColumnReturn - procedure return value
     * 	procedureColumnResult - result column in ResultSet
     * DATA_TYPE int => SQL type from java.sql.Types
     * TYPE_NAME String => SQL type name, for a UDT type the type name is fully qualified
     * PRECISION int => precision
     * LENGTH int => length in bytes of data
     * SCALE short => scale
     * RADIX short => radix
     * NULLABLE short => can it contain NULL.
     * 	procedureNoNulls - does not allow NULL values
     * 	procedureNullable - allows NULL values
     * 	procedureNullableUnknown - nullability unknown
     * REMARKS String => comment describing parameter/column
     *
     * Note: Some databases may not return the column descriptions for a procedure. Additional columns beyond REMARKS can be defined by the database.
     *
     * Parameters:
     * 	catalog - a catalog name; must match the catalog name as it is stored in the database; "" retrieves those without a catalog; null means that the catalog name should not be used to narrow the search
     * 	schemaPattern - a schema name pattern; must match the schema name as it is stored in the database; "" retrieves those without a schema; null means that the schema name should not be used to narrow the search
     * 	procedureNamePattern - a procedure name pattern; must match the procedure name as it is stored in the database
     * 	columnNamePattern - a column name pattern; must match the column name as it is stored in the database
     *
     * @history zugarekdj 07-20-2004 11225
     * 	Changed DBTBL40 to DBTBL25.  DBTBL40 does not excist on the host and no other table supplies details
     * 	of the procedure parameters.
     **/
    public synchronized ResultSet getProcedureColumns(String catalog, String schemaPattern, String procedureNamePattern, String columnNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getProcedures(" + catalog + "|" + schemaPattern + "|" + procedureNamePattern + ")");

        String query;
        String whereCluse = "";
        String where = " %LIBS='SYSDEV'";

        if ((procedureNamePattern == null) || (procedureNamePattern.equalsIgnoreCase("%")))
            whereCluse = "WHERE" + where;
        else if ((procedureNamePattern.charAt(0) == '%') || (procedureNamePattern.charAt(procedureNamePattern.length() - 1) == '%'))
            whereCluse = "WHERE PROCID LIKE '" + procedureNamePattern + "' \n" + "AND" + where;
        else
            whereCluse = "WHERE PROCID ='" + procedureNamePattern + "' \n" + "AND" + where;

        String tableSchem = ".";
    /*
     [DBTBL25]
     %LIBS         %LIBS                                  T     12  1*           Lik
     DES           Description                            T     40  PROCID    1  Lik
     LTD           Last Modified                          D     10  PROCID    3  Lik
     MPLUS         PSL Format                             L      1  PROCID    9  Lik
     PFID          Access Files                           U     50  PROCID    8  Lik
     PGM           Run-time Routine                       U      8  PROCID    2  Lik
     PROCID        Procedure Name                         U     12  3*           Lik
     RPCVAR        List of variable names (RPC call)      T    250  PROCID    6  Lik
     RPCVAR1       List of variable names                 T    250  PROCID    7  Lik
     TIME          Time Last Updated                      C     10  PROCID    5  Lik
     USER          By User                                T     20  PROCID    4  Lik
     */

        query = "SELECT '','" + tableSchem + "',PROCID,'','','','','','','','','','' FROM DBTBL25 " + whereCluse;
        Statement s = connection.createStatement();

        ScJdbcResultSet rs = null;
        ScStatement ss = null;
        try {
            rs = (ScJdbcResultSet) s.executeQuery(query);
            ss = (ScStatement) s;
        } catch (Exception e) {
            return null;
        }

        String[] colName = {"PROCEDURE_CAT", "PROCEDURE_SCHEM", "PROCEDURE_NAME", "COLUMN_NAME", "COLUMN_TYPE", "DATA_TYPE", "TYPE_NAME", "PRECISION", "LENGTH", "SCALE", "RADIX", "NULLABLE", "REMARKS"};
        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    /**
     * @history zugarekdj 07-20-2004 11225
     * 	Added REMARKS as a returned element.
     **/
    public synchronized ResultSet getTables(String catalog, String schemaPattern, String tableNamePattern, String types[])
            throws SQLException {
        connection.log("ScDatabaseMetaData.getTables(" + catalog + "|" + schemaPattern + "|" + tableNamePattern + ")");
        //connection.log("ScDatabaseMetaData.getTables("+tableNamePattern+")");
        String query;
        String whereCluse = "";
        //String where=" %LIBS='SYSDEV' AND FILETYP<>5";
        String where = " %LIBS='SYSDEV'";
        if ((tableNamePattern == null) || (tableNamePattern.equalsIgnoreCase("%"))) whereCluse = "WHERE" + where;
        else if ((tableNamePattern.charAt(0) == '%') || (tableNamePattern.charAt(tableNamePattern.length() - 1) == '%'))
            whereCluse = "WHERE FID LIKE '" + tableNamePattern + "' \n" + "AND" + where;
        else whereCluse = "WHERE FID ='" + tableNamePattern + "' \n" + "AND" + where;

        //String tableSchem = connection.i_sUser;
        String tableSchem = "ProfileSchema";
        //String tableSchem = "profile";

        //jiaq
        query = "SELECT '','" + tableSchem + "',FID,'TABLE',DES,'','','','','' FROM DBTBL1 " + whereCluse + " ORDER BY FID";
        //query = "SELECT '','"+tableSchem+"',FID,DBCTLFILETYP.DES,DES FROM DBTBL1,DBCTLFILETYP "+whereCluse+" AND DBTBL1.FILETYP=DBCTLFILETYP.FILETYP ORDER BY FID";

        Statement s = connection.createStatement();

        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        ScStatement ss = (ScStatement) s;

        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "TABLE_TYPE", "REMARKS", "TYPE_CAT", "TYPE_SCHEM", "TYPE_NAME", "SELF_REFERENCING_COL_NAME", "REF_GENERATION"};
        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;

    }

    public ResultSet getSchemas() throws SQLException {
        connection.log("ScDatabaseMetaData.getSchemas");
        Statement s = connection.createStatement();

        String uid = connection.i_sUser;
        String basic_query = "SELECT 'ProfileSchema' FROM SCAU where UID='" + uid + "'";

        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(basic_query);

        ((ScStatement) s).description[0][1] = "TABLE_SCHEM";

        ((ScStatement) s).i_ahHash.clear();
        ((ScStatement) s).i_ahHash.put(new Integer("1"), "TABLE_SCHEM");
        rs.closeStatementOnClose = true;

        return rs;

    }

    public ResultSet getCatalogs() throws SQLException {
        connection.log("ScDatabaseMetaData.getCatalogs");
        Statement s = connection.createStatement();
        String query = "select fid  from dbtbl1 where fid = '%%%%hhh'";
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        ((ScStatement) s).description[0][1] = "TABLE_CAT";
        ((ScStatement) s).i_ahHash.clear();
        ((ScStatement) s).i_ahHash.put(new Integer("1"), "TABLE_CAT");
        rs.closeStatementOnClose = true;
        return rs;
    }

    public ResultSet getTableTypes()
            throws SQLException {
        connection.log("ScDatabaseMetaData.getTableTypes");
        Statement s = connection.createStatement();
        //String query = "select  FILETYP FROM DBCTLFILETYP";
        //String query = "select  'TABLE' FROM DBCTLFILETYP";
        String query = "select  DES FROM DBCTLFILETYP";
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        ((ScStatement) s).description[0][1] = "TABLE_TYPE";
        ((ScStatement) s).i_ahHash.clear();
        ((ScStatement) s).i_ahHash.put(new Integer("1"), "TABLE_TYPE");
        //  jiaq
        ((ScStatement) s).cells.removeAllElements();
        ((ScStatement) s).i_iTotalRows = 1;
        ((ScStatement) s).cells.updateElement(0, 0, "TABLE");
        //
        rs.closeStatementOnClose = true;
        return rs;

    }

    public synchronized ResultSet getColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getColumns(tableName" + tableNamePattern + ",columnName/" + columnNamePattern);

        if (tableNamePattern == null)
            tableNamePattern = "";
        if (columnNamePattern == null)
            columnNamePattern = "";

        if (!tableNamePattern.equalsIgnoreCase("")) {
            if (tableNamePattern.indexOf('%') > 0)
                tableNamePattern = " DBTBL1D.FID LIKE '" + tableNamePattern + "'\n";
            else
                tableNamePattern = " DBTBL1D.FID = '" + tableNamePattern + "'";
        }
        if (!columnNamePattern.equalsIgnoreCase("")) {
            if (columnNamePattern.indexOf('%') >= 0)
                columnNamePattern = " AND DBTBL1D.DI LIKE '" + columnNamePattern + "'\n ";
            else
                columnNamePattern = " AND DBTBL1D.DI = '" + columnNamePattern + "'";
        }

        String tableSchem = connection.i_sUser;
        String query = "SELECT null,'" + tableSchem + "',DBTBL1D.FID,DBTBL1D.DI," + "DBTBL1D.TYP,DBTBL1D.TYP,DBTBL1D.LEN,DBTBL1D.SIZ,DBTBL1D.DEC,10,DBTBL1D.REQ,DBTBL1D.DES,\n" + "DBTBL1D.DFT,1,1,DBTBL1D.LEN,DBTBL1D.POS,DBTBL1D.REQ,null,null,null,0 "
                + "\n FROM DBTBL1D \nWHERE " + tableNamePattern + columnNamePattern + " ORDER by nod,pos";

        Statement s = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM "

        String[] sTemPara1 = {"DBTBL1D", "TMP", "20", "", "T", "", "20", "0", "", ""};

        ScStatement ss = (ScStatement) s;
        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "COLUMN_NAME", "DATA_TYPE", "TYPE_NAME", "COLUMN_SIZE", "BUFFER_LENGTH", "DECIMAL_DIGITS", "NUM_PREC_RADIX", "NULLABLE", "REMARKS", "COLUMN_DEF", "SQL_DATA_TYPE", "SQL_DATETIME_SUB",
                "CHAR_OCTET_LENGTH", "ORDINAL_POSITION", "IS_NULLABLE", "SCOPE_CATALOG", "SCOPE_SCHEMA", "SCOPE_TABLE", "SOURCE_DATA_TYPE"};

        ResultSetMetaData mData = rs.getMetaData();

        ss.i_ahHash.clear();

        for (int i = 0; i < colName.length; i++) {

            if ((i == 4) || (i == 9) || (i == 14) || (i == 10) || (i == 21)) {
                String[] sTemPara2 = {"DBTBL1D", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara2;
            }
            if (i == 17) {
                String[] sTemPara2 = {"DBTBL1D", "TMP", "20", "", "T", "", "5", "0", "", ""};
                ss.description[i] = sTemPara2;
            }

            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);

        }

        rs.last();

        String sReq, sDec, sType;
        String[] returnType = new String[2];
        String colname;
        int isInt;
        for (int j = 0; j < ss.cells.rows(); j++) {
            colname = (String) ss.cells.elementAt(j, 3);
            isInt = 1;
            if (colname.startsWith("\"")) {
                ss.cells.removeRow(j);
                j--;
                continue;

            }

            try {
                Integer.parseInt(colname);
            } catch (Exception e) {
                isInt = 0;
            }
            if (isInt == 1) {
                ss.cells.removeRow(j);
                j--;
                continue;
            }

            sType = (String) ss.cells.elementAt(j, 4);
            sDec = (String) ss.cells.elementAt(j, 8);
            returnType = dataTypeConv(sType, sDec);

            sReq = (String) ss.cells.elementAt(j, 17);
            if (sReq.compareTo("1") == 0) {
                ss.cells.updateElement(j, 17, "NO");
                ss.cells.updateElement(j, 10, Integer.toString(columnNoNulls));
            } else if (sReq.compareTo("0") == 0) {
                ss.cells.updateElement(j, 17, "YES");
                ss.cells.updateElement(j, 10, Integer.toString(columnNullable));
            } else {
                ss.cells.updateElement(j, 17, "");
                ss.cells.updateElement(j, 10, Integer.toString(columnNullableUnknown));
            }
            ss.cells.updateElement(j, 4, returnType[1]);
            ss.cells.updateElement(j, 5, returnType[0]);
            ss.cells.updateElement(j, 16, String.valueOf((j + 1)));
        }
        ss.i_iTotalRows = ss.cells.rows();
        rs.beforeFirst();
        rs.closeStatementOnClose = true;
        return rs;
    }

    private String[] dataTypeConv(String sType, String sDec) {
        int type;
        if (sType.compareTo("L") == 0) {
            type = -7; //BIT
            sType = "BIT";
        } else if (sType.compareTo("B") == 0) {
            type = -2; //BINARY
            sType = "BINARY";
        } else if (sType.compareTo("D") == 0) {
            type = 91; //DATE
            sType = "DATE";
        } else if (sType.compareTo("C") == 0) {
            type = 92; //TIME
            sType = "TIME";
        } else if (sType.compareTo("$") == 0) {
            type = 3;    //CURRENCY //10/23/2003 MKT Changed to 99
            // 99 is not a valid data type
            sType = "CURRENCY";
        } else if ((sType.compareTo("T") == 0) || (sType.compareTo("M") == 0) || (sType.compareTo("U") == 0) || (sType.compareTo("F") == 0)) {
            type = 12; //VARCHAR
            sType = "VARCHAR";
        } else if (sType.compareTo("M") == 0) {
            type = java.sql.Types.LONGVARCHAR;
            sType = "LONGVARCHAR";
        } else if (sType.compareTo("N") == 0) {
            type = 2;
            sType = "NUMERIC";
        } else
            type = 1111;
        String[] returnType = {sType, String.valueOf(type)};
        return returnType;
    }

    /**
     *
     * Retrieves a description of the access rights for a table's columns.
     * Only privileges matching the column name criteria are returned. They are ordered by COLUMN_NAME and PRIVILEGE.
     *
     * Each privilige description has the following columns:
     *
     * TABLE_CAT String => table catalog (may be null)
     * TABLE_SCHEM String => table schema (may be null)
     * TABLE_NAME String => table name
     * COLUMN_NAME String => column name
     * GRANTOR => grantor of access (may be null)
     * GRANTEE String => grantee of access
     * PRIVILEGE String => name of access (SELECT, INSERT, UPDATE, REFRENCES, ...)
     * IS_GRANTABLE String => "YES" if grantee is permitted to grant to others; "NO" if not; null if unknown
     *
     * Parameters:
     * 	catalog - a catalog name; must match the catalog name as it is stored in the database; "" retrieves those without a catalog; null means that the catalog name should not be used to narrow the search
     * 	schema - a schema name; must match the schema name as it is stored in the database; "" retrieves those without a schema; null means that the schema name should not be used to narrow the search
     * 	table - a table name; must match the table name as it is stored in the database
     * 	columnNamePattern - a column name pattern; must match the column name as it is stored in the database
     *
     * @history zugarekd 07-21-2004 11225
     * 	Look at DBTBL14
     *
     **/
    public synchronized ResultSet getColumnPrivileges(String catalog, String schemaPattern, String table, String columnNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getTablePrivileges");

    /*
     [DBTBL14]
     DATE          Date Last Updated                      D     10  GROUP     6  Lik
     DESC          Description                            T     50  GROUP     1  Lik
     DINAM         Data Item                              U    256  4*           Lik
     FID           File Name                              U    256  3*           Lik
     FILDESC       File Name                              T     40               Lik
     GROUP         Group Code                             N      2  5*           Lik
     ITEMDESC      Data Item Description                  T     40               Lik
     PLIBS         Library                                T     12  1*           Lik
     PROT          Prot Flag                              N      1  GROUP     2  Lik
     PROTOPT       Protection Option                      T     10               Lik
     PROTPGM       Protection Routine Name                T      8               Lik
     QRYDESC       Query Description                      T     75  1         1  Lik
     QRYFLG        Query Flag                             L      1  GROUP     9  Lik
     RUCLS1        Restricted Userclass                   T     75  GROUP     3  Lik
     UID           User ID                                T     20  GROUP    15  Lik
   */

        String query;

        if (columnNamePattern == null)
            columnNamePattern = "";

        if (!columnNamePattern.equalsIgnoreCase("")) {
            if (columnNamePattern.indexOf('%') > 0)
                columnNamePattern = " DBTBL14.DINAM LIKE '" + columnNamePattern + "'\n";
            else
                columnNamePattern = " DBTBL14.DINAM = '" + columnNamePattern + "'";
        }

        query = "SELECT null,null,DBTBL14.FID,DBTBL14.DINAM,null," + "DBTBL14.RUCLS1,DBTBL14.PROT,null" + " FROM DBTBL14 WHERE " + columnNamePattern + " AND FID = '" + table + "'";

        Statement s = connection.createStatement();
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);

        ScStatement ss = (ScStatement) s;
        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "COLUMN_NAME", "GRANTOR", "GRANTEE", "PRIVILEGE", "IS_GRANTABLE"};

        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    /**
     *
     * Retrieves a description of the access rights for each table available in a catalog. Note that a table privilege applies to one or more columns in the table. It would be wrong to assume that this privilege applies to all columns (this may be true for some systems but is not true for all.)
     * Only privileges matching the schema and table name criteria are returned. They are ordered by TABLE_SCHEM, TABLE_NAME, and PRIVILEGE.
     *
     * Each privilige description has the following columns:
     * TABLE_CAT String => table catalog (may be null)
     * TABLE_SCHEM String => table schema (may be null)
     * TABLE_NAME String => table name
     * GRANTOR => grantor of access (may be null)
     * GRANTEE String => grantee of access
     * PRIVILEGE String => name of access (SELECT, INSERT, UPDATE, REFRENCES, ...)
     * IS_GRANTABLE String => "YES" if grantee is permitted to grant to others; "NO" if not; null if unknown
     *
     * Parameters:
     * 	catalog - a catalog name; must match the catalog name as it is stored in the database; "" retrieves those without a catalog; null means that the catalog name should not be used to narrow the search
     * 	schemaPattern - a schema name pattern; must match the schema name as it is stored in the database; "" retrieves those without a schema; null means that the schema name should not be used to narrow the search
     * 	tableNamePattern - a table name pattern; must match the table name as it is stored in the database
     *
     * @history zugarekd 07-21-2004 11225
     * 	Look at DBTBL14 where a "*" is used for DINAM
     *
     **/
    public synchronized ResultSet getTablePrivileges(String catalog, String schemaPattern, String tableNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getTablePrivileges");

    /*
     [DBTBL14]
     DATE          Date Last Updated                      D     10  GROUP     6  Lik
     DESC          Description                            T     50  GROUP     1  Lik
     DINAM         Data Item                              U    256  4*           Lik
     FID           File Name                              U    256  3*           Lik
     FILDESC       File Name                              T     40               Lik
     GROUP         Group Code                             N      2  5*           Lik
     ITEMDESC      Data Item Description                  T     40               Lik
     PLIBS         Library                                T     12  1*           Lik
     PROT          Prot Flag                              N      1  GROUP     2  Lik
     PROTOPT       Protection Option                      T     10               Lik
     PROTPGM       Protection Routine Name                T      8               Lik
     QRYDESC       Query Description                      T     75  1         1  Lik
     QRYFLG        Query Flag                             L      1  GROUP     9  Lik
     RUCLS1        Restricted Userclass                   T     75  GROUP     3  Lik
     UID           User ID                                T     20  GROUP    15  Lik
   */

        String query;

        if (tableNamePattern == null)
            tableNamePattern = "";

        if (!tableNamePattern.equalsIgnoreCase("")) {
            if (tableNamePattern.indexOf('%') > 0)
                tableNamePattern = " DBTBL14.FID LIKE '" + tableNamePattern + "'\n";
            else
                tableNamePattern = " DBTBL14.FID = '" + tableNamePattern + "'";
        }

        query = "SELECT null,null,DBTBL14.FID,null," + "DBTBL14.RUCLS1,DBTBL14.PROT,null" + " FROM DBTBL14 WHERE " + tableNamePattern + " AND DINAM = '*'";

        Statement s = connection.createStatement();
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);

        ScStatement ss = (ScStatement) s;
        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "GRANTOR", "GRANTEE", "PRIVILEGE", "IS_GRANTABLE"};

        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    /**
     *
     * Retrieves a description of a table's optimal set of columns that uniquely identifies a row. They are ordered by SCOPE.
     * Each column description has the following columns:
     *
     * SCOPE short => actual scope of result
     * 	bestRowTemporary - very temporary, while using row
     * 	bestRowTransaction - valid for remainder of current transaction
     *	bestRowSession - valid for remainder of current session
     * COLUMN_NAME String => column name
     * DATA_TYPE int => SQL data type from java.sql.Types
     * TYPE_NAME String => Data source dependent type name, for a UDT the type name is fully qualified
     * COLUMN_SIZE int => precision
     * BUFFER_LENGTH int => not used
     * DECIMAL_DIGITS short => scale
     * PSEUDO_COLUMN short => is this a pseudo column like an Oracle ROWID
     * 	bestRowUnknown - may or may not be pseudo column
     * 	bestRowNotPseudo - is NOT a pseudo column
     * 	bestRowPseudo - is a pseudo column
     *
     * Parameters:
     * 	catalog - a catalog name; must match the catalog name as it is stored in the database; "" retrieves those without a catalog; null means that the catalog name should not be used to narrow the search
     * 	schema - a schema name; must match the schema name as it is stored in the database; "" retrieves those without a schema; null means that the schema name should not be used to narrow the search
     * 	table - a table name; must match the table name as it is stored in the database
     * 	scope - the scope of interest; use same values as SCOPE
     * 	nullable - include columns that are nullable.
     *
     * @history zugarekd 07-21-2004 11225
     * 	A list of primary keys is the best identifier.
     *
     **/
    public synchronized ResultSet getBestRowIdentifier(String catalog, String schema, String table, int scope, boolean nullable) throws SQLException {
        connection.log("ScDatabaseMetaData.getBestRowIdentifier");
        ResultSet keys = getPrimaryKeys(catalog, schema, table);

        String inStatement = " FID = '" + table + "' AND DI IN (";
        while (keys.next()) {
            inStatement = inStatement + "'" + keys.getString("COLUMN_NAME") + "',";
        }
        keys.close();
        inStatement = inStatement.substring(0, inStatement.length() - 1) + ")";

        String select = "SELECT '', DI, DOM, ITP, LEN, '', DEC, '' FROM DBTBL1D WHERE " + inStatement;
    /*
     [DBTBL1D]
     %LIBS         Library Name                           T     12  1*           Lik
     CMP           Computed Expression                    T    255  DI       16  Lik
     CNV           Conversion Flag                        N      2  DI       24  Lik
     DEC           Decimal Precision                      N      2  DI       14  Lik
     DEL           Delimeter                              N      3  DI       20  Lik
     DEPOSTP       Data Entry Post-Processor              T    255  DI       30  Lik
     DEPREP        Data Entry Pre-Processor               T    255  DI       29  Lik
     DES           Description                            T     40  DI       10  Lik
     DFT           Default Value                          T     58  DI        3  Lik
     DI            Data Item Name                         U    256  5*           Lik
     DOM           User-Defined Data Type                 U     20  DI        4  Lik
     FID           File Name                              U    256  3*           Lik
     ITP           Internal Data Type                     T      1  DI       11  Lik
     LEN           Maximum Field Length                   N      5  DI        2  Lik
     LTD           Last Updated                           D     10  DI       25  Lik
     MAX           Maximum Value                          T     25  DI       13  Lik
     MDD           Master Dictionary Reference            U     12  DI       27  Lik
     MDDFID        Master Dictionary File Name            T     12            1  Lik
     MIN           Minimum Value                          T     25  DI       12  Lik
     NOD           Subscript Key                          T     26  DI        1  Lik
     NULLIND       Null Vs. Zero Indicator                L      1  DI       31  Lik
     POS           Field Position                         N      2  DI       21  Lik
     PTN           MUMPS Pattern Match                    T     60  DI        6  Lik
     REQ           Required Indicator                     L      1  DI       15  Lik
     RHD           Report Header                          T     40  DI       22  Lik
     SFD           Sub Field Definition                   T     20  DI       18  Lik
     SFD1          Sub-Field Delimiter (Tag Prefix)       N      3  DI       18  Lik
     SFD2          Sub-Field Delimiter (Tag Suffix)       N      3  DI       18  Lik
     SFP           Sub-Field Position                     N      2  DI       18  Lik
     SFT           Sub-Field Tag                          U     12  DI       18  Lik
     SIZ           Field Display Size                     N      3  DI       19  Lik
     SRL           Serial Value                           L      1  DI       23  Lik
     TBL           Look-Up Table Name                     T    255  DI        5  Lik
     TYP           Data Type                              U      1  DI        9  Lik
     USER          User ID                                T     20  DI       26  Lik
     VAL4EXT       Valid for Extraction                   L      1  DI       28  Lik
     VALIDCMP      Validate the CMP field syntax          L      1               Lik
     XPO           Post Processor expression              T     58  DI        7  Lik
     XPR           Pre Processor Expression               T     58  DI        8  Lik
     */

        Statement s = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(select);

        ScStatement statement = (ScStatement) s;
        String[] colName = {"SCOPE", "COLUMN_NAME", "DATA_TYPE", "TYPE_NAME", "COLUMN_SIZE", "BUFFER_LENGTH", "DECIMAL_DIGITS", "PSEUDO_COLUMN"};

        statement.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {
            statement.i_ahHash.put(new Integer(i + 1), colName[i]);
            statement.description[i][1] = new String(colName[i]);
        }

        return rs;
    }

    public synchronized ResultSet getVersionColumns(String catalog, String schema, String tableNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getVersionColumns");
        String query;

        if (tableNamePattern == null)
            tableNamePattern = "";

        if (!tableNamePattern.equalsIgnoreCase("")) {
            if (tableNamePattern.indexOf('%') > 0)
                tableNamePattern = " DBTBL1D.FID LIKE '" + tableNamePattern + "'\n";
            else
                tableNamePattern = " DBTBL1D.FID = '" + tableNamePattern + "'";
        }

        query = "SELECT 1,DBTBL1D.DI,1,DBTBL1D.TYP," + "DBTBL1D.LEN,DBTBL1D.LEN,DBTBL1D.DEC,0" + "\n FROM DBTBL1D \nWHERE " + tableNamePattern + " AND DBTBL1D.CMP<>''";

        Statement s = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM "

        ScStatement ss = (ScStatement) s;
        String[] colName = {"SCOPE", "COLUMN_NAME", "DATA_TYPE", "TYPE_NAME", "COLUMN_SIZE", "BUFFER_LENGTH", "DECIMAL_DIGITS", "PSEUDO_COLUMN"};

        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {

            if ((i == 2) || (i == 7)) {
                String[] sTemPara2 = {"DBTBL1D", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara2;
            }
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);
        }

        rs.last();

        String sReq, sDec, sType;
        String[] returnType = new String[2];
        for (int j = 0; j < ss.cells.rows(); j++) {
            sType = (String) ss.cells.elementAt(j, 3);
            sDec = (String) ss.cells.elementAt(j, 6);
            returnType = dataTypeConv(sType, sDec);
            ss.cells.updateElement(j, 2, returnType[1]);
            ss.cells.updateElement(j, 3, returnType[0]);

        }
        rs.beforeFirst();
        rs.closeStatementOnClose = true;
        return rs;
    }

    public ResultSet getPrimaryKeys(String catalog, String schemaPattern, String tableNamePattern) throws SQLException {

        connection.log("ScDatabaseMetaData.getPrimaryKeys(tableName/" + tableNamePattern);

        String query = "EXECUTE $$KEYCOL^SQLODBC(" + "\"" + tableNamePattern + "\"" + ")";

        Statement s = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        rs.absolute(1);
        String key = rs.getString(1);

        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "COLUMN_NAME", "KEY_SEQ", "PK_NAME"};
        ScStatement ss = (ScStatement) s;
        ss.i_ahHash.clear();
        ss.description = new String[6][10];

        for (int i = 0; i < colName.length; i++) {
            if (i == 4) {
                String[] sTemPara1 = {"DBTBL1D", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara1;
            }

            String[] sTemPara1 = {"DBTBL1D", "TMP", "20", "", "T", "", "20", "0", "", ""};
            ss.description[i] = sTemPara1;
            ss.description[i][1] = colName[i];
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
        }

        java.util.StringTokenizer parser = new java.util.StringTokenizer(key, ",", false);
        String pkCol;
        int i = 0;
        int j = 0;

        String tableSchem = connection.i_sUser;
        ss.cells.removeAllElements();
        while (parser.hasMoreTokens()) {
            pkCol = ((String) (parser.nextToken())).trim();
            i = pkCol.indexOf('.');
            ss.cells.addElement(j, 0, "");
            ss.cells.addElement(j, 1, tableSchem);
            ss.cells.addElement(j, 2, tableNamePattern.toUpperCase());
            ss.cells.addElement(j, 3, pkCol.substring(i + 1));
            ss.cells.addElement(j, 4, Integer.toString((j + 1)));
            ss.cells.addElement(j, 5, pkCol.substring(i + 1));

            j++;
        }
        ss.i_iTotalRows = ss.cells.rows();
        rs.beforeFirst();
        rs.closeStatementOnClose = true;
        return rs;
    }

    private ResultSet DBTBL1F(String tableNamePattern) throws SQLException {
        String tableSchem = connection.i_sUser;

        String query = "SELECT %LIBS,'" + tableSchem + "',TBLREF,PKEYS,NULL,NULL,FID,FKEYS,1,UPD,DEL,FKEYS,PKEYS,1 \n" + "FROM DBTBL1F " + tableNamePattern;

        Statement s = connection.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);

        String[] colName = {"PKTABLE_CAT", "PKTABLE_SCHEM", "PKTABLE_NAME", "PKCOLUMN_NAME", "FKTABLE_CAT", "FKTABLE_SCHEM", "FKTABLE_NAME", "FKCOLUMN_NAME", "KEY_SEQ", "UPDATE_RULE", "DELETE_RULE", "FK_NAME", "PK_NAME", "DEFERRABILITY"};
        ScStatement ss = (ScStatement) s;
        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {

            if (i == 13) {
                String[] sTemPara1 = {"DBTBL1D", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara1;
            }
            ss.description[i][1] = colName[i];
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    /**
     * Gets a description of the primary key columns that are
     * referenced by a table's foreign key columns (the primary keys
     * imported by a table).  They are ordered by PKTABLE_CAT,
     * PKTABLE_SCHEM, PKTABLE_NAME, and KEY_SEQ.
     *
     * <P>Each primary key column description has the following columns:
     *  <OL>
     *	<LI><B>PKTABLE_CAT</B> String => primary key table catalog
     *      being imported (may be null)
     *	<LI><B>PKTABLE_SCHEM</B> String => primary key table schema
     *      being imported (may be null)
     *	<LI><B>PKTABLE_NAME</B> String => primary key table name
     *      being imported
     *	<LI><B>PKCOLUMN_NAME</B> String => primary key column name
     *      being imported
     *	<LI><B>FKTABLE_CAT</B> String => foreign key table catalog (may be null)
     *	<LI><B>FKTABLE_SCHEM</B> String => foreign key table schema (may be null)
     *	<LI><B>FKTABLE_NAME</B> String => foreign key table name
     *	<LI><B>FKCOLUMN_NAME</B> String => foreign key column name
     *	<LI><B>KEY_SEQ</B> short => sequence number within foreign key
     *	<LI><B>UPDATE_RULE</B> short => What happens to
     *       foreign key when primary is updated:
     *      <UL>
     *      <LI> importedNoAction - do not allow update of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - change imported key to agree
     *               with primary key update
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been updated
     *      <LI> importedKeySetDefault - change imported key to default values
     *               if its primary key has been updated
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      </UL>
     *	<LI><B>DELETE_RULE</B> short => What happens to
     *      the foreign key when primary is deleted.
     *      <UL>
     *      <LI> importedKeyNoAction - do not allow delete of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - delete rows that import a deleted key
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been deleted
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      <LI> importedKeySetDefault - change imported key to default if
     *               its primary key has been deleted
     *      </UL>
     *	<LI><B>FK_NAME</B> String => foreign key name (may be null)
     *	<LI><B>PK_NAME</B> String => primary key name (may be null)
     *	<LI><B>DEFERRABILITY</B> short => can the evaluation of foreign key
     *      constraints be deferred until commit
     *      <UL>
     *      <LI> importedKeyInitiallyDeferred - see SQL92 for definition
     *      <LI> importedKeyInitiallyImmediate - see SQL92 for definition
     *      <LI> importedKeyNotDeferrable - see SQL92 for definition
     *      </UL>
     *  </OL>
     *
     * @param catalog a catalog name; "" retrieves those without a
     * catalog; null means drop catalog name from the selection criteria
     * @param schema a schema name; "" retrieves those
     * without a schema
     * @param table a table name
     * @return ResultSet - each row is a primary key column description
     * @exception SQLException if a database access error occurs
     * @see #getExportedKeys
     */

    public synchronized ResultSet getImportedKeys(String catalog, String schema, String table) throws SQLException {
        connection.log("ScDatabaseMetaData.getImportedKeys");
        String tableNamePattern = "";
        if (table == null)
            table = "";
        if (!table.equalsIgnoreCase("")) {
            if (table.indexOf('%') > 0)
                tableNamePattern = " WHERE FID LIKE '" + table + "' \n";
            else
                tableNamePattern = " WHERE FID = '" + table + "' ";
        }

        return DBTBL1F(tableNamePattern);
    }

    /**
     * Gets a description of the foreign key columns that reference a
     * table's primary key columns (the foreign keys exported by a
     * table).  They are ordered by FKTABLE_CAT, FKTABLE_SCHEM,
     * FKTABLE_NAME, and KEY_SEQ.
     *
     * <P>Each foreign key column description has the following columns:
     *  <OL>
     *	<LI><B>PKTABLE_CAT</B> String => primary key table catalog (may be null)
     *	<LI><B>PKTABLE_SCHEM</B> String => primary key table schema (may be null)
     *	<LI><B>PKTABLE_NAME</B> String => primary key table name
     *	<LI><B>PKCOLUMN_NAME</B> String => primary key column name
     *	<LI><B>FKTABLE_CAT</B> String => foreign key table catalog (may be null)
     *      being exported (may be null)
     *	<LI><B>FKTABLE_SCHEM</B> String => foreign key table schema (may be null)
     *      being exported (may be null)
     *	<LI><B>FKTABLE_NAME</B> String => foreign key table name
     *      being exported
     *	<LI><B>FKCOLUMN_NAME</B> String => foreign key column name
     *      being exported
     *	<LI><B>KEY_SEQ</B> short => sequence number within foreign key
     *	<LI><B>UPDATE_RULE</B> short => What happens to
     *       foreign key when primary is updated:
     *      <UL>
     *      <LI> importedNoAction - do not allow update of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - change imported key to agree
     *               with primary key update
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been updated
     *      <LI> importedKeySetDefault - change imported key to default values
     *               if its primary key has been updated
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      </UL>
     *	<LI><B>DELETE_RULE</B> short => What happens to
     *      the foreign key when primary is deleted.
     *      <UL>
     *      <LI> importedKeyNoAction - do not allow delete of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - delete rows that import a deleted key
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been deleted
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      <LI> importedKeySetDefault - change imported key to default if
     *               its primary key has been deleted
     *      </UL>
     *	<LI><B>FK_NAME</B> String => foreign key name (may be null)
     *	<LI><B>PK_NAME</B> String => primary key name (may be null)
     *	<LI><B>DEFERRABILITY</B> short => can the evaluation of foreign key
     *      constraints be deferred until commit
     *      <UL>
     *      <LI> importedKeyInitiallyDeferred - see SQL92 for definition
     *      <LI> importedKeyInitiallyImmediate - see SQL92 for definition
     *      <LI> importedKeyNotDeferrable - see SQL92 for definition
     *      </UL>
     *  </OL>
     *
     * @param catalog a catalog name; "" retrieves those without a
     * catalog; null means drop catalog name from the selection criteria
     * @param schema a schema name; "" retrieves those
     * without a schema
     * @param table a table name
     * @return ResultSet - each row is a foreign key column description
     * @exception SQLException if a database access error occurs
     * @see #getImportedKeys
     */

    public ResultSet getExportedKeys(String catalog, String schema, String table) throws SQLException {
        connection.log("ScDatabaseMetaData.getExportedKeys");
        String tableNamePattern = "";
        if (table == null)
            table = "";
        if (!table.equalsIgnoreCase("")) {
            if (table.indexOf('%') > 0)
                tableNamePattern = " WHERE TBLREF LIKE '" + table + "' \n";
            else
                tableNamePattern = " WHERE TBLREF = '" + table + "' ";
        }

        return DBTBL1F(tableNamePattern);
    }

    /**
     * Gets a description of the foreign key columns in the foreign key
     * table that reference the primary key columns of the primary key
     * table (describe how one table imports another's key.) This
     * should normally return a single foreign key/primary key pair
     * (most tables only import a foreign key from a table once.)  They
     * are ordered by FKTABLE_CAT, FKTABLE_SCHEM, FKTABLE_NAME, and
     * KEY_SEQ.
     *
     * <P>Each foreign key column description has the following columns:
     *  <OL>
     *	<LI><B>PKTABLE_CAT</B> String => primary key table catalog (may be null)
     *	<LI><B>PKTABLE_SCHEM</B> String => primary key table schema (may be null)
     *	<LI><B>PKTABLE_NAME</B> String => primary key table name
     *	<LI><B>PKCOLUMN_NAME</B> String => primary key column name
     *	<LI><B>FKTABLE_CAT</B> String => foreign key table catalog (may be null)
     *      being exported (may be null)
     *	<LI><B>FKTABLE_SCHEM</B> String => foreign key table schema (may be null)
     *      being exported (may be null)
     *	<LI><B>FKTABLE_NAME</B> String => foreign key table name
     *      being exported
     *	<LI><B>FKCOLUMN_NAME</B> String => foreign key column name
     *      being exported
     *	<LI><B>KEY_SEQ</B> short => sequence number within foreign key
     *	<LI><B>UPDATE_RULE</B> short => What happens to
     *       foreign key when primary is updated:
     *      <UL>
     *      <LI> importedNoAction - do not allow update of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - change imported key to agree
     *               with primary key update
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been updated
     *      <LI> importedKeySetDefault - change imported key to default values
     *               if its primary key has been updated
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      </UL>
     *	<LI><B>DELETE_RULE</B> short => What happens to
     *      the foreign key when primary is deleted.
     *      <UL>
     *      <LI> importedKeyNoAction - do not allow delete of primary
     *               key if it has been imported
     *      <LI> importedKeyCascade - delete rows that import a deleted key
     *      <LI> importedKeySetNull - change imported key to NULL if
     *               its primary key has been deleted
     *      <LI> importedKeyRestrict - same as importedKeyNoAction
     *                                 (for ODBC 2.x compatibility)
     *      <LI> importedKeySetDefault - change imported key to default if
     *               its primary key has been deleted
     *      </UL>
     *	<LI><B>FK_NAME</B> String => foreign key name (may be null)
     *	<LI><B>PK_NAME</B> String => primary key name (may be null)
     *	<LI><B>DEFERRABILITY</B> short => can the evaluation of foreign key
     *      constraints be deferred until commit
     *      <UL>
     *      <LI> importedKeyInitiallyDeferred - see SQL92 for definition
     *      <LI> importedKeyInitiallyImmediate - see SQL92 for definition
     *      <LI> importedKeyNotDeferrable - see SQL92 for definition
     *      </UL>
     *  </OL>
     *
     * @param primaryCatalog a catalog name; "" retrieves those without a
     * catalog; null means drop catalog name from the selection criteria
     * @param primarySchema a schema name; "" retrieves those
     * without a schema
     * @param primaryTable the table name that exports the key
     * @param foreignCatalog a catalog name; "" retrieves those without a
     * catalog; null means drop catalog name from the selection criteria
     * @param foreignSchema a schema name; "" retrieves those
     * without a schema
     * @param foreignTable the table name that imports the key
     * @return ResultSet - each row is a foreign key column description
     * @exception SQLException if a database access error occurs
     * @see #getImportedKeys
     */

    public ResultSet getCrossReference(String primaryCatalog, String primarySchema, String primaryTable, String foreignCatalog, String foreignSchema, String foreignTable) throws SQLException {
        connection.log("ScDatabaseMetaData.getCrossReference");
        if (primaryTable == null)
            primaryTable = "";
        if (foreignTable == null)
            foreignTable = "";

        String tableNamePattern = "";

        if (!primaryTable.equalsIgnoreCase("")) {
            if (primaryTable.indexOf('%') > 0)
                tableNamePattern = " WHERE TBLREF LIKE '" + primaryTable + "' \n";
            else
                tableNamePattern = " WHERE TBLREF = '" + primaryTable + "' ";
        }

        if (!foreignTable.equalsIgnoreCase("")) {
            if (tableNamePattern.length() > 0)
                tableNamePattern = tableNamePattern + " AND FID ";
            else
                tableNamePattern = " WHERE FID ";
            if (foreignTable.indexOf('%') > 0)
                tableNamePattern = tableNamePattern + "  LIKE '" + foreignTable + "' \n";
            else
                tableNamePattern = tableNamePattern + "  = '" + foreignTable + "' ";
        }

        return DBTBL1F(tableNamePattern);

    }

    /**
     *
     * Retrieves a description of all the standard SQL types supported by this database. They are ordered by DATA_TYPE and then by how closely the data type maps to the corresponding JDBC SQL type.
     * Each type description has the following columns:
     *
     * TYPE_NAME String => Type name
     * DATA_TYPE int => SQL data type from java.sql.Types
     * PRECISION int => maximum precision
     * LITERAL_PREFIX String => prefix used to quote a literal (may be null)
     * LITERAL_SUFFIX String => suffix used to quote a literal (may be null)
     * CREATE_PARAMS String => parameters used in creating the type (may be null)
     * NULLABLE short => can you use NULL for this type.
     * 	typeNoNulls - does not allow NULL values
     * 	typeNullable - allows NULL values
     * 	typeNullableUnknown - nullability unknown
     * CASE_SENSITIVE boolean=> is it case sensitive.
     * SEARCHABLE short => can you use "WHERE" based on this type:
     * 	typePredNone - No support
     * 	typePredChar - Only supported with WHERE .. LIKE
     * 	typePredBasic - Supported except for WHERE .. LIKE
     * 	typeSearchable - Supported for all WHERE ..
     * UNSIGNED_ATTRIBUTE boolean => is it unsigned.
     * FIXED_PREC_SCALE boolean => can it be a money value.
     * AUTO_INCREMENT boolean => can it be used for an auto-increment value.
     * LOCAL_TYPE_NAME String => localized version of type name (may be null)
     * MINIMUM_SCALE short => minimum scale supported
     * MAXIMUM_SCALE short => maximum scale supported
     * SQL_DATA_TYPE int => unused
     * SQL_DATETIME_SUB int => unused
     * NUM_PREC_RADIX int => usually 2 or 10
     *
     * @history zugarekdj 07-20-2004 11225
     * 	Changed NUM_PRE_RADIX to NUM_PREC_RADIX
     *
     **/
    public ResultSet getTypeInfo() throws SQLException {
        connection.log("ScDatabaseMetaData.getTypeInfo");
        String query = "SELECT DES,TYP,LEN,'','','',1,0,3,1,0,0,'',0,0,0,0,0 " + "FROM DBCTLDVFM";

        Statement s = connection.createStatement();

        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);
        ScStatement ss = (ScStatement) s;

        String[] colName = {"TYPE_NAME", "DATA_TYPE", "PRECISION", "LITERAL_PREFIX", "LITERAL_SUFFIX", "CREATE_PARAMS", "NULLABLE", "CASE_SENSITIVE", "SEARCHABLE", "UNSIGNED_ATTRIBUTE", "FIXED_PREC_SCALE", "AUTO_INCREMENT", "LOCAL_TYPE_NAME",
                "MINIMUM_SCALE", "MAXIMUM_SCALE", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "NUM_PREC_RADIX"};

        for (int i = 0; i < colName.length; i++) {
            if ((i == 1) || (i == 2) || (i == 6) || (i == 8) || (i > 13)) {
                String[] sTemPara1 = {"TYPEINF", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara1;
            } else if ((i == 7) || (i == 9) || (i == 10) || (i == 11)) {
                String[] sTemPara2 = {"TYPEINF", "TMP", "20", "", "L", "", "1", "0", "", ""};
                ss.description[i] = sTemPara2;
            } else {
                String[] sTemPara3 = {"TYPEINF", "TMP", "20", "", "T", "", "20", "0", "", ""};
                ss.description[i] = sTemPara3;
            }
            ss.description[i][1] = colName[i];
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
        }

        String sType;
        int type;
        int caseSensitive = 0;
        int searchable = 3;
        int unsigned = 1;
        int fixedPrecScale = 0;
        int miniScale = 0;
        int maxScale = 20;
    /* data type supported by PROFILE/Anyware
     I typ="NUMERIC" Q "N"
     I typ="NUMBER" Q "N"
     I typ="CHAR" Q "T"
     I typ="VARCHAR" Q "T"
     I typ="VARCHAR2" Q "T"
     I typ="INTEGER" S colsize=5,dec=2 Q "N"
     I typ="SMALLINT" Q "N"
     I typ="TIMESTAMP" Q "X"
     I typ="DATE" Q "D"
     I typ="TIME" Q "C"
     I typ="LONG" Q "B"
     I typ="REAL" S colsize=7,dec=2 Q "N"
     I typ="FLOAT" S colsiz=15,dec=2 Q "N"

     $  Currency
     B  Binary
     C  Clock Time
     D  Date
     F  Frequency
     L  Logical
     M  Memo
     N  Numeric
     T  Text
     U  Upper Case
     */
        for (int j = 0; j < ss.cells.rows(); j++) {
            sType = (String) ss.cells.elementAt(j, 1);
            if (sType.compareTo("L") == 0) {
                sType = "INTEGER";
                type = -7; //BIT
            } else if (sType.compareTo("B") == 0) {
                type = -2; //BINARY
                sType = "VARCHAR2";
                searchable = 0;
            } else if (sType.compareTo("D") == 0) {
                type = 91;
                sType = "DATE";
                //DATE
            } else if (sType.compareTo("C") == 0) {
                type = 92; //TIME
                sType = "TIME";
            } else if (sType.compareTo("$") == 0) {
                type = 3;   //CURRENCY //10/23/2003 MKT Changed to 99
                // 99 is not a valid data type
                searchable = 3;
                unsigned = 0;
                fixedPrecScale = 1;
                maxScale = 2;
                sType = "CURRENCY";
            } else if ((sType.compareTo("T") == 0) || (sType.compareTo("M") == 0) || (sType.compareTo("U") == 0) || (sType.compareTo("F") == 0)) {
                type = 12; //VARCHAR
                sType = "VARCHAR";
                caseSensitive = 1;
                if (sType.compareTo("M") == 0)
                    searchable = 0;
            } else if (sType.compareTo("N") == 0) {
                type = 2; // NUMERIC
                unsigned = 0;
                fixedPrecScale = 1;
                maxScale = 20;
                sType = "NUMERIC";

            } else if (sType.compareTo("X") == 0) {
                type = 93; //TIME
                sType = "TIMESTAMP";
            } else
                type = 1111; //unknown

      /*
       7:caseSensitive=0;
       8:searchable=3;
       9:unsigned=1;
       10:fixedPrecScale=0;
       13:miniScale=0;
       14:maxScale=0;
       */
            ss.cells.updateElement(j, 1, String.valueOf(type));
            ss.cells.updateElement(j, 7, String.valueOf(caseSensitive));
            ss.cells.updateElement(j, 8, String.valueOf(searchable));
            ss.cells.updateElement(j, 9, String.valueOf(unsigned));
            ss.cells.updateElement(j, 10, String.valueOf(fixedPrecScale));
            ss.cells.updateElement(j, 13, String.valueOf(miniScale));
            ss.cells.updateElement(j, 14, String.valueOf(maxScale));

            ss.cells.updateElement(j, 0, sType);
        }

        rs.closeStatementOnClose = true;
        return rs;

    }

    /**
     * @history zugarekdj 07-21-2004 11225
     * 	Changed "INDEX_QUALIFILER" to "INDEX_QUALIFIER"
     **/
    public synchronized ResultSet getIndexInfo(String catalog, String schema, String table, boolean unique, boolean approximate) throws SQLException {
        connection.log("ScDatabaseMetaData.getIndexInfo");
        String tableSchem = connection.i_sUser;

        String tableNamePattern = "";
        if (table == null)
            table = "";
        if (!table.equalsIgnoreCase("")) {
            if (table.indexOf('%') > 0)
                tableNamePattern = " WHERE DBTBL8.FID LIKE '" + table + "' \n";
            else
                tableNamePattern = " WHERE DBTBL8.FID = '" + table + "' ";
        }
        String query = "SELECT null,'" + tableSchem + "',DBTBL8.FID,0,null,DBTBL8.INDEXNM,\n" + "3,0,DBTBL8.ORDERBY,'A',0,0,null from dbtbl8 " + tableNamePattern;

        Statement s = connection.createStatement();
        ScJdbcResultSet rs = (ScJdbcResultSet) s.executeQuery(query);

        //FID,DI,LEN,DFT,TYP,DES,SIZ,REQ,DEC,NOD FROM "

        ScStatement ss = (ScStatement) s;
        String[] colName = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "NON_UNIQUE", "INDEX_QUALIFIER", "INDEX_NAME", "TYPE", "ORDINAL_POSITION", "COLUMN_NAME", "ASC_OR_DESC", "CARDINALITY", "PAGES", "FILTER_CONDITION"};

        ss.i_ahHash.clear();
        for (int i = 0; i < colName.length; i++) {

            if ((i == 6) || (i == 7) || (i == 11)) {
                String[] sTemPara2 = {"DBTBL8", "TMP", "20", "", "N", "", "20", "0", "", ""};
                ss.description[i] = sTemPara2;
            }
            ss.i_ahHash.put(new Integer(i + 1), colName[i]);
            ss.description[i][1] = new String(colName[i]);

        }
        rs.closeStatementOnClose = true;
        return rs;
    }

    SQLException fail() {
        SQLException ex = new SQLException("Not implemented yet");
        return ex;
    }

    //--------------------------JDBC 2.0-----------------------------

    /**
     * JDBC 2.0
     *
     * Does the database support the given result set type?
     *
     * @param type defined in <code>java.sql.ResultSet</code>
     * @return <code>true</code> if so; <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     * @see Connection
     */
    public boolean supportsResultSetType(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.supportsResultSetType");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Does the database support the concurrency type in combination
     * with the given result set type?
     *
     * @param type defined in <code>java.sql.ResultSet</code>
     * @param concurrency type defined in <code>java.sql.ResultSet</code>
     * @return <code>true</code> if so; <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     * @see Connection
     */
    public boolean supportsResultSetConcurrency(int type, int concurrency) throws SQLException {
        connection.log("ScDatabaseMetaData.supportsResultSetConcurrency");
        return true;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether a result set's own updates are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if updates are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean ownUpdatesAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.ownUpdatesAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether a result set's own deletes are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if deletes are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean ownDeletesAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.ownDeletesAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether a result set's own inserts are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if inserts are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean ownInsertsAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.ownInsertsAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether updates made by others are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if updates made by others
     * are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean othersUpdatesAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.othersUpdatesAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether deletes made by others are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if deletes made by others
     * are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean othersDeletesAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.othersDeletesAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether inserts made by others are visible.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return true if updates are visible for the result set type
     * @return <code>true</code> if inserts made by others
     * are visible for the result set type;
     *        <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean othersInsertsAreVisible(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.othersInsertsAreVisible");
        return false;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether or not a visible row update can be detected by
     * calling the method <code>ResultSet.rowUpdated</code>.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return <code>true</code> if changes are detected by the result set type;
     *         <code>false</code> otherwise
     * @exception SQLException if a database access error occurs
     */
    public boolean updatesAreDetected(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.updatesAreDetected");
        return true;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether or not a visible row delete can be detected by
     * calling ResultSet.rowDeleted().  If deletesAreDetected()
     * returns false, then deleted rows are removed from the result set.
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return true if changes are detected by the resultset type
     * @exception SQLException if a database access error occurs
     */
    public boolean deletesAreDetected(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.deletesAreDetected");
        return true;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether or not a visible row insert can be detected
     * by calling ResultSet.rowInserted().
     *
     * @param result set type, i.e. ResultSet.TYPE_XXX
     * @return true if changes are detected by the resultset type
     * @exception SQLException if a database access error occurs
     */
    public boolean insertsAreDetected(int type) throws SQLException {
        connection.log("ScDatabaseMetaData.insertsAreDetected");
        return true;
    }

    /**
     * JDBC 2.0
     *
     * Indicates whether the driver supports batch updates.
     * @return true if the driver supports batch updates; false otherwise
     */
    public boolean supportsBatchUpdates() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsBatchUpdates");
        return true;
    }

    /**
     *
     * Retrieves a description of the user-defined types (UDTs) defined in a particular schema. Schema-specific UDTs may have type JAVA_OBJECT, STRUCT, or DISTINCT.
     * Only types matching the catalog, schema, type name and type criteria are returned. They are ordered by DATA_TYPE, TYPE_SCHEM and TYPE_NAME. The type name parameter may be a fully-qualified name. In this case, the catalog and schemaPattern parameters are ignored.
     *
     * Each type description has the following columns:
     *
     * TYPE_CAT String => the type's catalog (may be null)
     * TYPE_SCHEM String => type's schema (may be null)
     * TYPE_NAME String => type name
     * CLASS_NAME String => Java class name
     * DATA_TYPE int => type value defined in java.sql.Types. One of JAVA_OBJECT, STRUCT, or DISTINCT
     * REMARKS String => explanatory comment on the type
     * BASE_TYPE short => type code of the source type of a DISTINCT type or the type that implements the user-generated reference type of the SELF_REFERENCING_COLUMN of a structured type as defined in java.sql.Types (null if DATA_TYPE is not DISTINCT or not STRUCT with REFERENCE_GENERATION = USER_DEFINED)
     *
     * Note: If the driver does not support UDTs, an empty result set is returned.
     *
     * Parameters:
     * 	catalog - a catalog name; must match the catalog name as it is stored in the database; "" retrieves those without a catalog; null means that the catalog name should not be used to narrow the search
     * 	schemaPattern - a schema pattern name; must match the schema name as it is stored in the database; "" retrieves those without a schema; null means that the schema name should not be used to narrow the search
     * 	typeNamePattern - a type name pattern; must match the type name as it is stored in the database; may be a fully qualified name
     * 	types - a list of user-defined types (JAVA_OBJECT, STRUCT, or DISTINCT) to include; null returns all types
     *
     * @history zugarekd 07-21-2004 11225
     * See "Note" above.  An empty result set is returned not a null result.
     *
     **/
    public ResultSet getUDTs(String catalog, String schemaPattern, String typeNamePattern, int[] types) throws SQLException {
        connection.log("ScDatabaseMetaData.getUDTs");

        String[] columns = {"TYPE_CAT", "TYPE_SCHEM", "TYPE_NAME", "CLASS_NAME", "DATA_TYPE", "REMARKS"};

        ScJdbcResultSet empty = new ScJdbcResultSet(connection, (ScStatement) connection.createStatement());
        empty.closeStatementOnClose = true;

        ScStatement statement = (ScStatement) empty.getStatement();

        if (statement.description == null) {
            statement.description = new String[columns.length][2];
        }
        for (int i = 0; i < columns.length; i++) {
            statement.description[i][1] = columns[i];
            statement.i_ahHash.put(new Integer(i + 1), columns[i]);
        }
        return empty;
    }

    /**
     * JDBC 2.0
     * Retrieves the connection that produced this metadata object.
     *
     * @return the connection that produced this metadata object
     */
    public Connection getConnection() throws SQLException {
        connection.log("ScDatabaseMetaData.getConnection");
        return connection;
    }

    //--------------------------JDBC 3.0-----------------------------
    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsSavepoints()
     */
    public boolean supportsSavepoints() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsSavepoints");
        return false;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsNamedParameters()
     */
    public boolean supportsNamedParameters() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsNamedParameters");
        return false;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsMultipleOpenResults()
     */
    public boolean supportsMultipleOpenResults() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsMultipleOpenResults");
        return false;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsGetGeneratedKeys()
     */
    public boolean supportsGetGeneratedKeys() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsGetGeneratedKeys");
        return true;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSuperTypes(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getSuperTypes(String catalog, String schemaPattern, String typeNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getSuperTypes");
        String[] columns = {"TYPE_CAT", "TYPE_SCHEM", "TYPE_NAME", "SUPERTYPE_CAT", "SUPERTYPE_SCHEM", "SUPERTYPE_NAME"};

        ScJdbcResultSet empty = new ScJdbcResultSet(connection, (ScStatement) connection.createStatement());
        empty.closeStatementOnClose = true;

        ScStatement statement = (ScStatement) empty.getStatement();

        if (statement.description == null) {
            statement.description = new String[columns.length][2];
        }
        for (int i = 0; i < columns.length; i++) {
            statement.description[i][1] = columns[i];
            statement.i_ahHash.put(new Integer(i + 1), columns[i]);
        }
        return empty;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSuperTables(java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getSuperTables(String catalog, String schemaPattern, String tableNamePattern) throws SQLException {

        connection.log("ScDatabaseMetaData.getSuperTables");
        String[] columns = {"TABLE_CAT", "TABLE_SCHEM", "TABLE_NAME", "SUPERTABLE_NAME"};

        ScJdbcResultSet empty = new ScJdbcResultSet(connection, (ScStatement) connection.createStatement());
        empty.closeStatementOnClose = true;

        ScStatement statement = (ScStatement) empty.getStatement();

        if (statement.description == null) {
            statement.description = new String[columns.length][2];
        }
        for (int i = 0; i < columns.length; i++) {
            statement.description[i][1] = columns[i];
            statement.i_ahHash.put(new Integer(i + 1), columns[i]);
        }
        return empty;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getAttributes(java.lang.String, java.lang.String, java.lang.String, java.lang.String)
     */
    public ResultSet getAttributes(String catalog, String schemaPattern, String typeNamePattern, String attributeNamePattern) throws SQLException {
        connection.log("ScDatabaseMetaData.getAttributes");
        String[] columns = {"TYPE_CAT", "TYPE_SCHEM", "TYPE_NAME", "DATA_TYPE", "ATTR_NAME", "ATTR_TYPE_NAME", "ATTR_SIZE", "DECIMAL_DIGITS",
                "NUM_PREC_RADIX", "NULLABLE", "REMARKS", "ATTR_DEF", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "CHAR_OCTEL_LENGTH", "ORDINAL_POSITION",
                "IS_NULLABLE", "SCOPE_CATALOG", "SCOPE_SCHEMA", "SCOPE_TABLE", "SOURCE_DATA_TYPE"};


        ScJdbcResultSet empty = new ScJdbcResultSet(connection, (ScStatement) connection.createStatement());
        empty.closeStatementOnClose = true;

        ScStatement statement = (ScStatement) empty.getStatement();

        if (statement.description == null) {
            statement.description = new String[columns.length][2];
        }
        for (int i = 0; i < columns.length; i++) {
            statement.description[i][1] = columns[i];
            statement.i_ahHash.put(new Integer(i + 1), columns[i]);
        }
        return empty;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsResultSetHoldability(int)
     */
    public boolean supportsResultSetHoldability(int holdability) throws SQLException {
        connection.log("ScDatabaseMetaData.supportsResultSetHoldability");
        return true;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getResultSetHoldability()
     */
    public int getResultSetHoldability() throws SQLException {
        connection.log("ScDatabaseMetaData.getResultSetHoldability");
        return ResultSet.CLOSE_CURSORS_AT_COMMIT;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getDatabaseMajorVersion()
     */
    public int getDatabaseMajorVersion() throws SQLException {
        connection.log("ScDatabaseMetaData.getDatabaseMajorVersion");
        String version = getDatabaseProductVersion();
        int i = version.indexOf(".");
        if (i > 0) {
            try {
                String v1 = version.substring(0, i);
                return Integer.parseInt(v1);
            } catch (Exception e) {
            }
        }
        ScDBError.check_error(-52, "java.sql.DatabaseMetaData#getDatabaseMajorVersion()");
        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getDatabaseMinorVersion()
     */
    public int getDatabaseMinorVersion() throws SQLException {
        connection.log("ScDatabaseMetaData.getDatabaseMinorVersion");
        String version = getDatabaseProductVersion();
        int i = version.indexOf(".");
        if (i > 0) {
            try {
                String v1 = version.substring(i + 1);
                return Integer.parseInt(v1);
            } catch (Exception e) {
            }
        }

        ScDBError.check_error(-52, "java.sql.DatabaseMetaData#getDatabaseMinorVersion()");
        return 0;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getJDBCMajorVersion()
     */
    public int getJDBCMajorVersion() throws SQLException {
        connection.log("ScDatabaseMetaData.getJDBCMajorVersion");
        return 3;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getJDBCMinorVersion()
     */
    public int getJDBCMinorVersion() throws SQLException {
        connection.log("ScDatabaseMetaData.getJDBCMinorVersion");
        return 1;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#getSQLStateType()
     */
    public int getSQLStateType() throws SQLException {
        connection.log("ScDatabaseMetaData.getSQLStateType");
        return DatabaseMetaData.sqlStateSQL99;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#locatorsUpdateCopy()
     */
    public boolean locatorsUpdateCopy() throws SQLException {
        connection.log("ScDatabaseMetaData.locatorsUpdateCopy");
        return true;
    }

    /* (non-Javadoc)
     * @see java.sql.DatabaseMetaData#supportsStatementPooling()
     */
    public boolean supportsStatementPooling() throws SQLException {
        connection.log("ScDatabaseMetaData.supportsStatementPooling");
        return true;
    }

    @Override
    public boolean generatedKeyAlwaysReturned() {
        return false;
    }

    @Override
    public ResultSet getPseudoColumns(String catalog, String schemaPattern, String tableNamePattern, String columnNamePattern) {
        return null;
    }

    @Override
    public ResultSet getFunctionColumns(String catalog, String schemaPattern, String functionNamePattern, String columnNamePattern) {
        return null;
    }

    @Override
    public ResultSet getFunctions(String catalog, String schemaPattern, String functionNamePattern) {
        return null;
    }

    @Override
    public ResultSet getClientInfoProperties() {
        return null;
    }

    @Override
    public boolean autoCommitFailureClosesAllResultSets() {
        return false;
    }

    @Override
    public boolean supportsStoredFunctionsUsingCallSyntax() {
        return false;
    }

    @Override
    public ResultSet getSchemas(String catalog, String schemaPattern) {
        return null;
    }

    @Override
    public RowIdLifetime getRowIdLifetime() {
        return null;
    }

    @Override
    public boolean isWrapperFor(Class<?> iface) {
        return false;
    }

    @Override
    public <T> T unwrap(Class<T> iface) {
        return null;
    }

}

