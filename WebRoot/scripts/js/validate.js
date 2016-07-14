//* =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ */
//*              PROGRAM  COPYRIGHT  DAVID J SHILLING  2004                */
//* =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ */
//*                                                                        */
//*vc_prog = "validate.js".        - Format fileds like Progress 4GL       */
//*                                                                        */
//*vc_create = 04/24/2004.         - the date of creation - first version  */
//*vc_modify = 05/01/2004.         - last modification date.               */
//*          mm dd yy                                                      */
//*                                                                        */
//*vc_version = "200405a".         - version number.                       */
//*                                                                        */
//*                                                                        */
//*From an original idea by John McGlothlin - tbMask - Extensivly modified */
//* By David Shilling - to allow for decimals and lots of other Progress   */
//* formats and pull in wierd things like phone (__)___-_______ etc...     */
//*  There is a second part for editor fields - validation.js              */
//* +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+= */
//*     THIS IS GPL SOFTWARE SO MAKE SURE THIS HEADER STAYS PUT!!!         */
//* +=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+= */
//
// Mask Characters
// 9,<,>,z  = Numeric only
// A,!      = Alpha only
// X        = Alphanumeric
//
// All other chars treated as literals.
// Special dispensation given to the Thousand & Decimal separators for internationalisation (wow that's a big word!)
//
// special key vars
var CTRL_PASTE = 22;
var CTRL_COPY = 3;
var CTRL_CUT = 24;
var TAB_KEY = 9;
var DELETE_KEY = 46;
var BACKSPACE_KEY = 8;
var ENTER_KEY = 13;
var RIGHT_ARROW_KEY = 39;
var DOWN_ARROW_KEY = 40;
var UP_ARROW_KEY = 38;
var LEFT_ARROW_KEY = 37;
var HOME_KEY = 36;
var END_KEY = 35;
var PAGEUP_KEY = 33;
var PAGEDOWN_KEY = 34;
var CAPS_LOCK_KEY = 20;
var ESCAPE_KEY = 27;

// very important vars...
var spaceChar     = " "     // normally a space ' ' but could be '_' or whatever...
//
var thousChar     = ",";    // need to derive this from system? equiv to Progress -E
var deciChar      = ".";    // need to derive this from system? equiv to Progress -E
var dateFormat    = "dmy"   // need to derive this from system? equiv to Progress -d
var currLanguage  = "e"     // need to derive this from system? equiv to Progress -lng
var currCentury   = 1950    // need to derive this from system? equiv to Progress -yy
// datatypes to handle
var tbChar        = false;  // 10 - char
var tbDec         = false;  // 20 - dec
var tbDate        = false;  // 30 - date
var tbInt         = false;  // 40 - int
var tbLog         = false;  // 50 - log
var tbTime        = false;  // 60 - time
// other vars...
var decimalPoint  = null;
var decPast       = false;
var thousands     = [];
var boxEntered    = false;
var maskLength    = 0;
var negSign       = false;
var negPresent    = false;
var addNegSign    = false;
var negBracket    = false
var aa, bb, cc = '', dd = '', xx;
var inEdit        = false;


// --------------------------------------------------------------------
// check mask for dec & thousands
// --------------------------------------------------------------------
function fetchDecimals(mask)
{
  decimalPoint = 0;
  if (mask.indexOf(thousChar) != -1) // if there is a comma it should only appear if length of chars upto the full stop or end
  {                                // of string > format upto full stop or end of string... so remove comma and store position
    var f = mask.length;
    var tmpFormat = "";
    var p = 0;
    if (mask.indexOf(".") != -1 )
    {
      f = mask.indexOf("."); // check where decimal point is
      decimalPoint = f; // assign for later
      p = f - mask.length;
    }
        //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- A fetchDecimals " + decimalPoint + " <br>");}
    for  (y=mask.length;y>=0;y--)
    {
      x = mask.charAt(y);
      if (x == thousChar)
      {
        thousands.push(p);
            //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- B fetchDecimals " + mask + "   y= " + y + "   p= " + p + "   f= " + f + "   dec= " + decimalPoint +  "<br>")}
      }
      else tmpFormat = x + tmpFormat;
      p++;
    }
    mask = tmpFormat;

    //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- C fetchDecimals " + mask + " <br>");}
  } // end of commas
if (mask.indexOf(deciChar) != -1) // if there is a decimal point
  {
    var f = mask.length;
    var tmpFormat = "";
    var p = 0;
    if (mask.indexOf(".") != -1 )
    {
      f = mask.indexOf("."); // check where decimal point is
      decimalPoint = f; // assign for later
      p = f - mask.length;
    }
        //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- A fetchDecimals " + decimalPoint + " <br>");}
    for  (y=mask.length;y>=0;y--)
    {
      x = mask.charAt(y);
      if (x == thousChar)
      {
        thousands.push(p);
            //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- B fetchDecimals " + mask + "   y= " + y + "   p= " + p + "   f= " + f + "   dec= " + decimalPoint +  "<br>")}
      }
      else tmpFormat = x + tmpFormat;
      p++;
    }
    mask = tmpFormat;

    //if (debugThis)   { debugThis("<b>Validate:</b> ---------------- C fetchDecimals " + mask + " <br>");}
  } // end of decimal point
}

// --------------------------------------------------------------------
// expand mask where x(8) should be xxxxxxxx
// --------------------------------------------------------------------

function expandMask(tB)
{

  var mask = tB.mask ==""?"":tB.mask;
  if (!tbDec && mask.substr(mask.indexOf("(") -1, 1) == "X" && mask.indexOf("(") == 1 && mask.indexOf(")") != -1)
  {
    tmpInt = mask.substring(mask.indexOf("(") + 1, mask.indexOf(")")  );
    tmpStr = mask.substring(mask.indexOf("(") -1, mask.indexOf(")") + 1);
    tmpChr = mask.substr(mask.indexOf("(") -1, 1);
    tB.mask = mask.replace(tmpStr,fillString(tmpChr, tmpInt));
    ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- done expandMask " + tB.mask +  "<br>")}
  }
}

// --------------------------------------------------------------------
// convert time mask so HH:MM becomes 99:99 then we carry on as normal!
// --------------------------------------------------------------------

function convertTimeMask(tB)
{

  var mask = tB.mask ==""?"":tB.mask;
  var aa = "";
  for (x=0;x<mask.length;x++)
  {
    if (mask.charAt(x).toLowerCase() == "h") aa += "9";
    else if (mask.charAt(x).toLowerCase() == "m") aa += "9";
    else aa += mask.charAt(x);
  }
 ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- done convertTimeMask " + aa +  "<br>")}

  tB.mask = aa;
}


// --------------------------------------------------------------------
// fill string function
// --------------------------------------------------------------------

function fillString(x,y)
{
  var chars = "";
  while ( chars.length < y )
  {
    chars += x;
  }
  return chars;
}

// --------------------------------------------------------------------
// overlay string function: strMask  = mask (from mask2overlay) or target string
//                          strValue = source input string to overlay from start
//                          start    = position to insert from
// --------------------------------------------------------------------

