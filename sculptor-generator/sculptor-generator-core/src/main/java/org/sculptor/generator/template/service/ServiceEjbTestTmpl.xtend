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

package org.sculptor.generator.template.service

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Service
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class ServiceEjbTestTmpl {

	@Inject private var ServiceTestTmpl serviceTestTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

/*Used for pure-ejb3, i.e. without spring */
def String serviceJUnitSubclassOpenEjb(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
	�javaHeader()�
	package �it.getServiceapiPackage()�;

/// Sculptor code formatter imports ///

	import static org.junit.Assert.*;

	/**
	 *  JUnit test with OpenEJB support.
	 */
	public class �name�Test extends �IF jpa()��fw("test.AbstractOpenEJBDbUnitTest")��ELSE��fw("test.AbstractOpenEJBTest")��ENDIF� implements �name�TestBase {

	@javax.ejb.EJB
		private �it.getServiceapiPackage()�.�name� �name.toFirstLower()�;

		�serviceTestTmpl.serviceJUnitGetDataSetFile(it)�

		�it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[serviceTestTmpl.testMethod(it)].join()�
	}
	'''
	)
	'''
	'''
}

def String ejbJarXml(Application it) {
	fileOutput("META-INF/ejb-jar.xml", OutputSlot::TO_RESOURCES, '''
	<?xml version="1.0" encoding="UTF-8"?>  
	<!-- need this for OpenEJB testing -->

	<ejb-jar version="3.0" 
	xmlns="http://java.sun.com/xml/ns/javaee" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/ejb-jar_3_0.xsd">

	</ejb-jar>
	'''
	)
}
}
