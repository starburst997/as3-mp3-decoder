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
	 * Recreate some Java specifics function into ActionScript 3
	 */
	public final class System
	{
		
	  /**
	   * Constructor
	   */
	  public function System()
	  { 
	  }
	  
	  public static function arraycopy(array:Array, offset:int, arrayCopy:Array, offsetCopy:int, length:int):void {
	  	for(var i:uint=offsetCopy; i<offsetCopy+length; i++) {
	  		arrayCopy[i] = array[offset+(i-offsetCopy)];
	  	}
	  }
	}
}
