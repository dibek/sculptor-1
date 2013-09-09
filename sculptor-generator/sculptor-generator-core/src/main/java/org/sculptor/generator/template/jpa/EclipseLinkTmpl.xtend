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
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class EclipseLinkTmpl {

	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper

def String eclipseLink(Application it) {
	'''
		�mapping(it)�
		�IF isJodaDateTimeLibrary()�
			�jodaConverterClass(it)�
		�ENDIF�
		�IF it.containsNonOrdinaryEnums()�
			�enumConverterClass(it)�
		�ENDIF�
	'''
}

def String header(Application it) {
	'''
	<?xml version="1.0" encoding="utf-8" ?>
	<entity-mappings
	xmlns="http://www.eclipse.org/eclipselink/xsds/persistence/orm"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	version="1.0">
	'''
}

def String footer(Application it) {
	'''
	</entity-mappings>
	'''
}

def String mapping(Application it) {
	fileOutput("/META-INF/orm.xml", OutputSlot::TO_GEN_RESOURCES, '''
	�header(it)�
	�enumConverter(it)�
		�IF isJodaDateTimeLibrary()�
		�jodaConverter(it)�
	�ENDIF�
	�footer(it)�
	'''
	)
}

def String enumConverter(Application it) {
	'''
	<converter name="EnumConverter" class="�basePackage�.util.EnumConverter"></converter>
	'''
}

def String jodaConverter(Application it) {
	'''
	<converter name="JodaConverter" class="�basePackage�.util.JodaConverter"></converter>
	'''
}

def String jodaConverterClass(Application it) {
	fileOutput(javaFileName(basePackage +".util.JodaConverter"), OutputSlot::TO_GEN_SRC, '''
	package �basePackage�.util;

/// Sculptor code formatter imports ///

	import org.eclipse.persistence.mappings.DatabaseMapping;
	import org.eclipse.persistence.mappings.converters.Converter;
	import org.eclipse.persistence.sessions.Session;
	import org.joda.time.DateTime;
	import org.joda.time.LocalDate;

	@SuppressWarnings("serial")
	public class JodaConverter implements Converter {
		private Class<?> dateClass;

		public Object convertDataValueToObjectValue(Object dataValue, Session session) {
			if ("LocalDate".equals(dateClass.getSimpleName())) {
				return new LocalDate(dataValue);
			}
			if ("DateTime".equals(dateClass.getSimpleName())) {
				return new DateTime(dataValue);
			}
			else {
				throw new IllegalArgumentException("dataValue can not be converted to LocalDate/DateTime");
			}
		}

		public Object convertObjectValueToDataValue(Object objectValue, Session session) {
			if (objectValue instanceof DateTime) {
				return ((DateTime) objectValue).toDate();
			}
			else if (objectValue instanceof LocalDate) {
				return ((LocalDate) objectValue).toDateTimeAtStartOfDay().toDate();
			}
			else {
				throw new IllegalArgumentException("objectValue is not of type LocalDate/DateTime");
			}
		}

		public void initialize(DatabaseMapping mapping, Session session) {
			dateClass = mapping.getAttributeClassification();
		}

		public boolean isMutable() {
			return false;
		}
	}
	'''
	)
}

def String enumConverterClass(Application it) {
	fileOutput(javaFileName(basePackage +".util.EnumConverter"), OutputSlot::TO_GEN_SRC, '''
	package �basePackage�.util;

/// Sculptor code formatter imports ///

	import org.eclipse.persistence.mappings.DatabaseMapping;
	import org.eclipse.persistence.mappings.converters.Converter;
	import org.eclipse.persistence.sessions.Session;

	import org.sculptor.framework.util.EnumHelper;

	@SuppressWarnings("serial")
	public class EnumConverter implements Converter {
		private Class<?> enumClass;

		@SuppressWarnings("unchecked")
		public Enum convertDataValueToObjectValue(Object dataValue, Session session) {
			return EnumHelper.toEnum(enumClass, dataValue);
		}

		@SuppressWarnings("unchecked")
		public Object convertObjectValueToDataValue(Object objectValue,
			Session session) {
			if (objectValue instanceof Enum) {
				return EnumHelper.toData((Enum) objectValue);
			} else {
				throw new IllegalArgumentException(
				    "objectValue is not of type Enum");
			}
		}

		public void initialize(DatabaseMapping mapping, Session session) {
			enumClass = mapping.getAttributeClassification();
		}

		public boolean isMutable() {
			return false;
		}
	}
	'''
	)
}
}
