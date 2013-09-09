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

package org.sculptor.generator.template.consumer

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.db.DbUnitTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Consumer
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class ConsumerTestTmpl {

	@Inject private var DbUnitTmpl dbUnitTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String consumerJUnitWithAnnotations(Consumer it) {
	fileOutput(javaFileName(getConsumerPackage(it) + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
	�javaHeader()�
	package �getConsumerPackage(it)�;

/// Sculptor code formatter imports ///

	import static org.junit.Assert.*;

	/**
	 * JUnit test.
	 */
	public class �name�Test extends �databaseJpaTestCaseClass()� {

		@org.springframework.beans.factory.annotation.Autowired
		private �consumerInterface()� �name.toFirstLower()�;

	�consumerJUnitGetDataSetFile(it)�

	�receiveTestMethod(it)�

	}
	'''
	)
}

def String consumerJUnitGetDataSetFile(Consumer it) {
	'''
	�IF getDbUnitDataSetFile() != null�
		@Override
		protected String getDataSetFile() {
			return "�getDbUnitDataSetFile()�";
		}
	�ENDIF�
	'''
}

def String receiveTestMethod(Consumer it) {
	'''
		@org.junit.Test
		public void testReceive() throws Exception {
			// TODO Auto-generated method stub
			//�name.toFirstLower()�.receive(event);
			fail("testReceive not implemented");
		}
	'''
}

def String dbunitTestData(Consumer it) {
	fileOutput("dbunit/" + name + "Test.xml", OutputSlot::TO_RESOURCES_TEST, '''
		�dbUnitTmpl.dbunitTestDataContent(it.module.application)�
	'''
	)
}

def String consumerDependencyInjectionJUnit(Consumer it) {
	fileOutput(javaFileName(getConsumerPackage(it) + "." + name + "DependencyInjectionTest"), OutputSlot::TO_GEN_SRC_TEST, '''
	�javaHeader()�
	package �getConsumerPackage(it)�;

/// Sculptor code formatter imports ///

	/**
	 * JUnit test to verify that dependency injection setter methods
	 * of other Spring beans have been implemented.
	 */
	public class �name�DependencyInjectionTest extends junit.framework.TestCase {

		�it.otherDependencies.map[d | consumerDependencyInjectionTestMethod(d, it)].join()�

	}
	'''
	)
}

def String consumerDependencyInjectionTestMethod(String it, Consumer consumer) {
	'''
		public void test�it.toFirstUpper()�Setter() throws Exception {
			Class clazz = �consumer.getConsumerPackage()�.�consumer.name�.class;
			java.lang.reflect.Method[] methods = clazz.getMethods();
			String setterMethodName = "set�it.toFirstUpper()�";
			java.lang.reflect.Method setter = null;
			for (int i = 0; i < methods.length; i++) {
				if (methods[i].getName().equals(setterMethodName) &&
				        void.class.equals(methods[i].getReturnType()) &&
				        methods[i].getParameterTypes().length == 1) {
				    setter = methods[i];
				    break;
				}
			}

			assertNotNull("Setter method for dependency injection of " +
					"�it� must be defined in �consumer.name�."
					, setter);

			�consumer.getConsumerPackage()�.�consumer.name� �consumer.name.toFirstLower()� = new �consumer.getConsumerPackage()�.�consumer.name�();
			try {
				setter.invoke(�consumer.name.toFirstLower()�, new Object[] {null});
			} catch (java.lang.reflect.InvocationTargetException e) {
				if (e.getCause().getClass().equals(UnsupportedOperationException.class)) {
					assertTrue(e.getCause().getMessage(), false);
				} else {
					// exception due to something else, but the method was not forgotten
				}
			}

		}
	'''
}
}
