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

import org.zeromq.ZMQ;

class TestVersion extends BaseTest
{

	public function testVersionMethods() 
	{
		var _major = ZMQ.versionMajor();
		assertTrue(_major >= 2);

		var _minor = ZMQ.versionMinor();
		assertTrue(_minor >= 0);

		var _patch = ZMQ.versionPatch();
		assertTrue(_patch >= 0);

		var _version = ZMQ.version_full();
		trace ("version_full:" + _version);
		assertTrue(_version >= 0);

	}

	public function testMakeVersion() 
	{
		assertTrue(ZMQ.makeVersion(1, 2, 3) == 10203);
	}
	
	public override function setup():Void {
		// No setup needed for these tests
	}
	
	public override function tearDown():Void {
		// No tearDown needed for these tests
	}
}