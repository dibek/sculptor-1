/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.generator.template.jpa

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.db.OracleDDLTmpl
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.Enum
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DataNucleusTmpl {

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties
	@Inject private var OracleDDLTmpl oracleDDLTmpl

def String dataNucleus(Application it) {
	'''
		�IF it.containsNonOrdinaryEnums()�
			�enumMappingClass(it)�
			�enumLiteralClass(it)�
			�enumPlugin(it)�
			�manifest(it)�
		�ENDIF�
		�IF isTestToBeGenerated()�
			�dataNucleusTestProperties(it)�
			�testDdl(it)�
		�ENDIF�
	'''
}

def String dataNucleusTestProperties(Application it) {
	fileOutput("datanucleus-test.properties", OutputSlot::TO_GEN_RESOURCES_TEST, '''
	datanucleus.ConnectionDriverName=org.hsqldb.jdbcDriver
	datanucleus.ConnectionURL=jdbc:hsqldb:mem:�name.toLowerCase()�
	datanucleus.ConnectionUserName=sa
	datanucleus.ConnectionPassword=
	'''
	)
}

def String enumPlugin(Application it) {
	fileOutput("plugin.xml", OutputSlot::TO_GEN_RESOURCES, '''
	<?xml version="1.0"?>
	<plugin>
		<extension point="org.datanucleus.store_mapping">
		�FOR enm : it.getAllEnums().filter(e|!e.isOrdinaryEnum())�
			�enumPluginMapping(enm)�
		�ENDFOR�
		</extension>
		<extension point="org.datanucleus.store.rdbms.sql_expression">
			<sql-expression mapping-class="�basePackage�.util.EnumMapping"
				literal-class="org.datanucleus.store.rdbms.sql.expression.ParameterEnumLiteral"
				expression-class="org.datanucleus.store.rdbms.sql.expression.EnumExpression"/>
		</extension>
	</plugin>
	'''
	)
}

def String enumPluginMapping(Enum it) {
	'''
		<mapping java-type="�getDomainPackage() + "." + name�"
			mapping-class="�it.getApplicationBasePackage()�.util.EnumMapping"/>
	'''
}

def String manifest(Application it) {
	fileOutput("META-INF/MANIFEST.MF", OutputSlot::TO_GEN_RESOURCES, '''
	Manifest-Version: 1.0
	Bundle-ManifestVersion: 2
	Bundle-Name: enumplugin
	Bundle-SymbolicName: org.datanucleus.enumplugin
	Bundle-Version: 1.0.0
	'''
	)
}

def String enumMappingClass(Application it) {
	fileOutput(javaFileName(basePackage + ".util.EnumMapping"), OutputSlot::TO_GEN_SRC, '''
	package �basePackage�.util;

/// Sculptor code formatter imports ///

	import java.math.BigInteger;

	import org.datanucleus.ClassNameConstants;
	import org.datanucleus.metadata.FieldRole;
	import org.datanucleus.store.ExecutionContext;
	import org.sculptor.framework.util.EnumHelper;

	public class EnumMapping extends org.datanucleus.store.mapped.mapping.EnumMapping {

		@Override
		@SuppressWarnings("rawtypes")
		public void setObject(ExecutionContext ec, Object preparedStatement, int[] exprIndex, Object value)
		{
			if (value == null)
			{
				getDatastoreMapping(0).setObject(preparedStatement, exprIndex[0], null);
			}
			else if (datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_STRING) ||
				     datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_INTEGER))
			{
				if (value instanceof String)
				{
				    getDatastoreMapping(0).setString(preparedStatement, exprIndex[0], (String)value);
				}
				else if (value instanceof BigInteger)
				{
				    getDatastoreMapping(0).setInt(preparedStatement, exprIndex[0], ((BigInteger)value).intValue());
				}
				else
				{
				    getDatastoreMapping(0).setObject(preparedStatement, exprIndex[0], EnumHelper.toData((Enum)value));
				}
			}
			else
			{
				super.setObject(ec, preparedStatement, exprIndex, value);
			}
		}

		@Override
		@SuppressWarnings("rawtypes")
		public Object getObject(ExecutionContext ec, Object resultSet, int[] exprIndex)
		{
			if (exprIndex == null)
			{
				return null;
			}

			if (getDatastoreMapping(0).getObject(resultSet, exprIndex[0]) == null)
			{
				return null;
			}
			else if (datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_STRING) ||
				     datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_INTEGER))
			{
				Object value = getDatastoreMapping(0).getObject(resultSet, exprIndex[0]);
				Class enumType = null;
				if (mmd == null)
				{
				    enumType = ec.getClassLoaderResolver().classForName(type);
				}
				else
				{
				    enumType = mmd.getType();
				    if (roleForMember == FieldRole.ROLE_COLLECTION_ELEMENT)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getCollection().getElementType());
				    }
				    else if (roleForMember == FieldRole.ROLE_ARRAY_ELEMENT)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getArray().getElementType());
				    }
				    else if (roleForMember == FieldRole.ROLE_MAP_KEY)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getMap().getKeyType());
				    }
				    else if (roleForMember == FieldRole.ROLE_MAP_VALUE)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getMap().getValueType());
				    }
				}
				return EnumHelper.toEnum(enumType, value);
			}
			else
			{
				return super.getObject(ec, resultSet, exprIndex);
			}
		}
	}
	'''
	)
}

def String enumLiteralClass(Application it) {
	fileOutput(javaFileName("org.datanucleus.store.rdbms.sql.expression.ParameterEnumLiteral"), OutputSlot::TO_GEN_SRC, '''
	package org.datanucleus.store.rdbms.sql.expression;

/// Sculptor code formatter imports ///

	import org.datanucleus.ClassNameConstants;
	import org.datanucleus.store.mapped.mapping.JavaTypeMapping;
	import org.datanucleus.store.rdbms.sql.SQLStatement;
	import org.sculptor.framework.util.EnumHelper;

	/**
	 * Representation of an Enum literal.
	 */
	public class ParameterEnumLiteral extends EnumLiteral
	{
		public ParameterEnumLiteral(SQLStatement stmt, JavaTypeMapping mapping, Object value, String parameterName) {
			super(stmt, mapping, value, parameterName);
			setDelegate(mapping);
		}

		@Override
		public void setJavaTypeMapping(JavaTypeMapping mapping)
		{
			super.setJavaTypeMapping(mapping);
			setDelegate(mapping);
		}

		private void setDelegate(JavaTypeMapping mapping) {
			if (mapping.getJavaTypeForDatastoreMapping(0).equals(ClassNameConstants.JAVA_LANG_STRING))
			{
				delegate = new StringLiteral(stmt, mapping,
				    (getValue() != null ? EnumHelper.toData((Enum<?>)getValue()) : null), parameterName);
			}
			else
			{
				delegate = new IntegerLiteral(stmt, mapping,
				    (getValue() != null ? EnumHelper.toData((Enum<?>)getValue()) : null), parameterName);
			}
		}
	}
	'''
	)
}

/*
		This is hopefully a temporary workaround for DataNucleus.
		DataNucleus is not generating primary keys on manytomany jointables
 */
def String testDdl(Application it) {
	val manyToManyRelations = it.resolveManyToManyRelations(true)
	fileOutput("dbunit/ddl_additional.sql", OutputSlot::TO_GEN_RESOURCES_TEST, '''
		�manyToManyRelations.map[oracleDDLTmpl.manyToManyPrimaryKey(it)].join()�
	'''
	)
}
}
