var defaultEmptyOK = false;

//set up basic character groups
var digits = "0123456789";
var lowercaseLetters = "abcdefghijklmnopqrstuvwxyz";
var uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
var whitespace = " \t\n\r";
var nameDelimiters = "-. ";
var decimalPointDelimiter = ".";
var daysInMonth = makeArrayFromString(31,29,31,30,31,30,31,31,30,31,30,31);

//set up allowed characters for specific data types

//phone numbers
var phoneNumberDelimiters = "()- ";
var digitsInUSPhoneNumber = 10;
var validUSPhoneChars = digits + phoneNumberDelimiters;
var validWorldPhoneChars = digits + phoneNumberDelimiters + "+";

//electronic addresses
var validDomainNameChars = digits + uppercaseLetters + lowercaseLetters + "-_.";

//snail mail addresses
var addressDelimiters = ".,/-" + whitespace;
var validAddressCharacters = addressDelimiters + digits + uppercaseLetters + lowercaseLetters;

//US mail address parameters
var digitsInZIPCode1 = 5;
var digitsInZIPCode2 = 9;
var ZIPCodeDelimiters = "-";
var ZIPCodeDelimeter = "-";
var validZIPCodeChars = digits + ZIPCodeDelimiters;
var USStateCodes = "AL|AK|AS|AZ|AR|CA|CO|CT|DE|DC|FM|FL|GA|GU|HI|ID|IL|IN|IA|KS|KY|LA|ME|MH|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|MP|OH|OK|OR|PW|PA|PR|RI|SC|SD|TN|TX|UT|VT|VI|VA|WA|WV|WI|WY|AE|AA|AE|AE|AP";
var USStateCodeDelimiter = "|";

//Canadian mail address parameters
var cdnProvCodes = "BC|AB|SK|MB|ON|QC|NF|PE|NS|NB|NT|YT|NU";
var postalCodeDelimiter = " ";
var validPostalCodeChars = digits + lowercaseLetters + uppercaseLetters + postalCodeDelimiter;
var charsInPostalCode = 6;
var cdnProvCodeDelimiter = "|";

//credit card parameters
var creditCardDelimiters = " ";

function makeArray(n) {
   for (var i = 1; i <= n; i++) {
      this[i] = 0;
   } 
   this[length] = n;
   return this;
}

function makeArrayFromString() {
   for (var i = 1; i <= makeArrayFromString.arguments.length; i++){
      this[i] = makeArrayFromString.arguments[i];
   }
   this[length] = makeArrayFromString.arguments.length;
   return this;
}

function isEmpty(s) {
    return ((s == null) || (s.length == 0))
}

function isWhitespace(s) {
    var i;

    if (isEmpty(s)) return true;
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if (whitespace.indexOf(c) == -1) return false; // not whitespace
    }
    return true;
}

function stripCharsInBag (s, bag){
    var i;
    var returnString = "";
    for (i = 0; i < s.length; i++)
    {   
        // Check that current character isn't whitespace.
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function stripCharsNotInBag (s, bag){
    var i;
    var returnString = "";
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if (bag.indexOf(c) != -1) returnString += c;
    }
    return returnString;
}

function stripWhitespace (s){
   return stripCharsInBag (s, whitespace)
}

function charInString (c, s){
    for (i = 0; i < s.length; i++){
       if (s.charAt(i) == c) return true;
    }
    return false
}

function stripInitialWhitespace (s){
    var i = 0;
    while ((i < s.length) && charInString (s.charAt(i), whitespace))
       i++;
    return s.substring (i, s.length);
}

function isLetter (c){
   return ( ((c >= "a") && (c <= "z")) || ((c >= "A") && (c <= "Z")) )
}

function isDigit (c){
   return ((c >= "0") && (c <= "9"))
}

function isLetterOrDigit (c){
   return (isLetter(c) || isDigit(c))
}

function isInteger (s){
    var i;
    if (isEmpty(s)) 
       if (isInteger.arguments.length == 1) return defaultEmptyOK;
       else return (isInteger.arguments[1] == true);
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if (!isDigit(c)) return false;
    }
    return true;
}

