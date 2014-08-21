package org.bsonspec;

import haxe.Int64;
using haxe.Int64;


class MongoDate
{
  public var utc_ms:Int64;
  public var date:Date;
  
  
  public function new(utc_ms:Int64) 
  {    
    this.utc_ms = utc_ms;
    
    var low:UInt = utc_ms.getLow();
    var high:UInt = utc_ms.getHigh();
    date = Date.fromTime(cast(high, Float) * 4294967296.0 + low);            
  }
  
  public inline function ms():Int
  {
    var m = Int64.make(0, 1000);
    return utc_ms.mod(m).getLow();        
  }
  
  // tz_offset in minutes, e.g. for UTC +02:00 value is -120
  
  public function format(?tz_offset:Int):String
  {
    if (tz_offset == null)    
    { 
      // Haxe currently doesn't support cross platform Date.getTimezoneOffset() function
      // so we use this snippet, but it's not counting in Daylight Saving Time difference

      var a = DateTools.format(Date.fromTime(0), '%H:%M').split(':');   
      tz_offset = -Std.parseInt(a[0]) * 60 + Std.parseInt(a[1]);      
    }
    
    return DateTools.format(Date.fromTime(date.getTime() + tz_offset * 60*1000), '%Y-%m-%d %H:%M:%S.' + ms());
  }
  
  public function toString()
  {
    return format();
  }
}