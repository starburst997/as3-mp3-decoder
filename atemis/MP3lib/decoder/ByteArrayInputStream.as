/*
 * 06/01/07 	By Jean-Denis Boivin 
 *				(jeandenis.boivin@gmail.com) From Team-AtemiS.com
 *
 *-----------------------------------------------------------------------
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as published
 *   by the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details.
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the Free Software
 *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *----------------------------------------------------------------------
 */
 
package atemis.MP3lib.decoder {

	/**
	 * Recreate Java's PushbackInputStream function into ActionScript 3
	 */
	public final class ByteArrayInputStream extends InputStream
	{
		
		protected var buf:Array;
		
		protected var pos:int;
		
		protected var count:int;
		
	  /**
	   * Constructor
	   */
	  public function ByteArrayInputStream(buf:Array)
	  { 
	  	this.buf = buf;
      	this.pos = 0;
     	this.count = buf.length;
	  }
	 
	 
	}
}