function isSignedInteger (s){
   if (isEmpty(s)) 
       if (isSignedInteger.arguments.length == 1) return defaultEmptyOK;
       else return (isSignedInteger.arguments[1] == true);
    else {
        var startPos = 0;
        var secondArg = defaultEmptyOK;
        if (isSignedInteger.arguments.length > 1)
            secondArg = isSignedInteger.arguments[1];
        if ( (s.charAt(0) == "-") || (s.charAt(0) == "+") )
           startPos = 1;    
        return (isInteger(s.substring(startPos, s.length), secondArg))
    }
}

function isPositiveInteger (s){
    var secondArg = defaultEmptyOK;
    if (isPositiveInteger.arguments.length > 1)
        secondArg = isPositiveInteger.arguments[1];
    return (isSignedInteger(s, secondArg)
         && ( (isEmpty(s) && secondArg)  || (parseInt (s) > 0) ) );
}

function isNonnegativeInteger (s){
    var secondArg = defaultEmptyOK;
    if (isNonnegativeInteger.arguments.length > 1)
        secondArg = isNonnegativeInteger.arguments[1];
    return (isSignedInteger(s, secondArg)
         && ( (isEmpty(s) && secondArg)  || (parseInt (s) >= 0) ) );
}

function isNegativeInteger (s){
    var secondArg = defaultEmptyOK;
    if (isNegativeInteger.arguments.length > 1)
        secondArg = isNegativeInteger.arguments[1];
    return (isSignedInteger(s, secondArg)
         && ( (isEmpty(s) && secondArg)  || (parseInt (s) < 0) ) );
}

function isNonpositiveInteger (s){
    var secondArg = defaultEmptyOK;
    if (isNonpositiveInteger.arguments.length > 1)
        secondArg = isNonpositiveInteger.arguments[1];
    return (isSignedInteger(s, secondArg)
         && ( (isEmpty(s) && secondArg)  || (parseInt (s) <= 0) ) );
}

function isFloat (s){
    var i;
    var seenDecimalPoint = false;
    if (isEmpty(s)) 
       if (isFloat.arguments.length == 1) return defaultEmptyOK;
       else return (isFloat.arguments[1] == true);
    if (s == decimalPointDelimiter) return false;
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if ((c == decimalPointDelimiter) && !seenDecimalPoint) seenDecimalPoint = true;
        else if (!isDigit(c)) return false;
    }
    return true;
}

function isSignedFloat (s){
    if (isEmpty(s)) 
       if (isSignedFloat.arguments.length == 1) return defaultEmptyOK;
       else return (isSignedFloat.arguments[1] == true);
    else {
        var startPos = 0;
        var secondArg = defaultEmptyOK;
        if (isSignedFloat.arguments.length > 1)
            secondArg = isSignedFloat.arguments[1];
        if ( (s.charAt(0) == "-") || (s.charAt(0) == "+") )
           startPos = 1;    
        return (isFloat(s.substring(startPos, s.length), secondArg))
    }
}

function isAlphabetic (s){
    var i;
    if (isEmpty(s)) 
       if (isAlphabetic.arguments.length == 1) return defaultEmptyOK;
       else return (isAlphabetic.arguments[1] == true);
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if (!isLetter(c))
        return false;
    }
    return true;
}

function isAlphanumeric (s){
    var i;
    if (isEmpty(s)) 
       if (isAlphanumeric.arguments.length == 1) return defaultEmptyOK;
       else return (isAlphanumeric.arguments[1] == true);
    for (i = 0; i < s.length; i++)
    {   
        var c = s.charAt(i);
        if (! (isLetter(c) || isDigit(c) ) )
        return false;
    }
    return true;
}

