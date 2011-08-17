/**
 * (c) 2011 Richard J Smith
 *
 * This file is part of hxzmq
 *
 * hxzmq is free software; you can redistribute it and/or modify it under
 * the terms of the Lesser GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * hxzmq is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * Lesser GNU General Public License for more details.
 *
 * You should have received a copy of the Lesser GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.zeromq.test;

import haxe.unit.TestRunner;
import org.zeromq.test.TestContext;
import org.zeromq.test.TestVersion;


class TestAll 
{

	public static function main() {
		
		var runner:TestRunner = new TestRunner();

		// Core org.zeromq package tests
		runner.add(new TestVersion());
		runner.add(new TestContext());
		runner.add(new TestError());
		runner.add(new TestSocket());
		runner.add(new TestPubSub());
		runner.add(new TestMultiPartMessage());
		runner.add(new TestReqRep());
		runner.add(new TestPoller());
        //
		// org.zeromq.remoting package tests
        runner.add(new TestZMQRemoting());
        
        // Higher-level management class tests
        runner.add(new TestZContext());
        runner.add(new TestZSocket());
        runner.add(new TestZFrame());
        runner.add(new TestZMsg());
        runner.add(new TestZLoop());
		runner.add(new TestZThread());
        
		// Run
		runner.run();
	}
}