function overlay(strMask,strValue,start)
{
  var aa, bb, cc = [], dd = strMask.length, ee, xx = 0, negPresent;
  if ((tbDec || tbInt) && (strValue.indexOf("-") != -1 || strValue.indexOf("(") != -1 || strValue.indexOf(")") != -1   ) ) negPresent = true;
  else negPresent = false;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- overlay " + strMask + " with " + strValue + " (len) " + (strValue.length + 1) + " @ " + start +  " dd= " + dd + " for " + strValue.length + " neg? " + negPresent + "<br>"); }
  for ( i=0;i<=dd;i++)
  {
    aa = strMask.charAt(i); // mask (from mask2overlay) or target string
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- inner " + i + " aa= " + aa + " : " + start +  "<br>"); }
    if (i < start)
    {
      if (aa == "¬") cc[i] = " ";
      else if (aa == spaceChar) cc[i] = spaceChar;
      else if ((tbDec || tbInt) && (aa == "-" || aa == thousChar)) cc[i] = spaceChar;
      else  cc[i] = aa;
            ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- A NON i= " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
    }
    else if (i >= start && xx < strValue.length + 1)
    {
      bb = strValue.charAt(xx); // input string to overlay from start

            ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- A IN  i= " + i + " aa= " + aa + " bb= " + bb + " xx= " + xx  + " cc= " + cc.join("") + "<br>"); }

      if ((tbDec || tbInt) && aa == "¬")
      {
        if ((tbDec && "123456789".indexOf(bb) == -1 ) || bb == "" ) cc[i] = "0";
        else cc[i] = bb;
        xx++;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B A " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }
      else if ((tbDec || tbInt) && aa == "-" && bb != "-" && !negPresent)
      {
        cc[i] = spaceChar;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B B " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }
      else if ((tbDec || tbInt) && (bb == "(" || bb == ")")  && negPresent)
      {
        cc[i] = bb;
        xx++;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B C " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }
      else if (aa == spaceChar && bb == "" && (tbDec || tbInt || tbDate))
      {
        cc[i] = aa;
        xx++;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B D " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }
      else if (aa != spaceChar && aa != bb )
      {
        cc[i] = aa;  // leave mask and wait for next space to insert - thus if mask = ( )  -  $
                     //                                                then result is (5)55-55$ !!!
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B E " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }
      else
      {
        cc[i] = bb;
        xx++;
        ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- B F " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      }

    }
    else
    {

            ////if (debugThis)   { debugThis("<b>Validate:</b>  --------------B4 --- C " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
      if (aa == "¬") cc[i] = " ";
      else if (aa == spaceChar) cc[i] = spaceChar;
      else  cc[i] = aa;
            ////if (debugThis)   { debugThis("<b>Validate:</b>  --------------   --- C " + i + " aa= " + aa + " bb= " + bb + " cc= " + cc.join("") + " : " + xx + "<br>"); }
    }
  }
  ee = cc.join("");
  return ee;
}

// --------------------------------------------------------------------
// mask2overlay string function to convert mask to an overlay string
//    it removes mask chars like '9' or 'A' or ',' and leaves the rest
// --------------------------------------------------------------------

function mask2overlay(mask,isNumeric)
{
      ////if (debugThis)   { debugThis("<b>Validate:</b>  ----------------- mask2overlay " + mask + " : " + isNumeric +  "<br>"); }
  var aa, cc = [], dd = mask.length;
  for ( i=0;i<=dd;i++)
  {
    aa = mask.charAt(i);
    if ((tbDec || tbInt) && aa == '9' ) cc[i] = "¬"; //special char added to keep a defined zero in mask - interpreted by overlay only
    else if (aa == 'X' || aa == 'N' || aa == 'A' || aa == '!' || aa == '9' ||  (isNumeric && (aa == 'z' || aa == '<' || aa == '>' || aa == thousChar || aa == deciChar || aa == '-' || aa == '(' || aa == ')'))) cc[i] = spaceChar;
    else cc[i] = aa;
  }
  return cc.join("");
}

// --------------------------------------------------------------------
// numericLength check length of integer
// --------------------------------------------------------------------

function numericLength(mask)
{

  var aa, dd = mask.length, x = -1;
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- field2value " + field + " : " + mask + " : " + isNumeric + "<br>"); }
  for ( i=0;i<=dd;i++)
  {
    aa = mask.charAt(i);
    if  ("9<>z.".indexOf(aa) != -1  ) x++;

  }
return x;

}

// --------------------------------------------------------------------
// field2value string function to convert field contents to a value string
//    it removes mask chars like '$' or '()' or ',' and leaves the rest
// --------------------------------------------------------------------

function field2value(field,mask,isNumeric,forceNLZ)
{

  var aa, bb, cc = [], dd = mask.length, x = 0, z, addMinus, result;

      ////if (debugThis)   { debugThis("<b>Validate:</b> -------------------- field2value " + field + " : " + mask + " : " + isNumeric + "  :  "  + forceNLZ + "<br>"); }

  if (mask.indexOf(">") != -1) tmpNLZ = true;  // No Leading Zeros is true
  else tmpNLZ = false;


  if (forceNLZ != null && forceNLZ == true) tmpNLZ = true; // force a No Leading Zero format - usefull for testing actual length


      ////if (debugThis)   { debugThis("<b>Validate:</b> -------------------- field2value " + field + " : " + mask + " : " + tmpNLZ + "  :  "  + forceNLZ + "<br>"); }


  if (isNumeric) z = numericLength(mask);

  for ( i=0;i<=dd;i++)
  {
    aa = field.charAt(i);
    bb = mask.charAt(i);
    if (isNumeric)
    {
      if (aa == "(" )
      {
        addMinus = true;
      }
      else if (aa == ")")
      {
      }
      else if ( (aa == deciChar || "1234567890-".indexOf(aa) != -1 ) && aa != "")
      {
        if (tmpNLZ && (aa == "0" && bb != "9"))
        {
          cc[x] = "";
          x++;
        }
        else
        {
          cc[x] = aa;
          x++;
        }
      }
            ////if (debugThis)   { debugThis("<b>Validate:</b>  -------------------- inner A aa= " + aa + " bb= " + bb + " i= " + i + " x= " + x + " cc= " + cc + "<br>"); }
    }
    else if ( aa != bb && aa!= spaceChar && (bb == 'X' || bb == 'N' || bb == 'A' || bb == '!' || bb == '9') )
    {
      if (bb == "!") aa.toUpperCase();
      cc[x] = aa;
      x++;
            ////if (debugThis)   { debugThis("<b>Validate:</b>  -------------------- inner B aa= " + aa + " bb= " + bb + " i= " + i + " x= " + x + " cc= " + cc + "<br>"); }
    }
  }

  if (isNumeric)
  {
    result = cc.join("");
    if (result == "")
    {
      if (mask.indexOf(deciChar) != -1) result = "0.00";
      else result = "0";
    }

    ////if (debugThis)   { debugThis("<b>Validate:</b> -------------------- field2value x " + x + " z " + z + "  tmpNLZ= " + tmpNLZ + " <br>"); }

  ////if (debugThis)   { debugThis("<b>Validate:</b> -------------------- field2value x " + x + " z " + z + "  result= " + result + " <br>"); }

    if (!tmpNLZ) // if a full format fill it out
    {
      while  (x < z)
      {
        result = "0" + result;
        x++;
      }
    }
    if (addMinus) result = "-" + result;
  }
  else result = cc.join("");

  ////if (debugThis)   { debugThis("<b>Validate:</b> -------------------- field2value result " + result + " <br>"); }

  return result;
}

// --------------------------------------------------------------------
// reformatDecimal function to reformat field contents to a valid dec
// --------------------------------------------------------------------

function reformatDecimal(tB)
{
  var tmpStr = tB.value;
  var tmpMask = mask2overlay(tB.mask,true);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatDecimal A  " + tmpStr +  " <br>"); }
  tmpStr = field2value(tmpStr,tB.mask,true);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatDecimal B  " + tmpStr +  " <br>"); }
  tB.value = tmpStr;
  tmpStr = checkThousand(tB);
  if (tmpStr == null) tmpStr = tB.value;
  else tmpStr = tmpStr;
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatDecimal C  " + tmpStr +  " <br>"); }
  var tmpDec = tB.mask.indexOf(deciChar) - tmpStr.indexOf(deciChar);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatDecimal X  " + tmpDec +  " <br>"); }
  tmpStr = overlay(tmpMask,tmpStr,tmpDec);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatDecimal D  " + tmpStr +  " <br>"); }
  return tmpStr
}

// --------------------------------------------------------------------
// reformatInteger function to reformat field contents to a valid int
// --------------------------------------------------------------------

function reformatInteger(tB)
{
  var tmpStr = tB.value;
  var tmpMask = mask2overlay(tB.mask,true);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatInteger A  " + tmpStr +  " <br>"); }

  if (mask.indexOf(">") != -1) tmpNLZ = true;  // No Leading Zeros is true
  else tmpNLZ = false;

  if (tB.mask.indexOf(")") != -1) tmpBrkt = true; // we have brackets for minus
  else tmpBrkt = false;

  if (tB.mask.indexOf("-") != -1) tmpNeg = true; // we have brackets for minus
  else tmpNeg = false;


  var xx = 0;

  for (i=0;i<tB.mask.length;i++) // find out where the integer will start
  {
    if ( !tmpNLZ )
    {
      if ("9>z".indexOf(tB.mask.charAt(i)) == -1) xx++;
      else break;
    }
    else
    {
      if ("9z".indexOf(tB.mask.charAt(i)) == -1) xx++;
      else break;
    }
  }


  tmpStr = field2value(tmpStr,tB.mask,true);  // convert to a db style integer

      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatInteger B  " + xx + "  tmpStr= " + tmpStr + "  tmpBrkt= " + tmpBrkt + " <br>"); }

  if (tmpNLZ)
  {
    xx ++;
    if (tmpStr.indexOf("-") != -1 ) ss = tmpStr.length ;
    else ss = tmpStr.length ;
    xx = xx - ss;

  }
  else if (tmpStr.indexOf("-") != -1) xx--;

    ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatInteger X  " + xx + "   tmpBrkt= " + tmpBrkt + " <br>"); }

  tB.value = tmpStr;

  tmpStr = checkThousand(tB);

  if (tmpStr == null) tmpStr = tB.value;
  else tmpStr = tmpStr;

     ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatInteger C  " + tmpStr +  " <br>"); }




  tmpStr = overlay(tmpMask,tmpStr,xx);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- reformatInteger D  " + tmpStr +  " <br>"); }
  return tmpStr
}


// --------------------------------------------------------------------
// extract logical format
// --------------------------------------------------------------------
function logExtract(mask,x)
{
  var  maskArray = mask.split("/");
  var result  = new Array();
  if (x == null) return maskArray[1];
  else
  {
    if (x == 1) {result[0] = maskArray[0].charAt(0); result[1] =  maskArray[0];}
    if (x == 0) {result[0] = maskArray[1].charAt(0); result[1] =  maskArray[1]; }
    return result;
  }
}


// --------------------------------------------------------------------
// setType function to set data type
// --------------------------------------------------------------------
function setType(tB)
{
  // datatypes =
  tbChar            = false;  // 10 - char
  tbDec             = false;  // 20 - dec
  tbDate            = false;  // 30 - date
  tbInt             = false;  // 40 - int
  tbLog             = false;  // 50 - log
  tbTime            = false;  // 60 - time
  switch (tB.datatype)
  {
    case '10': tbChar = true; break  // 10 - char
    case '20': tbDec  = true; break  // 20 - dec
    case '30': tbDate = true; break  // 30 - date
    case '40': tbInt  = true; break  // 40 - int
    case '50': tbLog  = true; break  // 50 - log
    case '60': tbTime = true; break  // 60 - time
    default: return false; break;
  }
}

// --------------------------------------------------------------------
// Focus function fires first so sets up all vars & format
// puts masked thingie in tB eg: '(___) ___-____'
// --------------------------------------------------------------------
function tbFocus(tB)
{
  negSign       = false;
  negPresent    = false;
  addNegSign    = false;
  negBracket    = false
  decPast       = false;
  decimalPoint  = null;
  startVal      = '';

      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus in " + tB.name + " -------------------------------------------------------------------------------- <br>"); }


  setType(tB);

  if (tbChar) expandMask(tB);
  if (tbTime) convertTimeMask(tB);

  val  = tB.value ==""?"":tB.value;
  mask = tB.mask ==""?"":tB.mask;


  if (tbDec)  fetchDecimals(mask);

      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus - 10= " +  tbChar + " 20= " +   tbDec + " 30= " +   tbDate + " 40= " +   tbInt + " 50= " +   tbLog  + " 60= " +   tbTime + "<br>")  }

  if (tbDec) tB.style.textAlign = "right" ;
  else if (tbInt && mask.indexOf(">") != -1) tB.style.textAlign = "right" ;
  else tB.style.textAlign =  "left" ;

       ////if (debugThis)   { debugThis("<b>Validate:</b> -----------------  after fetchDecimals -- " + decimalPoint + " <br>"); }

  maskLength = mask.length;
  if (tbDec || tbInt)
  {
    x = mask.indexOf("(")
    y = mask.indexOf(")")
    if (x != y) negBracket = true;
    if (negBracket || (mask.indexOf("-") != -1 && decimalPoint != null  && ( mask.indexOf("-") < decimalPoint || mask.indexOf("-") > decimalPoint ))) negSign = true;
    else if (tbInt && mask.indexOf("-") != -1)  negSign = true;

    if (negBracket && negSign) maskLength = mask.length - 1;
    else if (negSign && mask.indexOf("-") != 0) maskLength = mask.length - 1;
    else maskLength = mask.length;
  }
      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- negBracket= " + negBracket + " neg= " + negSign + "  maskLength= "  + maskLength + "  mask.length= "  + mask.length + " val= " + val + " dec= " + decimalPoint  + "  <br>"); }


// --------------------------------------------------------------
// FIELD HAS NO INITIAL VALUE -----------------------------------
// --------------------------------------------------------------
  // if value null....set the starting format eg: '(___) ___-____'
  if(val.length == 0 || val == null || (val.indexOf("?") != -1 && tbDec) )
  {
    for(var i = 0; i <= mask.length; i++)
    {
      var chr = mask.charAt(i);

      //if (tbTime && (chr == 'H' || chr == 'h' || chr == 'M' || chr == 'm' || chr == 'S' || chr == 's' || chr == 'A' || chr == 'a' ) )
      //{
      //  if(chr == "a" || chr == "A") continue;
      //  startVal += spaceChar;
      //  tB.curPos = -1;
      //}
      //else
      if (!tbDec && !tbInt && (chr == 'X' || chr == 'N' || chr == 'A' || chr == '!' || chr == '9') )
      {
        startVal += spaceChar;
        tB.curPos = -1;
      }
      else if (tbDec || tbInt)
      {
        if (chr == '9') startVal += '0';
        else if (chr == deciChar) startVal += deciChar;
        else startVal += "";
        ////if (debugThis)   { debugThis("<b>Validate:</b> Focus  ----------------- WOW 1 = " + tB.curPos + "  i= " + i +  " startVal= " + startVal + "<br>"); }
      }
      else
      {
        startVal += chr;
      }
    }
    if (tbLog)
    {
       var tmpLog = [];
       var tmpVal = "";
       tmpLog[0] = logExtract(mask,0);
       tmpLog[1] = logExtract(mask,1);
       //alert(tmpLog[1][0] + " -- " + tmpLog[1][1]);
       if (tB.value.charAt(0) == tmpLog[0][0] ) tmpVal = tmpLog[0][1];
       else if (tB.value.charAt(0) == tmpLog[1][0] ) tmpVal = tmpLog[1][1];
       else  tmpVal = tmpLog[0][1]; // there is no value so default to false/no
       startVal    = tmpVal;

      //alert(logExtract(mask) + " -- " + logExtract(mask,1) + " -- " + logExtract(mask,0) )

    }
    else if (tbInt)
    {
      var tmpMask = mask2overlay(mask,tbInt);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner A  " + tmpMask +  " <br>"); }
      //var tmpStr = field2value(tB.value,mask,true);

      //if (parseInt(startVal) > 0 ) tmpInt = (mask.length - startVal.length);
      //else tmpInt = mask.length - startVal.length;
      //if (mask.indexOf("-") != -1 || mask.indexOf("(") != -1) tmpInt--;
      tB.value = startVal;

      startVal = reformatInteger(tB);

      //startVal = overlay(tmpMask,startVal,tmpInt);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner B  " + startVal +  " <br>"); }
      //tB.curPos = maskLength;
    }
    else if (tbDec)
    {
      var tmpDec = mask.indexOf(deciChar) - startVal.indexOf(deciChar);
      var tmpMask = mask2overlay(mask,tbDec);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner A  " + tmpMask +  " <br>"); }

      startVal = overlay(tmpMask,startVal,tmpDec);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner B  " + startVal +  " <br>"); }
    }

    ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- in here " + tB.curPos + " : " + startVal + " <br>"); }
    tB.value = startVal;
  }
// --------------------------------------------------------------
// OR FORMAT FIELD VALUE ----------------------------------------
// --------------------------------------------------------------
  else // take the field value and present it....
  {
    if (tbChar)
    {
      var tmpMask = mask2overlay(mask,false);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner C  " + tmpMask +  " <br>"); }
      startVal    = overlay(tmpMask,tB.value,0);
    }
    else if (tbTime)
    {
      var tmpTime = [];
      tmpTime[0] = tB.value.substr(0,2);
      tmpTime[1] = tB.value.substr(2,1);
      tmpTime[2] = tB.value.substr(3,2);

      if (( tmpTime[0] > 24 || tmpTime[0] < 0 ) || (tmpTime[2] > 59 || tmpTime[2] < 0 )) tB.value = "????";

      var tmpMask = mask2overlay(mask,false);
      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- inner TIME  " + tmpMask +  " <br>"); }
      startVal    = overlay(tmpMask,tB.value,0);


    }
    else if (tbLog)
    {
       var tmpLog = [];
       var tmpVal = "";

       tmpLog[0] = logExtract(mask,0);
       tmpLog[1] = logExtract(mask,1);
       //alert(tmpLog[1][0] + " -- " + tmpLog[1][1] + " -- " + tB.value );

       if (tB.value.toLowerCase() == "yes" ) tmpVal = tmpLog[1][1]
       else if (tB.value.toLowerCase() == "no" ) tmpVal = tmpLog[0][1]
       else if (tB.value.charAt(0).toLowerCase() == tmpLog[0][0].toLowerCase() ) tmpVal = tmpLog[0][1];
       else if (tB.value.charAt(0).toLowerCase() == tmpLog[1][0].toLowerCase() ) tmpVal = tmpLog[1][1];
       else  tmpVal = '?';
       startVal    = tmpVal;

    }
    else if (tbInt)
    {

      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus  ----------------- WOW 2 = " + tB.value + "  mask= " + tmpMask + "<br>"); }

      startVal = reformatInteger(tB);

      if (startVal.length > mask.length) startVal = fillString("?", mask.length);

    }
    else if (!tbDec)
    {
      var tmpMask = mask2overlay(mask,false);
      startVal    = overlay(tmpMask,tB.value,0);
    }
    else
    {
      if (tB.value.length > mask.length || (tB.value.indexOf("-") != -1 && !negSign))
      {
        ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- near end " + tB.value.length + " : " + mask.length + " <br>"); }
        startVal = fillString("?", mask.length);
      }
      else
      {
        startVal = reformatDecimal(tB);
        if (startVal.length > mask.length) startVal = fillString("?", mask.length);
      }
    }
    tB.value = startVal;
  }

// --------------------------------------------------------------
// DONE ---------------------------------------------------------
// --------------------------------------------------------------

      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- near end " + tB.curPos + " <br>"); }
  // set proper cursor pos
  if (tbDec) tB.curPos = decimalPoint;
  else if (tbInt) tB.curPos = maskLength;
  else if (tB.curPos == -1) tB.curPos = 0;
  //else if (tB.value.length == maskLength) tB.curPos = tB.value.length;

        ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- end A " + tB.value + " :"  + tB.curPos + " <br>"); }


  setCursorPos(tB,tB.curPos);

  boxEntered = false;

  // set just in case.
  tB.maxlength = maskLength;

 if (tbDec || tbDate || tbLog || tbTime)
  {
        ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- in dec etc " + tB.curPos + " <br>"); }
    tB.select();
    boxEntered = true;
  }
      ////if (debugThis)   { debugThis("<b>Validate:</b> Focus ----------------- end B " + tB.value + " :"  + tB.curPos + " <br>"); }
  return true;
}



// --------------------------------------------------------------------
// Main function
// Gets the current keystroke and deals with it if it is a 'function'
// keystroke eg: cursor, delete etc.
// --------------------------------------------------------------------
function tbFunction(tB)
{
  retVal    = false;
  keyCode   = event.keyCode;
    // grab the mask
  mask      = tB.mask;
  txt       = '';
  if(!checkKeyCode(keyCode)) return;

  setType(tB);

  if (tbDec)  fetchDecimals(mask);
  if (document.selection) txt = document.selection.createRange().text;
  if (boxEntered)
  {
       //if (debugThis)   { debugThis("<b>Validate:</b> Function ----------------- boxEntered " + tbDec +  " point= " + decimalPoint + " <br>"); }
     if (tbDec) setCursorPos(tB,decimalPoint);
     else setCursorPos(tB,0);
     boxEntered = false;
  }
  switch(keyCode)
  {
      case BACKSPACE_KEY:
          var c = getCursorPos(tB);
          ////if (debugThis)   { debugThis("<b>Validate:</b> BACKSPACE_KEY ----- " + c +  " : " + tB.value + "<br>"); }
          if ( (tbDec || tbDate || tbLog || tbInt )&& txt != '')
          {
            tB.value = "";
            txt = '';
            tbFocus(tB);
            if (tbDec) c = decimalPoint;
            else c = 0;
            setCursorPos(tB,c);
            tB.curPos = c;
          }
          if(c >= 0)
          {
            var cMaskCh;
            // get next available char to delete except mask chars

            while(c >= 0)
            {
              c--;
              cMaskCh = mask.charAt(c);

              ////if (debugThis)   { debugThis("<b>Validate:</b> BACKSPACE_KEY -------------------- c= " + c + "   cMaskCh= " + cMaskCh + "<br>"); }

              if (cMaskCh == 'X' || cMaskCh == 'N' || cMaskCh == 'A' || cMaskCh == '!' || cMaskCh == '9' || (tbDec || tbInt && (cMaskCh == 'z' || cMaskCh == '<' || cMaskCh == '>' || cMaskCh == "." || cMaskCh == "," || cMaskCh == '-' || cMaskCh == '(' || cMaskCh == ')')))
              //if(cMaskCh == '9' || cMaskCh == 'X' || cMaskCh == 'A' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == '!' || (tbDec || tbInt && (cMaskCh == "." || cMaskCh == "," || cMaskCh == "-")))
              {               // found a spot.....replace that char with spaceChar
                if (!tbDec && !tbInt)
                {
                  var x = tB.value.substring(0,c);
                  var y = tB.value.substring(c+1,tB.value.length);

                  if (tbInt && cMaskCh == "9") tB.value = x  + "0" +  y;
                  else  tB.value = x + spaceChar + y;

                  setCursorPos(tB,c);
                  tB.curPos = c;
                  break;
                }
                else if (tbInt)
                {
                  //c++;
                  var x = tB.value.substring(0,c);
                  var y = tB.value.substring(c+1,tB.value.length);

                  tB.value = x + y;

                  ////if (debugThis)   { debugThis("<b>Validate:</b> BACKSPACE_KEY ----- c= " + c + "  x= " + x + "  y= " + y + "  tB.value= " + tB.value + "<br>"); }


                  tB.value = reformatInteger(tB);
                  break;

                }
                else // must be dec!!
                {
                  var a = tB.value.charAt(c);
                  if (a == "-" || a == "(" || a == ")" || c  == decimalPoint) break;
                  var x = tB.value.substring(0,c);
                  var y = tB.value.substring(c+1,tB.value.length);
                  if (tB.curPos <= decimalPoint) decPast = false;
                  else decPast = true;

                  ////if (debugThis)   { debugThis("<b>Validate:</b> BACKSPACE_KEY ----- c= " + c + " a= " + a + " mask= " + cMaskCh + "<br>"); }


                  if (cMaskCh == "9" && ( (decPast && "123456789".indexOf(tB.value.charAt(c + 1)) == -1) || ( !decPast && "123456789".indexOf(tB.value.charAt(c - 1)) == -1 ) ) ) tB.value =  x + "0" + y ;
                  else  tB.value =  x + y ;


                  tB.value = reformatDecimal(tB);
                  if (!decPast) c++;
                  setCursorPos(tB,c);
                  tB.curPos = c;
                  break;
                }
              }
            }
          }

          if (tbDec && tB.curPos <= decimalPoint) decPast = false;
          else if (tbDec) decPast = true;
          else decPast = false;
          break;
      case TAB_KEY: // keep track of cursor b4 tabbing out of field ! do some more validation/fill up here
          var c = getCursorPos(tB);
          var log = true;
          tB.curPos = c;
          if (tbDate) log = reformatDate(tB);
          if (tbTime) log = reformatTime(tB);

      //if (debugThis)   { debugThis("<b>Validate:</b> TAB_KEY ----- c= " + c +  " log= " + log + "<br>"); }


          retVal = log;
          break;
      case HOME_KEY: // just move/keep track of cursor
          if (!tbDec)
          {
            setCursorPos(tB,0);
            tB.curPos = 0;
          }
          else
          {   // need to find first char and position there not just first place !!
            var x = tB.value.substr(0,decimalPoint).lastIndexOf(spaceChar) + 1;
            setCursorPos(tB,x);
            tB.curPos = x;
            if (tbDec && tB.curPos <= decimalPoint) decPast = false;
            else decPast = true;
          }
          break;
      case END_KEY: // just move/keep track of cursor
          if (!tbDec)
          {
            setCursorPos(tB,tB.value.length);
            tB.curPos = tB.value.length;
          }
          else
          {  // need to find first char and position there not just first place !!
            var x = tB.value.substr(decimalPoint).indexOf(spaceChar) + decimalPoint;
            setCursorPos(tB,x);
            tB.curPos = x;
            if (tbDec && tB.curPos <= decimalPoint) decPast = false;
            else decPast = true;
          }
          break;
      case ENTER_KEY:
          var c = getCursorPos(tB);
          var log = true;
          tB.curPos = c;
          if (tbDate) log = reformatDate(tB);
          if (tbTime) log = reformatTime(tB);
          retVal = log;
          break;
      case DELETE_KEY:
          var c = getCursorPos(tB);
          var cMaskCh = mask.charAt(c);
          // only allow delete if it's a valid char
          if ( (tbDec || tbDate || tbLog || tbDate)&& txt != '')
          {
            tB.value = "";
            txt = '';
            tbFocus(tB);
            if (tbDate) tB.curPos == 0;
          }
          ////if (debugThis)   { debugThis("<b>Validate:</b> Start DELETE_KEY -------- c= " + c +  " : " + tB.value +  "<br>"); }
          else if (cMaskCh == 'X' || cMaskCh == 'N' || cMaskCh == 'A' || cMaskCh == '!' || cMaskCh == '9' || (tbDec || tbInt && (cMaskCh == 'z' || cMaskCh == '<' || cMaskCh == '>' || cMaskCh == "."  || cMaskCh == '(' || cMaskCh == ')')))
          //if(cMaskCh == '9' || cMaskCh == 'X' || cMaskCh == 'A' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == '!' || cMaskCh == ',' )
          {
            if (!tbDec)
            {
              var x = tB.value.substring(0,c);
              var y = tB.value.substring(c+1,tB.value.length);
              if (tbInt && cMaskCh == "9") tB.value = x + "0" + y;
              else tB.value = x + spaceChar + y;
              setCursorPos(tB,c+1);
              tB.curPos = c+1;
            }
            else
            {
              var a = tB.value.charAt(c);
              if (a == "-" || a == "(" || a == ")" || c  == decimalPoint) break;
              var x = tB.value.substring(0,c);
              var y = tB.value.substring(c+1,tB.value.length);
              if (tB.curPos <= decimalPoint) decPast = false;
              else decPast = true;

              ////if (debugThis)   { debugThis("<b>Validate:</b> DELETE_KEY ----- c= " + c + " a= " + a + " mask= " + cMaskCh + "<br>"); }

              if (cMaskCh == "9" && ( (decPast && "123456789".indexOf(tB.value.charAt(c + 1)) == -1) || ( !decPast && "123456789".indexOf(tB.value.charAt(c - 1)) == -1 ) ) ) tB.value =  x + "0" + y ;
              else  tB.value =  x + y ;

              tB.value =  x + y ;
              tB.value = reformatDecimal(tB);
              if (!decPast) c++;
              setCursorPos(tB,c);
              tB.curPos = c;
              if ( tB.value.substr(tB.curPos,1) == spaceChar && !decPast)
              {
                setCursorPos(tB,c + 1);
                tB.curPos = c + 1;
              }
              if (tbDec && tB.curPos <= decimalPoint) decPast = false;
              else decPast = true;
            }
          }
            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- End delete ---------------------------------- c= " + c + "<br>"); }
          break;
      case LEFT_ARROW_KEY: // just move/keep track of cursor
          var c = getCursorPos(tB);
          if(c > 0)
          {
            setCursorPos(tB,c-1);
            tB.curPos = c-1;
            if (tbDec && tB.curPos <= decimalPoint) decPast = false;
            else decPast = true;
          }
          break;
      case RIGHT_ARROW_KEY: // just move/keep track of cursor
          var c = getCursorPos(tB);
          if(c < tB.value.length)
          {
            setCursorPos(tB,c+1);
            tB.curPos = c+1;
            if (tbDec && tB.curPos <= decimalPoint) decPast = false;
            else decPast = true;
          }
          break;

      default:
          retVal = true;
          break;// adding a new char somewhere in the field
  }

  if ( (tbDec || tbDate || tbLog || tbTime) && boxEntered && txt != '')
  {
    tB.value = "";
    txt = '';
    tbFocus(tB);
    if (tbDec) c = decimalPoint;
    else c = 0;
    tB.curPos = c;
  }
  setCursorPos(tB,tB.curPos);
  return retVal;
}


// --------------------------------------------------------------------
// Other Main function
// Gets the current keystroke and deals with it when it is just a char or numeric...
// --------------------------------------------------------------------

function tbMask(tB)
{
  keyCode       = event.keyCode;
  keyCharacter  = String.fromCharCode(keyCode);
  retVal        = false;
  negSign       = false;
  addNegSign    = false;
  txt           = '';

  var cMaskCh   = '';

      //if (debugThis)   { debugThis("<b>Validate:</b> Mask in " + tB.name + " ---------------------------------------------------------------------------  <br>"); }
  // grab the mask
  var mask = tB.mask ==""?"":tB.mask;

  setType(tB);

  if (tbDec)  fetchDecimals(mask);

  if (tbDec || tbInt)
  {
    x = mask.indexOf("(")
    y = mask.indexOf(")")

    //if (debugThis)   { debugThis("<b>Validate:</b> Mask -------- x " + x + " y " +  y + " mask.length " + mask.length + "<br>")}
    if (x == 0 && y == mask.length - 1) negBracket = true;
  }
        //if (debugThis)   { debugThis("<b>Validate:</b> Mask -------- tbDec " + tbDec + " negBracket " +  negBracket + " decimalPoint " + decimalPoint + "<br>")}
  if ((negBracket || mask.indexOf("-") != -1) && (tbDec || tbInt)) negSign = true;
        //if (debugThis)   { debugThis("<b>Validate:</b> Mask -------- mask -  " +  mask.indexOf("-") + "<br>")}
  if (negBracket && negSign) maskLength = mask.length - 2;
  else if (negSign) maskLength = mask.length - 1;
  else maskLength = mask.length;



  if (tbDec || tbInt)
  {
    if (negBracket)
    {
      if (tB.value.indexOf("(") != -1 && negSign) negPresent = true;
      if (tB.value.indexOf("(") != -1 && !negSign)
      {
        negPresent = false;
        tB.value = fillString("?", tB.value.length) // a neg value has been passed to a non neg mask
      }
    }
    else
    {
      if (tB.value.indexOf("-") != -1 && negSign) negPresent = true;
      if (tB.value.indexOf("-") != -1 && !negSign)
      {
        negPresent = false;
        tB.value = fillString("?", tB.value.length) // a neg value has been passed to a non neg mask
      }
    }
  }
  if (document.selection) txt = document.selection.createRange().text;
  if (boxEntered)
  {
        //if (debugThis)   { debugThis("<b>Validate:</b> Mask ----------------- boxEntered " + tbDec +  " point= " + decimalPoint + " <br>"); }
    if ( txt != '')
    {
      tB.value = "";
      txt = '';
      tbFocus(tB);
    }
    if (tbDec) setCursorPos(tB,tB.value.indexOf(deciChar));
    else if (tbDate || tbTime || tbInt)
    {
      setCursorPos(tB,0);
      tB.curPos = 0;
    }
    else setCursorPos(tB,tB.value.length);
    boxEntered = false;
  }

      //if (debugThis)   { debugThis("<b>Validate:</b> MASK  - 10= " +  tbChar + " 20= " +   tbDec + " 30= " +   tbDate + " 40= " +   tbInt + " 50= " +   tbLog  + " 60= " +   tbTime + "<br>")  }
      //if (debugThis)   { debugThis("<b>Validate:</b> Mask ----------------- keyCode= " + keyCode +  " len= " + tB.value.length + " neg "  + negSign + " <br>"); }
      //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- start A " +  tbDec + " ----- " + tB.curPos +  " keyCode= " + keyCode + " <br>"); }
  switch (keyCode)
  {
    default:

      if (tbLog)
      {

         var tmpLog = [];
         var tmpVal = "";
         tmpLog[0] = logExtract(mask,0);
         tmpLog[1] = logExtract(mask,1);


         if (keyCharacter.toLowerCase() == tmpLog[0][0].toLowerCase() ) tmpVal = tmpLog[0][1];
         else if (keyCharacter.toLowerCase() == tmpLog[1][0].toLowerCase() ) tmpVal = tmpLog[1][1];
         else  break;

         //alert(tmpLog[1][0] + " -- " + tmpLog[1][1] + " -- " + tmpVal);

         tB.value    = tmpVal;
         cMaskCh = "+";
      }
      else if (tbChar || tbTime) // OK may be char or time ************************************************************
      {
        var c = getCursorPos(tB);
            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in B ----------- pos= " + c +  " cMaskCh= " + mask.charAt(c) + " : " + tB.value.length + " <br>"); }
        while(c <= tB.value.length) // get next available to change.....except masking chars
        {
          cMaskCh = mask.charAt(c);

              ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- while B B ----------- " + c +  " cMaskCh= " + cMaskCh + " <br>"); }
          if (cMaskCh == 'X' || cMaskCh == 'N' || cMaskCh == 'A' || cMaskCh == '!' || cMaskCh == '9') break;
          //if(cMaskCh == '9' || cMaskCh == 'X' || cMaskCh == 'A' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == '!' ) break;
          c++;
        }
      }
      else if (tbDate) // OK  is it a date? ***************************************************************************
      {
        var c = getCursorPos(tB);
            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in DATE ----------- pos= " + c +  " cMaskCh= " + mask.charAt(c) + " keyCode " + keyCode + " <br>"); }
        if (keyCode == 47 ) // insert slash date seperator
        {
          cMaskCh = '/';
          ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- while DATE A ----------- " + c +  " cMaskCh= " + cMaskCh + " <br>"); }
          break;
        }
        while(c <= tB.value.length) // get next available to change.....except masking chars
        {
          cMaskCh = mask.charAt(c);
              ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- while DATE B ----------- " + c +  " cMaskCh= " + cMaskCh + " <br>"); }
          if (cMaskCh == '9') break;
          c++;
        }
      }
      else if (tbInt) // is it an integer **********************************************************************************
      {
        var c = getCursorPos(tB) ;

        ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- here  ---c= " + c + " : " + mask.length + " : " + mask + "<br>"); }
        // get next available to change.....except masking chars
        //if (!decPast && keyCode != 46  && tB.value.substring(0,decimalPoint).indexOf(spaceChar) == -1) break;
        if (keyCode == 43 ) // remove neg sign
        {
          if (!negSign) break;
              ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- Hmmmmmmm  --- " + negSign + " : " + mask.length + " : " + mask + "<br>");
          addNegSign = false;
          cMaskCh = "+";
          break;
          ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in Minus  ----------- " + negBracket + " : " + addNegSign + " ; " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }
        }

        if (keyCode == 45 ) // insert neg sign
        {
          if (!negSign) break;
              ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- Hmmmmmmm  --- " + negSign + " : " + mask.length + " : " + mask + "<br>"); }
          for (z=0;z<=mask.length;z++)
          {
            if ( mask.charAt(z) == "-")
            {
              addNegSign = true;
              cMaskCh = mask.charAt(z);
              break;
            }
            else if (negBracket) // put brackets around it instead!!
            {
                addNegSign = true;
                cMaskCh = "-";
                break;
            }
          }
         ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in Minus  ----------- " + negBracket + " : " + addNegSign + " ; " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }
        }
        else  // not neg sign
        {
          xx = 0;
          while(xx < tB.value.length )
          {
            cMaskCh = mask.charAt(xx);

            if (cMaskCh == '9' || cMaskCh == '>' || cMaskCh == 'z'  ) break;
            xx++;
          }
          cMaskCh = "";
          tmpStr = tB.value.substr(xx);
          tmpVal = field2value(tmpStr,mask,true,true);
          tmpLen = tmpVal.length;
          if (negSign) tmpLen = tmpLen + 1;
          if (tmpVal.indexOf("-") != -1) tmpLen = tmpLen - 1;

          ////if (debugThis)   { debugThis("<b>Validate:</b> -----------------HERE!!!!  xx= " + xx + " -- " +  tmpLen + " -- " + numericLength(mask) + " <br>"); }

          if (tmpLen  > numericLength(mask)) break;
          else cMaskCh = "9";
        }

      }
      else if (tbDec) // OK its a decimal **********************************************************************************
      {
        var c = getCursorPos(tB);

        //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- here  --- " + c + " : " + mask.length + " : " + mask + " : " + tB.value.substring(0,decimalPoint) + "<br>"); }
        // get next available to change.....except masking chars

        //if (!decPast && keyCode != 46  && tB.value.substring(0,decimalPoint).indexOf(spaceChar) == -1) break;


		//if (debugThis)   { debugThis("<b>Validate:</b> ----- ----- " + tB.value.substring(0,decimalPoint).indexOf(spaceChar) + " <br>"); }

		if (keyCode == 43 ) // remove neg sign
		{
		  if (!negSign) break;
			  //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- Hmmmmmmm  --- " + negSign + " : " + mask.length + " : " + mask + "<br>"); }
		  xx = tB.value.substring(0,decimalPoint).lastIndexOf(spaceChar);
		  decPast = false;
		  addNegSign = false;
		  cMaskCh = "+";
		  break;
		  c = decimalPoint;
			 //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in Minus  ----------- " + negBracket + " : " + addNegSign + " ; " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }
		}

		if (keyCode == 45 ) // insert neg sign
		{
		  if (!negSign) break;
			  //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- Hmmmmmmm  --- " + negSign + " : " + mask.length + " : " + mask + "<br>"); }
		  for (z=0;z<=mask.length;z++)
		  {
			if ( mask.charAt(z) == "-")
			{
			  addNegSign = true;
			  cMaskCh = mask.charAt(z);
			  if (z < decimalPoint)
			  {
				xx = tB.value.substring(0,decimalPoint).lastIndexOf(spaceChar);
				decPast = false;
			  }
			  else
			  {
				xx = tB.value.substring(decimalPoint,mask.length).indexOf(spaceChar) + (decimalPoint - 1 );
				decPast = true;
			  }
			}
			else if (negBracket) // put brackets around it instead!!
			{
				xx = tB.value.substring(0,decimalPoint).lastIndexOf(spaceChar);
				decPast = false;
				addNegSign = true;
				cMaskCh = "-";
				break;
			}
		  }
		  c = xx;
		 //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in Minus  ----------- " + negBracket + " : " + addNegSign + " ; " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }
		}

        else  // not neg sign
        {

			 //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- NOT Minus  ----------- " + negBracket + " : " + addNegSign + " ; " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }

          while(c < tB.value.length )
          {
            cMaskCh = mask.charAt(c);
                //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- while A ----------- " + tbDec +  " keyCode= " + keyCode + " <br>"); }
            if (keyCode == 46 ) // accept decimal point and set
            {
              c = c++
              tB.curPos = c + 1;
                  ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in A ----------- " + c +  " tB.curPos = " + tB.curPos  + " <br>"); }
              decPast = true;
              break;
            }
            if (cMaskCh == '9' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == '-' || cMaskCh == '(' || cMaskCh == ')') break;
            c++;
          }
        }
        //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- else going to add key  c= " + c +  " keyCode= " + keyCode + " <br>"); }
      }


      // now decide what to do with the value as per mask char ******************************************************
  }
      ////if (debugThis)   { debugThis("<b>Validate:</b>------------------------------------------ cMaskCh " + cMaskCh + " <br>"); }


      //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- going to addkey  c= " + c +  " keyCode= " + keyCode + "  cMaskCh= " + cMaskCh + " <br>"); }

  switch(cMaskCh)
  {

    case "+": // remove a minus or set logical
        if (tbLog) break;
        else if (tbDec||tbInt) addNewKey(tB,"+",c);
        else addNewKey(tB,"+",c);
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- case plus " + xx +  " keyCharacter= " + keyCharacter + " <br>"); }
        break;
    case "-": // add a minus
        if (tbDec||tbInt) addNewKey(tB,keyCharacter,c);
        else addNewKey(tB,"-",c);
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- case minus " + xx +  " keyCharacter= " + keyCharacter + " <br>"); }
        break;
    case thousChar:
        if (!tbDec) addNewKey(tB,thousChar,c);
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- case thousChar " + c +  " keyCharacter= " + keyCharacter + " <br>"); }
        break;
    case deciChar:
        if (!tbDec) addNewKey(tB,deciChar,c);
        else
        {
          c++;
          setCursorPos(tB,c);
          tB.curPos = c;
        }
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- case deciChar " + c +  " keyCharacter= " + keyCharacter + " <br>"); }
        break;
    case '/':  // date seperator
        if (!tbDec) addNewKey(tB,'/',c);
            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- case thousChar " + c +  " keyCharacter= " + keyCharacter + " <br>"); }
        break;
    case '9': // numeric only
        if('0123456789'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case '>': // numeric only
        if('0123456789'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case '<': // numeric only
        if('0123456789'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case 'z': // numeric only
        if('0123456789'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case 'A': // alpha only
        if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case '!': // alpha only
        if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    case 'X': // alphanumeric anything goes!!!
        //if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(keyCharacter) != -1)
        addNewKey(tB,keyCharacter,c);
        break;
    default:
        break;
  }
      //if (debugThis)   { debugThis("<b>Validate:</b> Mask ----WOW--- " + tbDec +  " len= " + tB.value.length + " <br>"); }
  return retVal;
}


// --------------------------------------------------------------------
// Accept a tB, a keycharacter and an integer position
// adds the key to the position and then sets cursor to next available spot
// --------------------------------------------------------------------
function addNewKey(tB,key,pos)
{
  // add the new key to the tB at pos
  startSel      = "";
  endSel        = "";
  tmp           = "";
  elseWhere     = false;
  strTemp       = tB.value;
  maskTemp      = tB.mask;
  tmpString     = "";
  saveStr       = tB.value;

      //if (debugThis)   { debugThis("<b>Validate:</b> -------- addNewKey " + tB.name + " dec= " + tbDec + " decPast= " + decPast + " tB.value= " + tB.value + " decimalPoint= " + decimalPoint +  " pos= " + pos + "  key= " + key + " <br>"); }
  // -------------------------------------------------------------
  // INTEGER FORMAT
  // -------------------------------------------------------------
  if (tbInt)
  {

    tB.value = field2value(strTemp,maskTemp,true);

    lenInt = numericLength(maskTemp);

    ////if (debugThis)   { debugThis("<b>Validate:</b> -------- OK current integer value= "  + tB.value + " intLen= " + lenInt + "  pos= " + pos + " key= " +  key +  "<br>"); }

    //if (!addNegSign && key != "+" && key != "-")
    //{
    //  tB.value = tB.value.substring(1,pos+1) + key ;
    //  //strTemp = tB.value.substring(0,pos) + key +  tB.value.substring(pos,tB.value.length);
    //  //if (debugThis)   { debugThis("<b>Validate:</b> in ONE  "  + tB.value +  "<br>"); }
    //}
    //else
    if (!addNegSign && key == "+" )
    {
      tB.value = trim(tB.value,"-");
      ////if (debugThis)   { debugThis("<b>Validate:</b> in TWO  "  + tB.value +  "<br>"); }
    }
    else if (negBracket && addNegSign)
    {
        tB.value = "(" + tB.value + ")";
        ////if (debugThis)   { debugThis("<b>Validate:</b> in THREE  "  + tB.value +  "<br>"); }
    }
    else if (addNegSign)
    {
        tB.value = key + tB.value;
        ////if (debugThis)   { debugThis("<b>Validate:</b> in FOUR  "  + tB.value +  "<br>"); }
    }
    else if (tB.value == "0" ) // integer is zero
    {
      tB.value = key ;
            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in here  "  + tB.value +  "<br>"); }
    }
    else
    {
      ////if (debugThis)   { debugThis("<b>Validate:</b> ---------------B4--------  in integer  normal= "  + tB.value + "<br>"); }

      if (mask.indexOf(">") != -1)
      {
         tB.value = tB.value.substr(0) + key;

      }
      else
      {
        if (tB.value.indexOf("-") != -1) tB.value = "-" + tB.value.substr(2) + key;
        else tB.value = tB.value.substr(1) + key;

      }

      ////if (debugThis)   { debugThis("<b>Validate:</b> -----------------A------  in integer  normal= "  + tB.value + "<br>"); }


    }

           ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- from checkThousand "  + tB.value +  "<br>"); }

    tB.value = reformatInteger(tB)

            ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- leaving Integer  " + tB.value + " pos = " + pos +  " <br>"); }

    //pos++;
  }


  // -------------------------------------------------------------
  // DECIMAL FORMAT
  // -------------------------------------------------------------
  else if (tbDec)
  {
    if (!decPast)  // before decimal point
    {
      pos--;
      if (pos < decimalPoint) elseWhere = true;

      if (elseWhere && !addNegSign && key != "+" && key != "-")
      {
        strTemp = tB.value.substring(0,pos) + key +  tB.value.substring(pos,tB.value.length);
        //if (debugThis)   { debugThis("<b>Validate:</b> in elseWhere  "  + strTemp +  "<br>"); }
      }
              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- going to field2value ----------- pos= " + pos + " : " + strTemp + " elseWhere= " + elseWhere + " <br>"); }
      tB.value = field2value(strTemp,maskTemp,true);
              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- from field2value "  + tB.value +  "<br>"); }

      if (!addNegSign && key == "+" )
      {
          if (tB.value.indexOf("-") < decimalPoint) tB.value = tB.value.substring(1,tB.value.length);
          else tB.value = tB.value.substring(0,tB.value.length - 1);
      }
      else if (negBracket && addNegSign)
      {
          tB.value = "(" + tB.value + ")";
      }
      else if (addNegSign)
      {
          xx = tB.value.substring(0,tB.value.indexOf(deciChar)) ;
          tB.value = key + xx + tB.value.substring(tB.value.indexOf(deciChar),tB.value.length);
      }
      else if (tB.value.substring(0,tB.value.indexOf(deciChar)) == "0" && !elseWhere) // decimal is zero or 0.xxx
      {
        tB.value = key +  tB.value.substring(tB.value.indexOf(deciChar),tB.value.length);
              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- in here  "  + tB.value +  "<br>"); }
      }
      else if (tB.value.substring(0,tB.value.indexOf(deciChar)) == "-0" && !elseWhere) // decimal is minus zero or -0.xxx
      {
        tB.value = "-" + key +  tB.value.substring(tB.value.indexOf(deciChar),tB.value.length);
      }
      else if (!elseWhere)
      {
		tB.value = tB.value.substring(0,tB.value.indexOf(deciChar) -1 ) + key +  tB.value.substring(tB.value.indexOf(deciChar),tB.value.length);
		//tB.value = tB.value.substring(0,tB.value.indexOf(deciChar)) + key +  tB.value.substring(tB.value.indexOf(deciChar),tB.value.length);
	  }

              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- from now---- "  + tB.value +  "<br>"); }
      tmpString = checkThousand(tB);
      if (tmpString == null) tB.value = saveStr;
      else tB.value = tmpString;
              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- from checkThousand "  + tB.value +  "<br>"); }
      var tmpMask = mask2overlay(maskTemp,tbDec);
      var tmpDec = tB.mask.indexOf(deciChar) - tB.value.indexOf(deciChar);
      tB.value = overlay(tmpMask,tB.value,tmpDec);
              //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- leaving checkThousand  " + tB.value +  " <br>"); }
      if (elseWhere)  pos++;
      if (addNegSign) pos = decimalPoint;
    }
    else //  past decimalpoint
    {
          //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- going nowhere " + elseWhere + "<br>"); }
      tB.value = field2value(strTemp,maskTemp,true);
      if ( addNegSign)
      {
        xx = tB.value.substr(decimalPoint) ;
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- addNegSign " + xx + " : " + tB.value.substr(0,decimalPoint) + " : " + tB.value.substr(decimalPoint, xx.indexOf(spaceChar) ) + " : " + key + "<br>"); }
        tB.value =  tB.value + key ;
            //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- tmpString A  " + tB.value + "<br>"); }
        tB.value = reformatDecimal(tB);
        key = "";
        pos = decimalPoint;
      }
      else
      {
        tmpString = checkPostDec(tB,key,pos);
          //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- tmpString AA " + tmpString + "<br>"); }
        tB.value = tB.value.substr(0,tB.value.indexOf(deciChar)) + tmpString;
          //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- tmpString BB " + tB.value + "<br>"); }
        tB.value = reformatDecimal(tB);
      }
        //if (debugThis)   { debugThis("<b>Validate:</b> ----------------- tmpString " + tB.value + "<br>"); }
      pos++;
    }
  }
  // -------------------------------------------------------------
  // DATE FORMAT
  // -------------------------------------------------------------
  else if (tbDate)
  {
        ////if (debugThis)   { debugThis("<b>Validate:</b> ---------- date   pos = " + pos +  " key= " + key +   " <br>"); }
    startSel = tB.value.substring(0,pos);
    endSel = tB.value.substring(pos+1,tB.value.length);

    if (key == "/")
    {
      tB.value = stripDateField(tB.value,tB.mask);

      var tmpMask = mask2overlay(maskTemp,false);

      tB.value = overlay(tmpMask,tB.value,0);


    }
    else
    {
      tB.value = startSel + key + endSel;
    }

    // advance cursor to next spaceChar
    while(pos < tB.value.length)
    {
      curChar = tB.value.charAt(pos);
      if(curChar == spaceChar) break;
      pos++;
    }

      ////if (debugThis)   { debugThis("<b>Validate:</b> ------- end date  "  + tB.value + " tmpMask " + tmpMask + " pos " + pos + "<br>"); }
  }
  // -------------------------------------------------------------
  // LOGICAL FORMAT
  // -------------------------------------------------------------
  else if (tbLog)
  {
    ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- logical  tB.mask.charAt(pos) = " + tB.mask.charAt(pos) +  " key= " + key +   " <br>"); }
  }
  // -------------------------------------------------------------
  // ALL OTHER FORMATS
  // -------------------------------------------------------------
  else // not decimal, integer, date or logical !!
  {
    // add the new key to the tB at pos
    startSel = tB.value.substring(0,pos);
    endSel = tB.value.substring(pos+1,tB.value.length);

    ////if (debugThis)   { debugThis("<b>Validate:</b> ----------------- not the others!  tB.mask.charAt(pos) = " + tB.mask.charAt(pos) +  " key= " + key +   " <br>"); }

    if (tB.mask.charAt(pos) == "!" ) key = key.toUpperCase();
    tB.value = startSel + key + endSel;
      // advance cursor to next spaceChar
    while(pos < tB.value.length)
    {
      curChar = tB.value.charAt(pos);
      if(curChar == spaceChar) break;
      pos++;
    }
  }
  if (elseWhere) elseWhere = false;
  setCursorPos(tB,pos);
  tB.curPos = pos;
}

// -------------------------------------------------------------
// Strip file
// -------------------------------------------------------------
function stripDateField(arrg,mask)
{
  var cnt = 0;

  ////if (debugThis)   { debugThis("<b>Validate:</b> -------- " + arrg + " mask= " + mask  +   " <br>"); }
  for (i=0;i<arrg.length;i++)
  {
    if (mask.charAt(i) == '/') cnt++;

      ////if (debugThis)   { debugThis("<b>Validate:</b> -------- B  tmp " + tmp + " char " + arrg.charAt(i) + " mask= " + mask.charAt(i)  + "cnt= " + cnt +  " <br>"); }


    if (arrg.charAt(i) != spaceChar && arrg.charAt(i) != "/") tmp += arrg.charAt(i);

    if (cnt == 2 && tmp.length > 2 && tmp.length < 4) tmp = tmp.substr(0,2) + "0" + tmp.substr(2);

    if (cnt == 1 && tmp.length < 2 ) tmp = "0" + tmp ;



  }

  return tmp;

}






// -------------------------------------------------------------
// Reformat Date Field
// -------------------------------------------------------------
function reformatTime(tB)
{


  var tmpTime = [];
  tmpTime[0] = tB.value.substr(0,2);
  tmpTime[1] = tB.value.substr(2,1);
  tmpTime[2] = tB.value.substr(3,2);
  tmpTime[0] = quicktrim(tmpTime[0]);
  tmpTime[2] = quicktrim(tmpTime[2]);
  if ( tmpTime[0].length < 1 ) tmpTime[0] = tmpTime[0] + "0";
  if ( tmpTime[0].length < 2 ) tmpTime[0] = tmpTime[0] + "0";
  if ( tmpTime[2].length < 1 ) tmpTime[2] = tmpTime[2] + "0";
  if ( tmpTime[2].length < 2 ) tmpTime[2] = tmpTime[2] + "0";
  if (( tmpTime[0] > 24 || tmpTime[0] < 0 ) || (tmpTime[2] > 59 || tmpTime[2] < 0 ))
    {
      //defaultField.value = tB.name; ??
      alert("Invalid Time");
      var rNew = tB.createTextRange();
      rNew.moveStart('character', tB.length) ;
      rNew.select();
      tB.focus();
      return false;
    }
    else
    {
      tB.value = tmpTime[0] + tmpTime[1] + tmpTime[2];
      return true;
	}
}


// -------------------------------------------------------------
// Reformat Date Field
// -------------------------------------------------------------
function reformatDate(tB)
{
  var strTemp   = "";
  var tmpArray  = [];
  yy            = currCentury - 1900; // equates to the century parameter in Progress
  strTemp  = trim(tB.value);
  tmpArray = strTemp.split("/");

      ////if (debugThis)   { debugThis("<b>Validate:</b> ---  reformatDate  " + tB.value + " : "  + tmpArray + " : " + yy + " <br>"); }



  //alert(">" + tmpArray[0] + "<  >" + tmpArray[1] + "<  >" + tmpArray[2] + "<");

  if (tmpArray[0] == "" && tmpArray[1] == "" && tmpArray[2] == null) return true;
  else if (tmpArray[2] == null) myDate = 'NaN';
  else
  {
    strTemp = tmpArray[2];

    if (strTemp.length == 2) // assume only two chars entered eg 03 for 2003 or 96 for 1996!!!!
    {
      if (parseInt(strTemp) > yy) tmpArray[2] = "19" + strTemp;
      else tmpArray[2] = "20" + strTemp;
    }

    if (dateFormat == "dmy")
    {  // now convert to UK date and test
      var newDay   = tmpArray[0];
      var newMonth = tmpArray[1];
      var newYear  = tmpArray[2];
      if ((newMonth <= 0) || (newMonth > 12)) { newMonth = '??'; }
      var newDate  = newMonth + '/' + newDay + '/' + newYear;
      var myDate = new Date( newDate );
    }
    else if (dateFormat == "mdy")
    {  // now convert to other date and test
      var newMonth = tmpArray[0];
      var newDay   = tmpArray[1];
      var newYear  = tmpArray[2];
      if ((newMonth <= 0) || (newMonth > 12)) { newMonth = '??'; }
      var newDate  = newMonth + '/' + newDay + '/' + newYear;
      var myDate = new Date( newDate );
    }
  }
  ////if (debugThis)   { debugThis("<b>Validate:</b> ---reformatDate 2 " + myDate + " : "  + tmpArray +  " <br>"); }

  if (myDate == 'NaN' )
  {
    //defaultField.value = tB.name; ??
    alert("Invalid Date");
    var rNew = tB.createTextRange();
    rNew.moveStart('character', tB.length) ;
    rNew.select();
    tB.focus();
    return false;
  }
  else   tB.value = tmpArray.join('/');

  return true;
}

// ---------------------------------------------------------------------
// Check and insert a thousands char in a decimal field only
//  if key is blank then it will re-asses the field
// ---------------------------------------------------------------------
function checkThousand(tB)
{
  cc            = '';
  dd            = '';
  strTemp       = tB.value;
  maskTemp      = tB.mask;
  tmpString     = "";
  tmpMask       = "";
  maskArray     = [];
  someArray     = [];
  tempArray     = [];
  errCondition  = false;
  deciPoint     = false;
  negPos        = null;
  negBrkt       = null;
  y             = 0;

      ////if (debugThis)   { debugThis("<b>Validate:</b> ----------- start  checkThousand " + strTemp + "  :  " +  maskTemp + " : " + decimalPoint + "<br>")}

  if (tbInt) decimalPoint = (strTemp.length / 2);

  a = maskTemp.indexOf("(")
  b = maskTemp.indexOf(")")
  if (a < decimalPoint && b > decimalPoint) negBrkt = true;


  for (i=0;i<strTemp.length;i++)  // work our way through the value and remove the thousand char
  {
    aa = strTemp.charAt(i);
    if (aa != thousChar)
    {
      if (aa == "-") negPos = true;
      else if (aa == "(" ||aa == ")") negPos = true;
      else dd += aa;
    }
  }
  if (negPos != null && negBrkt == null &&  maskTemp.indexOf("-") < decimalPoint) dd = "-" + dd;
  else if (negPos != null && negBrkt == null && maskTemp.indexOf("-") >= decimalPoint ) dd = dd + "-";


        ////if (debugThis)   { debugThis("<b>Validate:</b> ----------- in  checkThousand " + strTemp + "  :  " +  dd + "<br>")}
  strTemp   = dd;
  someArray = strTemp.split("");
  someArray = someArray.reverse();
  maskArray = maskTemp.split("");
  maskArray = maskArray.reverse();
        ////if (debugThis)   { debugThis("<b>Validate:</b> A   " + maskArray + " : " + someArray +  " : " + deciChar + "<br>")}
  for (i=0;i<maskArray.length;i++)  // work our way back through the mask, when we get to the decimalPoint we can think about inserting the thousand char
  {
    aa = maskArray[i];
        ////if (debugThis)   { debugThis("<b>Validate:</b> AA   " + aa + "  i= " + i +  " ?= " +  deciPoint +  "<br>")}
    if ( aa == deciChar)
    {
        ////if (debugThis)   { debugThis("<b>Validate:</b> B   " + i + " : " + x +  "<br>")}
      deciPoint = true;
      for (x=0;x<someArray.length;x++)  // work our way back through the string to get to the decimalPoint, now we have a matching string!!!
      {
        bb = someArray[x];
        if (bb == deciChar)
        {
          y = x;
            ////if (debugThis)   { debugThis("<b>Validate:</b> BB   " + bb + " : " + y +  "<br>")}
        }
      }
    }
        ////if (debugThis)   { debugThis("<b>Validate:</b> B   i= " + i + "  x= " + x  + "  aa= " + aa + "  bb= " + bb + " someArray[y]= " + someArray[y] +  "<br>")}
    if (deciPoint && aa == thousChar)
    {      ////if (debugThis)   { debugThis("<b>Validate:</b> C   " + deciPoint + " : " + y +  "<br>")}
        if (someArray[y] != spaceChar && someArray[y] != "-" && someArray[y] != undefined) someArray.splice(y,0,thousChar);
    }
    if (deciPoint && aa == "-" && someArray[y] != "-" && someArray[y] != "" && someArray[y] != undefined) // trying to fill the negative with something other than a negative!!!!
    {
      errCondition = true;
    }
    y++;
  }
  someArray = someArray.reverse();

  if (tbInt) decimalPoint = null;

  if (errCondition)
  {
      ////if (debugThis)   { debugThis("<b>Validate:</b> done checkThousand " + tmpString + " Error? "  + errCondition + "<br>"); }
    return null;
  }
  else
  {
    tmpString = someArray.join("");
    if (negPos && negBrkt)
    {
      tmpString = "(" + tmpString + ")";
    }
        ////if (debugThis)   { debugThis("<b>Validate:</b> -----------  done checkThousand " + tmpString + " Error? "  + errCondition + "<br>"); }
    return tmpString;
  }
}


// ---------------------------------------------------------------------
// Check the backend of a decimal field only
// ---------------------------------------------------------------------
function checkPostDec(tB,key,pos)
{
  cc        = '';
  dd        = '';
  maskTemp  = tB.mask.substr(decimalPoint);
  strTemp   = tB.value.substr(tB.value.indexOf(deciChar));
  negPos    = null;
  negMask   = null;
  pos       = pos - decimalPoint;
  negMask   = maskTemp.indexOf("-") == -1?null:true; // does the mask support a neg sign?
      ////if (debugThis)   { debugThis("<b>Validate:</b> ---------------- in checkPostDec "  + strTemp + " mask " + maskTemp + " key " + key + " pos " + pos + " negMask " + negMask +  "<br>"); }
  for (i=0;i<strTemp.length;i++)  // work our way  through the value and remove the thousand char
  {
      aa = strTemp.charAt(i);
      if (aa == "-") negPos = i; // negPos tells us there is a neg sign in the string already.
      dd += aa;
  }
  strTemp = dd;
  x       = negMask == null?maskTemp.length:maskTemp.length - 1 ;
  y       = strTemp.length
  z       = false;
      //if ( strTemp.indexOf(spaceChar) == maskTemp.lastIndexOf("-") && negPos == null) z = true;
      ////if (debugThis)   { debugThis("<b>Validate:</b> in checkPostDec "  + strTemp + " mask " + maskTemp + " key " + key + " pos " + pos + " x " + x + " y " + y + " z " + z +  "<br>"); }
  for (i=0;i<=x ;i++)
  {
    aa = strTemp.charAt(i);
    bb = maskTemp.charAt(i);
    dd = strTemp.charAt(i + 1);
    if (i < pos)
    {
      cc += aa;
          ////if (debugThis)   { debugThis("<b>Validate:</b> in for B i= " + i + " x= " + x + " aa= " + aa   + " bb= " + bb + " cc= " + cc + " dd= " + dd + "<br>"); }
    }
    else if (i == pos)
    {
      if ( bb == "9") cc += key; // overwrite if mask is 9 else insert
      else if (bb != "9" && aa == spaceChar) cc += key; // overwrite if mask is < & current char is space else insert
      else if (y != x)  cc += key + aa;
      else cc += aa;
          ////if (debugThis)   { debugThis("<b>Validate:</b> in for C i= " + i + " x= " + x + " aa= " + aa   + " bb= " + bb + " cc= " + cc + " dd= " + dd + "<br>"); }
    }
    else if ( i > pos)
    {
      if (bb != "9" && aa == "0"  && dd == spaceChar) cc += spaceChar;
      else if (bb != "9" && aa != spaceChar && dd == spaceChar) cc += aa;
      else cc += aa;
          ////if (debugThis)   { debugThis("<b>Validate:</b> in for D i= " + i + " x= " + x + " aa= " + aa   + " bb= " + bb + " cc= " + cc + " dd= " + dd + "<br>"); }
    }
    else
    {
          ////if (debugThis)   { debugThis("<b>Validate:</b> in for E i= " + i + " x= " + x + " aa= " + aa   + " bb= " + bb + " cc= " + cc + " dd= " + dd + "<br>"); }
    }
  }
  if (negMask)
  {
    if (negPos != null) cc += "-";
    else cc += spaceChar
  }
      ////if (debugThis)   { debugThis("<b>Validate:</b> done checkPostDec " + pos + " : " +  cc +"<br>"); }
  return cc;
}

// --------------------------------------------------------------------
// Loops thru pasted value and checks each char against the mask
//
// Leaves old value and return false if *any* char is off
// Creates new masked value if all pasted data is ok
// --------------------------------------------------------------------
function tbPaste(tB)
{

      ////if (debugThis)   { debugThis("<b>Validate:</b> Paste in " + tB.name + " -------------------------------------------------------  <br>"); }

  // grab the tB value and the mask
  var pastedVal = window.clipboardData.getData("Text");
  var mask = tB.mask;
  var newVal = '';
  var curPastedVal = 0;

  for(var i=0;i<mask.length;i++)
  {
    var cMaskCh = mask.charAt(i);
    // if current mask pos allows entry
    if (cMaskCh == 'X' || cMaskCh == 'N' || cMaskCh == 'A' || cMaskCh == '!' || cMaskCh == '9' || (tbDec || tbInt && (cMaskCh == 'z' || cMaskCh == '<' || cMaskCh == '>' || cMaskCh == "." || cMaskCh == "," || cMaskCh == '-' || cMaskCh == '(' || cMaskCh == ')')))
    //if(cMaskCh == '9' || cMaskCh == 'X' || cMaskCh == 'A' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == '!')
    {
      var currentPastedChar = pastedVal.charAt(curPastedVal);
      // check each current mask char against new keystroke
      // return false if any are out of sync
      if(cMaskCh == '9' || cMaskCh == '>' || cMaskCh == '<' || cMaskCh == 'z' || cMaskCh == 'z' || cMaskCh == '<' || cMaskCh == '>' || cMaskCh == "." || cMaskCh == "," || cMaskCh == '-' || cMaskCh == '(' || cMaskCh == ')')
      {
        if('0123456789'.indexOf(currentPastedChar) == -1)
        return false;
      }
      else if(cMaskCh == 'A' || cMaskCh == '!')
      {
        if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.indexOf(currentPastedChar) == -1)
        return false;
      }
      else if(cMaskCh == 'X')
      {
        if('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.indexOf(currentPastedChar) == -1)
        return false;
      }
      else
      {
        return false;
      }

      // add new key
      newVal += currentPastedChar;
      curPastedVal++;
    }
    else
    {
      // add mask literal
      newVal += cMaskCh;
    }
  }
  tB.value = newVal;
  return false;
}

// --------------------------------------------------------------------
// Check if keycode should be actioned rather than character key !
// --------------------------------------------------------------------

function checkKeyCode(key)
{
  //if (debugThis)   { debugThis("<b>Validate:</b> checkKeyCode " + key + " <br>"); }

  inEdit = true;

  switch(key)
  {
    case 22: return true; break;
    case 3:  return true; break;
    case 24: return true; break;
    case 9:  return true; break;
    case 46: return true; break;
    case 8:  return true; break;
    case 13: return true; break;
    case 39: return true; break;
    case 40: return true; break;
    case 38: return true; break;
    case 37: return true; break;
    case 36: return true; break;
    case 35: return true; break;
    case 33: return true; break;
    case 34: return true; break;
    case 20: return true; break;
    case 27: return true; break;
    default: return false; break;
  }
}


// --------------------------------------------------------------------
// Google gems
// --------------------------------------------------------------------
function getCursorPos(el)
{
  var sel, rng, r2, i=-1;

  if(document.selection && el.createTextRange)
  {
    sel=document.selection;
    if(sel)
    {
      r2=sel.createRange();
      rng=el.createTextRange();
      rng.setEndPoint("EndToStart", r2);
      i=rng.text.length;
    }
  }
  return i;
}
function setCursorPos(field,pos)
{
  if (field.createTextRange)
  {
    var r = field.createTextRange();
    r.moveStart('character', pos);
    r.collapse();
    r.select();
  }
}

// ---------------------------------------------------------------------
// Trim things from a parsed value
// ---------------------------------------------------------------------

function trim(arrg,chars)
{

  if (arguments.length == 1) chars = spaceChar;

      ////if (debugThis)   { debugThis("<b>Validate:</b> ---  trim  " + arrg + " chars= "  + chars +  " <br>"); }

  var tmp = "";
  for (i=0;i<arrg.length;i++) // run thro begining of value to remove chars, stop once we hit a real value
  {
    if (arrg.charAt(i) != chars)
    {
      arrg = arrg.substr(i);
      break;
    }
  }
  for (i=0;i<arrg.length;i++) // run thro end of value to remove chars, stop once we hit a real value
  {
    if (arrg.charAt(i) != chars) tmp += arrg.charAt(i);
    else break;

  }

  return tmp;
}

// ---------------------------------------------------------------------
// Faster Trim to trim things from a parsed value
// ---------------------------------------------------------------------


function quicktrim (str) {
	str = str.replace(/^\s+/, '');
	for (var i = str.length - 1; i >= 0; i--) {
		if (/\S/.test(str.charAt(i))) {
			str = str.substring(0, i + 1);
			break;
		}
	}
	return str;

}





// ---------------------------------------------------------------------
// Run through fields to display as per mask
// ---------------------------------------------------------------------
function forceDisplay(DForm,DDatatype,DElem)
{
  //go thro the elements and see if its a match to get its element #
 if (DElem != null)
 {
  	for (var i = 0; i < document.forms[DForm].elements.length; i++ )
  	{
		if (document.forms[DForm].elements[i].name  == DElem)
  		{
			alert(document.forms[DForm].elements[i]);
	  		if (document.forms[DForm].elements[i].datatype == DDatatype )  document.forms[DForm].elements[i].focus();
		}
	}
 }
 else
 {
  for (i=0; i<document.forms[DForm].elements.length; i++)
  {
     if (document.forms[DForm].elements[i].datatype == DDatatype )  document.forms[DForm].elements[i].focus();
  }
 }
}



// ---------------------------------------------------------------------
// Run through fields to display as per mask
// ---------------------------------------------------------------------
function focusDisplay(FieldId)
{

  document.getElementById(FieldId).focus();

}