function reformat (s){
    var arg;
    var sPos = 0;
    var resultString = "";
    for (var i = 1; i < reformat.arguments.length; i++) {
       arg = reformat.arguments[i];
       if (i % 2 == 1) resultString += arg;
       else {
           resultString += s.substring(sPos, sPos + arg);
           sPos += arg;
       }
    }
    return resultString;
}

function reformatWebURL(s) {
  if (isEmpty(s)) 
     if (reformatWebURL.arguments.length == 1) return defaultEmptyOK;
     else return (reformatWebURL.arguments[1] == true);
  return ("http://"+s);
}

function makeTitleCase(s){
  if (isEmpty(s)) 
     if (makeTitleCase.arguments.length == 1) return defaultEmptyOK;
     else return (makeTitleCase.arguments[1] == true);
  count = 1;
  ws = 0;
  s = s.charAt(0).toUpperCase()+s.substring(1,s.length);
  while (count < s.length){
    if (isWhitespace(s.charAt(count)) || (s.charAt(count) == ".") || (s.charAt(count) == "-")) ws = 1;
    else if ((ws == 1) && (isLetter(s.charAt(count)))){
      s = s.substring(0,count)+s.charAt(count).toUpperCase()+s.substring(count+1,s.length);
      ws = 0;
    }
    count++;
  }
  return s;
}

function isUSPhoneNumber (s){
    if (isEmpty(s)) 
       if (isUSPhoneNumber.arguments.length == 1) return defaultEmptyOK;
       else return (isUSPhoneNumber.arguments[1] == true);
    return (isInteger(s) && s.length == digitsInUSPhoneNumber)
}

function isInternationalPhoneNumber (s){
    if (isEmpty(s)) {
       if (isInternationalPhoneNumber.arguments.length == 1) return defaultEmptyOK;
       else return (isInternationalPhoneNumber.arguments[1] == true);
    }
    return isPositiveInteger(s);
}

function isZIPCode (s){
   if (isEmpty(s)) 
       if (isZIPCode.arguments.length == 1) return defaultEmptyOK;
       else return (isZIPCode.arguments[1] == true);
   return (isInteger(s) && 
            ((s.length == digitsInZIPCode1) ||
             (s.length == digitsInZIPCode2)))
}

function isPostalCode (s){
   if (isEmpty(s)){
       if (isPostalCode.arguments.length == 1) return defaultEmptyOK;
       else return (isPostalCode.arguments[1] == true);
   }
   if (!isAlphanumeric(s)) return false;
   if (s.length == charsInPostalCode){
     var count = 0;
     var status = "";
     while (count < s.length){
       if ((parseFloat(count%2)) == 0) status = isLetter(s.charAt(count));
       else status = isDigit(s.charAt(count));     
       if (status == false) return status
       count++;
     }
   return status;
   }
   else return false;
}

function isStateCode(s){
    if (isEmpty(s)) 
       if (isStateCode.arguments.length == 1) return defaultEmptyOK;
       else return (isStateCode.arguments[1] == true);
    return ( (USStateCodes.indexOf(s) != -1) &&
             (s.indexOf(USStateCodeDelimiter) == -1) )
}

function isProvinceCode(s) {
    if (isEmpty(s))
        if (isProvinceCode.arguments.length == 1) return defaultEmptyOK;
        else return (isProvinceCode.arguments[1] == true);
    return( (cdnProvCodes.indexOf(s) != -1) &&
            (s.indexOf(cdnProvCodeDelimiter) == -1)  )
}

