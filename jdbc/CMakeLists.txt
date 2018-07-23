#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cmake_minimum_required(VERSION 2.8)

project(jdbc)

find_package(Java REQUIRED)
include(UseJava)

option(usemq "Use IBM MQ Message Transport Engine" OFF)

set(SOURCES sanchez/app/ScGlobalCacheManager.java
	    sanchez/base/ScBaseException.java
	    sanchez/base/ScBundle.java
	    sanchez/base/ScDateManager.java
	    sanchez/base/ScException.java
	    sanchez/base/ScMessage.java
	    sanchez/base/ScMessageManager.java
	    sanchez/base/ScMessageManagerGlobal.java
	    sanchez/base/ScNonSessionMessageManager.java
	    sanchez/base/ScNumberManager.java
	    sanchez/base/ScObject.java
	    sanchez/base/ScObjectGlobal.java
	    sanchez/base/ScResourceKeys.java
	    sanchez/him_pa/formatters/ScFormatter.java
	    sanchez/him_pa/formatters/ScProfileForm.java
	    sanchez/him_pa/transports/ScMTMTransport.java
	    sanchez/him_pa/transports/ScTCPTransport.java
	    sanchez/him_pa/transports/ScTransport.java
	    sanchez/him_pa/transports/ScTransportsException.java
	    sanchez/him_pa/utils/ScBufferCount.java
	    sanchez/him_pa/utils/ScFileUtils.java
	    sanchez/him_pa/utils/ScInt.java
	    sanchez/him_pa/utils/ScLV.java
	    sanchez/him_pa/utils/ScMrpcUtility.java
	    sanchez/him_pa/utils/ScMSQLFormat.java
	    sanchez/him_pa/utils/ScRawString.java
	    sanchez/him_pa/utils/ScStringTokenizer.java
	    sanchez/him_pa/utils/ScUnicodeBlock.java
	    sanchez/him_pa/utils/ScUtils.java
	    sanchez/him_pa/ScHIM.java
	    sanchez/him_pa/ScHIM_PAException.java
	    sanchez/him_pa/ScInvalidBackUserException.java
	    sanchez/him_pa/ScProfileException.java
	    sanchez/him_pa/ScProfToken.java
	    sanchez/him_pa/ScToken.java
	    sanchez/io/db/jdbc/ScTransaction.java
	    sanchez/ipc/ScIPCException.java
	    sanchez/ipc/ScMTMCommunication.java
	    sanchez/ipc/ScTCPCommunication.java
	    sanchez/ipc/SiCommunication.java
	    sanchez/jdbc/dbaccess/ScBufferPool.java
	    sanchez/jdbc/dbaccess/ScCursorPool.java
	    sanchez/jdbc/dbaccess/ScDBAccess.java
	    sanchez/jdbc/dbaccess/ScDBColumn.java
	    sanchez/jdbc/dbaccess/ScDBConversion.java
	    sanchez/jdbc/dbaccess/ScDBError.java
	    sanchez/jdbc/dbaccess/ScDBStatement.java
	    sanchez/jdbc/dbaccess/ScDBType.java
	    sanchez/jdbc/dbaccess/ScGenericStatement.java
	    sanchez/jdbc/dbaccess/ScMrpcStatement.java
	    sanchez/jdbc/dbaccess/ScMsqlDDLStatement.java
	    sanchez/jdbc/dbaccess/ScStoreProStatement.java
	    sanchez/jdbc/driver/ScCallableStatement.java
	    sanchez/jdbc/driver/ScConnection.java
	    sanchez/jdbc/driver/ScDatabaseMetaData.java
	    sanchez/jdbc/driver/ScDriver.java
	    sanchez/jdbc/driver/ScJdbcResultSet.java
	    sanchez/jdbc/driver/ScPreparedStatement.java
	    sanchez/jdbc/driver/ScResultSetMetaData.java
	    sanchez/jdbc/driver/ScStatement.java
	    sanchez/jdbc/pool/ScConnectionCache.java
	    sanchez/jdbc/pool/ScConnectionEvenListener.java
	    sanchez/jdbc/pool/ScConnectionPoolDataSource.java
	    sanchez/jdbc/pool/ScDataSource.java
	    sanchez/jdbc/pool/ScJDBCConnectionPoolCache.java
	    sanchez/jdbc/pool/ScJdbcPool.java
	    sanchez/jdbc/pool/ScObjectFactory.java
	    sanchez/jdbc/pool/ScPooledConnection.java
	    sanchez/jdbc/pool/ScPoolManager.java
	    sanchez/jdbc/thin/ScProfAccess.java
	    sanchez/jdbc/thin/ScProfileAPI.java
	    sanchez/jdbc/thin/ScSessionManager.java
	    sanchez/jdbc/utils/ScJdbcDriverGlobalCache.java
	    sanchez/jdbc/utils/ScSerialArray.java
	    sanchez/jdbc/utils/ScSerialBlob.java
	    sanchez/jdbc/utils/ScSerialClob.java
	    sanchez/jdbc/utils/ScSerialDatalink.java
	    sanchez/jdbc/utils/ScSerialException.java
	    sanchez/jdbc/utils/ScSerialJavaObject.java
	    sanchez/jdbc/utils/ScSerialRef.java
	    sanchez/jdbc/utils/ScSerialStruct.java
	    sanchez/jdbc/utils/ScSQLInputImpl.java
	    sanchez/jdbc/utils/ScSQLOutputImpl.java
	    sanchez/security/ScSystemSecurityManager.java
	    sanchez/security/ScUIO.java
	    sanchez/utils/cipher/ScMD5.java
	    sanchez/utils/objectpool/ScCannotCreatePoolException.java
	    sanchez/utils/objectpool/ScClientSocketPool.java
	    sanchez/utils/objectpool/ScGarbageCollector.java
	    sanchez/utils/objectpool/ScInvalidObjectException.java
	    sanchez/utils/objectpool/ScJDBCConnectionPool.java
	    sanchez/utils/objectpool/ScMTMCommPool.java
	    sanchez/utils/objectpool/ScObjectPool.java
	    sanchez/utils/objectpool/ScObjectPoolException.java
	    sanchez/utils/objectpool/ScTCPCommPool.java
	    sanchez/utils/objectpool/ScTokenNotFoundException.java
	    sanchez/utils/objectpool/SiCleanable.java
	    sanchez/utils/ScDebug.java
	    sanchez/utils/ScFileLogger.java
	    sanchez/utils/ScISKeys.java
	    sanchez/utils/ScLengthException.java
	    sanchez/utils/ScLogger.java
	    sanchez/utils/ScLogManager.java
	    sanchez/utils/ScMatrix.java
	    sanchez/utils/ScSerialHandler.java
	    sanchez/utils/ScSerialUtils.java
	    sanchez/utils/ScSqlFormat.java
	    sanchez/utils/ScUtility.java
	    sanchez/utils/ScUtilLogger.java
	    sanchez/utils/ScUtilsException.java
	    sanchez/utils/SiLoggable.java
	    sanchez/utils/SiLogger.java)

if(usemq)
	list(append SOURCES sanchez/him_pa/transports/ScMQTransport.java
		            sanchez/ipc/ScMQCommunication.java
		            sanchez/utils/objectpool/ScMQCommPool.java)
endif()

add_jar(ScJDBC ${SOURCES})
install_jar(ScJDBC DESTINATION jdbc)
