/* Norwegian keyboard layouts
  *
 * To use:
 *  Point to this js file into your page header: <script src='layouts/no.js' type='text/javascript'></script>
 *  Initialize the keyboard using: $('input').keyboard({ layout: 'norwegian-qwerty-1' });
 *
 * Needs additional keyactions:
 *             $.extend($.keyboard.keyaction, {
 *								 no: function (base) {
 *								 base.options.layout = 'norwegian-qwerty-1';
 *								 base.reveal(true);
 *								 },
 *								 se: function (base) {
 *								 base.options.layout = 'norwegian-sami-1';
 *								 base.reveal(true);
 *								 }
 *								 });
 *	and parameters to set up in the init:
 *							 display      : {
 *							 'no': 'NO',
 *							 'se': 'NOS'
 *							 },
 *
 * license for this file: WTFPL, unless the source layout site has a problem with me using them as a reference
 */
 jQuery.keyboard.layouts['norwegian-qwerty-1'] = {
	'name':'norwegian-qwerty-1',
	'normal':[
		'| 1 2 3 4 5 6 7 8 9 0 + \\ {b}',
		'{t} q w e r t y u i o p \u00e5 \u00a8 ',
		'a s d f g h j k l \u00f8 \u00e6 {enter}',
		'{s} < z x c v b n m , . - {s}',
		'{se} {space} {alt} {accept}'
	],
	'shift':[
		'\u00a7 ! \' # \u00a4 % & / ( ) = ? ` {b}',
		'{t} Q W E R T Y U I O P \u00c5 ^ *',
		'A S D F G H J K L \u00d8 \u00c6 {enter}',
		'{s} > Z X C V B N M ; : _ {s}',
		'{se} {space} {alt} {accept}'
	],
	'alt':[
		'{empty} {empty} @ \u00a3 $ {empty} {empty} { [ ] } {empty} \u00b4 {b}',
		'{t} {empty} {empty} \u20ac {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} ~ {empty}',
		'{empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {enter}',
		'{s} {empty} {empty} {empty} {empty} {empty} {empty} {empty} \u03bc {empty} {empty} {empty} {s}',
		'{se} {space} {alt} {accept}'
	],
	'alt-shift':[
		'{empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {b}',
		'{t} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty}',
		'{empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {empty} {enter}',
		'{s} {empty} {empty} {empty} {empty} {empty} {empty} {empty} \u039c {empty} {empty} {empty} {s}',
		'{se} {space} {alt} {accept}'
	],
	'lang':['no',
		'nb',
		'nn']
};
jQuery.keyboard.layouts['norwegian-sami-1'] = {
	'name':'norwegian-sami-1',
	'normal':[
		'| 1 2 3 4 5 6 7 8 9 0 + \u00EF {b}',
		'{t} \u00E1 \u0161 \u0065 \u0072 \u0074 \u0167 \u0075 \u0069 \u006F \u0070 \u00E5 \u014B \u017E ',
		'\u0061 \u0073 \u0064 \u0066 \u0067 \u0068 \u006A \u006B \u006C \u00F8 \u00E6 \u0111 {enter}',
		'{s} \u007A \u010D \u0063 \u0076 \u0062 \u006E \u006D , . - {s}',
		'{no} {space} {alt} {accept}'
	],
	'shift':[
		'\u00a7 ! \' # \u00a4 % & / ( ) = ? \u00CF {b}',
		'{t} \u00C1 \u0160 \u0045 \u0052 \u0054 \u0166 \u0055 \u0049 \u004F \u0050 \u00C5 \u014A \u017D',
		'\u0041 \u0053 \u0044 \u0046 \u0047 \u0048 \u004A \u004B \u004C \u00D8 \u00C6 \u0110 {enter}',
		'{s} \u005A \u010C \u0043 \u0056 \u0042 \u004E \u004D ; : _ {s}',
		'{no} {space} {alt} {accept}'
	],
	'lang':['se']
};


// Keyboard Language
// please update this section to match this language and email me with corrections!
// no = ISO 639-1 code for Norwegian
// ***********************
jQuery.keyboard.language.no = {
	display : {
		'a'      : '\u2714:Accept (Shift-Enter)', // check mark - same action as accept
		'accept' : 'Accept:Accept (Shift-Enter)',
		'alt'    : 'AltGr:Alternate Graphemes',
		'b'      : '\u2190:Backspace',    // Left arrow (same as &larr;)
		'bksp'   : 'Bksp:Backspace',
		'c'      : '\u2716:Cancel (Esc)', // big X, close - same action as cancel
		'cancel' : 'Cancel:Cancel (Esc)',
		'clear'  : 'C:Clear',             // clear num pad
		'combo'  : '\u00f6:Toggle Combo Keys',
		'dec'    : '.:Decimal',           // decimal point for num pad (optional), change '.' to ',' for European format
		'e'      : '\u21b5:Enter',        // down, then left arrow - enter symbol
		'enter'  : 'Enter:Enter',
		'lock'   : '\u21ea Lock:Caps Lock', // caps lock
		's'      : '\u21e7:Shift',        // thick hollow up arrow
		'shift'  : 'Shift:Shift',
		'sign'   : '\u00b1:Change Sign',  // +/- sign for num pad
		'space'  : '&nbsp;:Space',
		't'      : '\u21e5:Tab',          // right arrow to bar (used since this virtual keyboard works with one directional tabs)
		'tab'    : '\u21e5 Tab:Tab'       // \u21b9 is the true tab symbol (left & right arrows)
	},
	// Message added to the key title while hovering, if the mousewheel plugin exists
	wheelMessage : 'Use mousewheel to see other keys',
};

// no = ISO 639-1 code for Northern Sami
// ***********************
jQuery.keyboard.language.se = {
	display : {
		'a'      : '\u2714:Accept (Shift-Enter)', // check mark - same action as accept
		'accept' : 'Accept:Accept (Shift-Enter)',
		'alt'    : 'AltGr:Alternate Graphemes',
		'b'      : '\u2190:Backspace',    // Left arrow (same as &larr;)
		'bksp'   : 'Bksp:Backspace',
		'c'      : '\u2716:Cancel (Esc)', // big X, close - same action as cancel
		'cancel' : 'Cancel:Cancel (Esc)',
		'clear'  : 'C:Clear',             // clear num pad
		'combo'  : '\u00f6:Toggle Combo Keys',
		'dec'    : '.:Decimal',           // decimal point for num pad (optional), change '.' to ',' for European format
		'e'      : '\u21b5:Enter',        // down, then left arrow - enter symbol
		'enter'  : 'Enter:Enter',
		'lock'   : '\u21ea Lock:Caps Lock', // caps lock
		's'      : '\u21e7:Shift',        // thick hollow up arrow
		'shift'  : 'Shift:Shift',
		'sign'   : '\u00b1:Change Sign',  // +/- sign for num pad
		'space'  : '&nbsp;:Space',
		't'      : '\u21e5:Tab',          // right arrow to bar (used since this virtual keyboard works with one directional tabs)
		'tab'    : '\u21e5 Tab:Tab'       // \u21b9 is the true tab symbol (left & right arrows)
	},
	// Message added to the key title while hovering, if the mousewheel plugin exists
	wheelMessage : 'Use mousewheel to see other keys',
};