function isEmail (s){
    if (isEmpty(s)) {
       if (isEmail.arguments.length == 1) return defaultEmptyOK;
       else return (isEmail.arguments[1] == true); }
    if (isWhitespace(s)) return false;
    var i = 1;
    var sLength = s.length;
    while ((i < sLength) && (s.charAt(i) != "@"))
    { i++ }
    if ((i >= sLength) || (s.charAt(i) != "@")) return ("no @ sign");
    else atloc = i;
    j = i+1;
    i += 1;
    while ((j < sLength) && (validDomainNameChars.indexOf(s.charAt(j)) != -1))
    { j++ }
    if (j < sLength) return("invalid character in domain name: "+s.charAt(j));
    while ((i < sLength) && (s.charAt(i) != "."))
    { i++ }
    if (i == sLength) return("no . in domain name");
    if (i == (atloc +1)) return("not enough space between @ and .");
    k = atloc+1;
    while (k < sLength){
      if ((s.charAt(k) == ".") && (s.charAt(k+1) == ".")) return("too many .'s");
      k++
    }
    l = sLength;
    while ((i < sLength -2) && (l != i) && (s.charAt(l) != "."))
    { l = l-1 }
    if ((i >= sLength - 2) || (s.charAt(i) != ".") || (l >= sLength - 2)) return("not enough chars after .");
    else return true;
}

function isURL (s)
{   if (isEmpty(s)) 
       if (isURL.arguments.length == 1) return defaultEmptyOK;
       else return (isURL.arguments[1] == true);
    if (isWhitespace(s)) return false;
    var i = 0;
    var j = 0;
    var URLstart = 0;
    var sLength = s.length;
    while ((j < sLength) && (validDomainNameChars.indexOf(s.charAt(j)) != -1))
    { j++ }
    if (j < sLength) return("invalid character in domain name: "+s.charAt(j));
    while ((i < sLength) && (s.charAt(i) != "."))
    { i++ }
    if (i == sLength) return("no . in domain name");
    if (i == (URLstart)) return("not enough space before first .");
    k = URLstart+1;
    while (k < sLength)
    {
      if ((s.charAt(k) == ".") && (s.charAt(k+1) == ".")) return("too many .'s");
      k++
    }
    l = sLength;
    while ((i < sLength -2) && (l != i) && (s.charAt(l) != "."))
    { l = l-1 }
    if ((i >= sLength - 2) || (s.charAt(i) != ".") || (l >= sLength - 2)) return("not enough chars after .");
    else return true;
}

function isYear (s){
    if (isEmpty(s)) 
       if (isYear.arguments.length == 1) return defaultEmptyOK;
       else return (isYear.arguments[1] == true);
    if (!isNonnegativeInteger(s)) return false;
    else return ((s.length == 4) || (s.length == 2));
}

function isIntegerInRange (s, a, b){
    if (isEmpty(s)) 
       if (isIntegerInRange.arguments.length == 1) return defaultEmptyOK;
       else return (isIntegerInRange.arguments[1] == true);
    if (!isInteger(s, false)) return false;
    var num = parseInt (s);
    return ((num >= a) && (num <= b));
}

function isMonth (s){
    if (isEmpty(s)) 
       if (isMonth.arguments.length == 1) return defaultEmptyOK;
       else return (isMonth.arguments[1] == true);
    return isIntegerInRange (s, 1, 12);
}

function isDay (s){
    if (isEmpty(s)) 
       if (isDay.arguments.length == 1) return defaultEmptyOK;
       else return (isDay.arguments[1] == true);   
    return isIntegerInRange (s, 1, 31);
}

function daysInFebruary (year){
    return (  ((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0) ) ) ? 29 : 28 );
}

function isDate (year, month, day){ 
    if (! (isYear(year, false) && isMonth(month, false) && isDay(day, false))) return false;
    var intYear = parseInt(year);
    var intMonth = parseInt(month);
    var intDay = parseInt(day);
    if (intDay > daysInMonth[intMonth]) return false; 
    if ((intMonth == 2) && (intDay > daysInFebruary(intYear))) return false;
    return true;
}

function prompt (s){
    window.status = s
}

function warnInvalid (theField,s){
//    theField.focus()
    theField.select()
    alert(s)
    return false
}

