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

package org.sculptor.generator.template.domain

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Trait
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DomainObjectNamesTmpl {

	@Inject extension Helper helper
	@Inject extension HelperBase helperBase
	@Inject extension Properties properties

def dispatch String propertyNamesInterface(DataTransferObject it) {
	'''
	'''
}
def dispatch String propertyNamesInterface(Trait it) {
	'''
	'''
}

def dispatch String propertyNamesInterface(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Names"), OutputSlot::TO_GEN_SRC, '''
		�javaHeader()�
		package �getDomainPackage()�;

/// Sculptor code formatter imports ///

		/**
		 * This generated interface defines constants for all
		 * attributes and associatations in
		 * {@link �getDomainPackage()�.�name�}.
		 * <p>
		 * These constants are useful for example when building
		 * criterias.
		 */
		public interface �name�Names {
			�it.attributes.map[propertyNameConstant(it)].join()�
			�it.references.map[propertyNameConstant(it)].join()�
		}
	'''
	)
}

def String propertyNameConstant(NamedElement it) {
	'''
		public static final String �name.toUpperCase()� = "�name�";
	'''
}

}
