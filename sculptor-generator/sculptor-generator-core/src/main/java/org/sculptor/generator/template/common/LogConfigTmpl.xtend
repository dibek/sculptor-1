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

package org.sculptor.generator.template.common

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class LogConfigTmpl {

	@Inject extension Helper helper

	def String logbackConfig(Application it) {
		logbackXml(it)
		logbackTestXml(it)
	}

	def String logbackXml(Application it) {
		fileOutput("logback.xml", OutputSlot::TO_RESOURCES, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<configuration>

			<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
				<encoder>
					<pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
				</encoder>
			</appender>

			<root level="INFO">
				<appender-ref ref="STDOUT" />
			</root>

		</configuration>	    
		'''
		)
	}

	def String logbackTestXml(Application it) {
		fileOutput("logback-test.xml", OutputSlot::TO_RESOURCES_TEST, '''
		<?xml version="1.0" encoding="UTF-8" ?>
		<configuration>

			<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
				<encoder>
					<pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
				</encoder>
			</appender>
			
			<logger name="�basePackage�" level="DEBUG" />
			<root level="INFO">
				<appender-ref ref="STDOUT" />
			</root>

		</configuration>	    
		'''
		)
	}
}