function checkString (theField, s, emptyOK){
    if (checkString.arguments.length == 2) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    if (isWhitespace(theField.value)) 
       return warnEmpty (theField, s);
    else return true;
}

function checkStateCode (theField, emptyOK){
    if (checkStateCode.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else
    {  theField.value = theField.value.toUpperCase();
       if (!isStateCode(theField.value, false)) 
          return warnInvalid (theField, "Invalid State Code");
       else return true;
    }
}

function checkProvinceCode (theField, emptyOK)
{   if (checkProvinceCode.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else
    {  theField.value = theField.value.toUpperCase();
       if (!isProvinceCode(theField.value, false)) 
          return warnInvalid (theField, "Invalid Province Code");
       else return true;
    }
}

function reformatZIPCode (ZIPString){
    if (ZIPString.length == 5) return ZIPString;
    else return (reformat (ZIPString, "", 5, "-", 4));
}

function checkZIPCode (theField, emptyOK){
    if (checkZIPCode.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else
    { var normalizedZIP = stripCharsInBag(theField.value, ZIPCodeDelimiters)
      if (!isZIPCode(normalizedZIP, false)) 
         return warnInvalid (theField, "Invalid Zip Code");
      else 
      {
         theField.value = reformatZIPCode(normalizedZIP)
         return true;
      }
    }
}

function checkPostalCode (theField, emptyOK){
    if (checkPostalCode.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else{
      var normalizedPostalCode = stripCharsInBag(theField.value, postalCodeDelimiter)
      if (!isPostalCode(normalizedPostalCode, false)) 
         return warnInvalid (theField, "Invalid Postal Code");
      else {
         theField.value = theField.value.toUpperCase();
         theField.value = reformat(stripCharsInBag(theField.value,postalCodeDelimiter),"",3,postalCodeDelimiter,3);
         return true;
      }
    }
}

function reformatUSPhone (USPhone)
{   return (reformat (USPhone, "(", 3, ") ", 3, "-", 4))
}

function checkUSPhone (theField, emptyOK)
{   if (checkUSPhone.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else
    {  var normalizedPhone = stripCharsInBag(theField.value, phoneNumberDelimiters)
       if (!isUSPhoneNumber(normalizedPhone, false)) 
          return warnInvalid (theField, "Invalid NA Phone Number");
       else 
       {
          theField.value = reformatUSPhone(normalizedPhone)
          return true;
       }
    }
}

function checkInternationalPhone (theField, emptyOK)
{   if (checkInternationalPhone.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else
    {  if (!isInternationalPhoneNumber(stripCharsInBag(theField.value,phoneNumberDelimiters))) {
          return warnInvalid (theField, "Invalid International Phone");
       }
       else return true;
    }
}

function checkName(theField,emptyOK){
    if (checkName.arguments.length == 1) emptyOK = defaultEmptyOK;
    if (isEmpty(theField.value)) return emptyOK;
    else {
        if (!isAlphabetic(stripCharsInBag(theField.value,nameDelimiters))){
          warnInvalid(theField,theField.name+" contains invalid characters");
          return false;
        }
        else {
          theField.value = makeTitleCase(theField.value);
          return true;
        }
    }
}

function checkAddress(theField, emptyOK){
    if (checkAddress.arguments.length == 1) emptyOK = defaultEmptyOK;
    if (isEmpty(theField.value)) return emptyOK;
    else {
      if (!isEmpty(stripCharsInBag(theField.value,validAddressCharacters))) return warnInvalid(theField,theField.name+ " contains invalid characters");
      else {
        theField.value = makeTitleCase(theField.value);
        return true
      }
    }
}

function checkEmail (theField, emptyOK){
    if (checkEmail.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else {
      emailStatus = isEmail(theField.value, false)
      if (emailStatus != true) return warnInvalid (theField, "Invalid Email Address");
      else return true;
    }
}

function checkURL (theField, emptyOK){
    if (checkURL.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    else {
      var tempURL = theField.value;
      if ((tempURL.indexOf("http://") >= 0) && (tempURL.indexOf("http://") < tempURL.length)) theField.value = tempURL.substring(tempURL.indexOf("http://")+7,tempURL.length);
      URLStatus = isURL(theField.value, false)
      if (URLStatus != true) return warnInvalid (theField, "Invalid URL");
      else {
        theField.value = reformatWebURL(theField.value);
        return true;
      }
    }
}

function checkYear (theField, emptyOK){
    if (checkYear.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    if (!isYear(theField.value, false)) 
       return warnInvalid (theField, "Invalid Year");
    else {
    if (theField.value.length == 2) theField.value = (parseInt(theField.value)+1900);
    return true;
    }
}

function checkMonth (theField, emptyOK){
    if (checkMonth.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    if (!isMonth(theField.value, false)) 
       return warnInvalid (theField, "Invalid Month");
    else return true;
}

function checkDay (theField, emptyOK){
    if (checkDay.arguments.length == 1) emptyOK = defaultEmptyOK;
    if ((emptyOK == true) && (isEmpty(theField.value))) return true;
    if (!isDay(theField.value, false)) 
       return warnInvalid (theField, "Invalid Day");
    else return true;
}

function checkDate (yearField, monthField, dayField, labelString, OKtoOmitDay){
    if (checkDate.arguments.length == 4) OKtoOmitDay = false;
    if (!isYear(yearField.value)) return warnInvalid (yearField, "Invalid Year");
    else if (yearField.value.length == 2) yearField.value = (parseInt(yearField.value)+1900);
    if (!isMonth(monthField.value)) return warnInvalid (monthField, "Invalid Month");
    if ( (OKtoOmitDay == true) && isEmpty(dayField.value) ) return true;
    else if (!isDay(dayField.value)) 
       return warnInvalid (dayField, "Invalid Day");
    if (isDate (yearField.value, monthField.value, dayField.value))
       return true;
    alert ("The " + labelString + " is invalid" )
    return false
}

function checkMDY(theField,emptyOK){
    if (checkMDY.arguments.length == 1) emptyOK = defaultEmptyOK;
    if (isEmpty(theField.value)) return emptyOK;
    else{
      var dateString = stripCharsInBag(theField.value,"-/ ");
      var mm = dateString.substring(0,2);
      var dd = dateString.substring(2,4);
      var yyyy = dateString.substring(4,theField.value.length);
      if (!isMonth(mm)) return warnInvalid(theField,theField.name + " contains an invalid month. Format must be MM/DD/YYYY.");
      if (!isDay(dd)) return warnInvalid(theField,theField.name + " contains an invalid day. Format must be MM/DD/YYYY.");
      if (!isYear(yyyy)) return warnInvalid(theField,theField.name + " contains an invalid year. Format must be MM/DD/YYYY.");
      else if (yyyy.length == 2) yyyy = (parseInt(yyyy)+1900);
      if (isDate(yyyy.toString(),mm.toString(),dd.toString())){
        theField.value = mm+"/"+dd+"/"+yyyy;
        return true;
      }
      else{
        warnInvalid(theField,theField.name + " contains an invalid date");
        return false;
      }
    }
}

function getRadioButtonValue (radio){
    for (var i = 0; i < radio.length; i++)
    {   if (radio[i].checked) { break }
    }
    return radio[i].value
}

function checkCreditCard (radio, theField){
    var cardType = getRadioButtonValue (radio)
    var normalizedCCN = stripCharsInBag(theField.value, creditCardDelimiters)
    if (!isCardMatch(cardType, normalizedCCN)) 
       return warnInvalid (theField, "Not a valid " + cardType + " Number");
    else 
    {  theField.value = normalizedCCN
       return true
    }
}


function isCreditCard(st) {
  if (st.length > 19)
    return (false);
  sum = 0; mul = 1; l = st.length;
  for (i = 0; i < l; i++) {
    digit = st.substring(l-i-1,l-i);
    tproduct = parseInt(digit ,10)*mul;
    if (tproduct >= 10)
      sum += (tproduct % 10) + 1;
    else
      sum += tproduct;
    if (mul == 1)
      mul++;
    else
      mul--;
  }
  if ((sum % 10) == 0)
    return (true);
  else
    return (false);
}

function isVisa(cc){
  if (((cc.length == 16) || (cc.length == 13)) &&
      (cc.substring(0,1) == 4))
    return isCreditCard(cc);
  return false;
}

function isMasterCard(cc){
  firstdig = cc.substring(0,1);
  seconddig = cc.substring(1,2);
  if ((cc.length == 16) && (firstdig == 5) &&
      ((seconddig >= 1) && (seconddig <= 5)))
    return isCreditCard(cc);
  return false;

}

function isAmericanExpress(cc){
  firstdig = cc.substring(0,1);
  seconddig = cc.substring(1,2);
  if ((cc.length == 15) && (firstdig == 3) &&
      ((seconddig == 4) || (seconddig == 7)))
    return isCreditCard(cc);
  return false;

}

function isDinersClub(cc){
  firstdig = cc.substring(0,1);
  seconddig = cc.substring(1,2);
  if ((cc.length == 14) && (firstdig == 3) &&
      ((seconddig == 0) || (seconddig == 6) || (seconddig == 8)))
    return isCreditCard(cc);
  return false;
}


function isCarteBlanche(cc){
  return isDinersClub(cc);
}


function isDiscover(cc){
  first4digs = cc.substring(0,4);
  if ((cc.length == 16) && (first4digs == "6011"))
    return isCreditCard(cc);
  return false;

}

function isEnRoute(cc){
  first4digs = cc.substring(0,4);
  if ((cc.length == 15) &&
      ((first4digs == "2014") ||
       (first4digs == "2149")))
    return isCreditCard(cc);
  return false;
}

function isJCB(cc){
  first4digs = cc.substring(0,4);
  if ((cc.length == 16) &&
      ((first4digs == "3088") ||
       (first4digs == "3096") ||
       (first4digs == "3112") ||
       (first4digs == "3158") ||
       (first4digs == "3337") ||
       (first4digs == "3528")))
    return isCreditCard(cc);
  return false;
}

function isAnyCard(cc){
  if (!isCreditCard(cc))
    return false;
  if (!isMasterCard(cc) && !isVisa(cc) && !isAmericanExpress(cc) && !isDinersClub(cc) &&
      !isDiscover(cc) && !isEnRoute(cc) && !isJCB(cc)) {
    return false;
  }
  return true;
}

function isCardMatch (cardType, cardNumber){
	cardType = cardType.toUpperCase();
	var doesMatch = true;
	if ((cardType == "VISA") && (!isVisa(cardNumber)))
		doesMatch = false;
	if ((cardType == "MASTERCARD") && (!isMasterCard(cardNumber)))
		doesMatch = false;
	if ( ( (cardType == "AMERICANEXPRESS") || (cardType == "AMEX") )
                && (!isAmericanExpress(cardNumber))) doesMatch = false;
	if ((cardType == "DISCOVER") && (!isDiscover(cardNumber)))
		doesMatch = false;
	if ((cardType == "JCB") && (!isJCB(cardNumber)))
		doesMatch = false;
	if ((cardType == "DINERS") && (!isDinersClub(cardNumber)))
		doesMatch = false;
	if ((cardType == "CARTEBLANCHE") && (!isCarteBlanche(cardNumber)))
		doesMatch = false;
	if ((cardType == "ENROUTE") && (!isEnRoute(cardNumber)))
		doesMatch = false;
	return doesMatch;
}
