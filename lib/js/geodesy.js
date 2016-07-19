/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Vector handling functions                                          (c) Chris Veness 2011-2016  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/geodesy/docs/module-vector3d.html                               */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

'use strict';


/**
 * Library of 3-d vector manipulation routines.
 *
 * In a geodesy context, these vectors may be used to represent:
 *  - n-vector representing a normal to point on Earth's surface
 *  - earth-centered, earth fixed vector (≡ Gade’s ‘p-vector’)
 *  - great circle normal to vector (on spherical earth model)
 *  - motion vector on Earth's surface
 *  - etc
 *
 * Functions return vectors as return results, so that operations can be chained.
 * @example var v = v1.cross(v2).dot(v3) // ≡ v1×v2⋅v3
 *
 * @module vector3d
 */


/**
 * Creates a 3-d vector.
 *
 * The vector may be normalised, or use x/y/z values for eg height relative to the sphere or
 * ellipsoid, distance from earth centre, etc.
 *
 * @constructor
 * @param {number} x - X component of vector.
 * @param {number} y - Y component of vector.
 * @param {number} z - Z component of vector.
 */
function Vector3d(x, y, z) {
  // allow instantiation without 'new'
  if (!(this instanceof Vector3d)) return new Vector3d(x, y, z);

  this.x = Number(x);
  this.y = Number(y);
  this.z = Number(z);
}


/**
 * Adds supplied vector to ‘this’ vector.
 *
 * @param   {Vector3d} v - Vector to be added to this vector.
 * @returns {Vector3d} Vector representing sum of this and v.
 */
Vector3d.prototype.plus = function(v) {
  if (!(v instanceof Vector3d)) throw new TypeError('v is not Vector3d object');

  return new Vector3d(this.x + v.x, this.y + v.y, this.z + v.z);
};


/**
 * Subtracts supplied vector from ‘this’ vector.
 *
 * @param   {Vector3d} v - Vector to be subtracted from this vector.
 * @returns {Vector3d} Vector representing difference between this and v.
 */
Vector3d.prototype.minus = function(v) {
  if (!(v instanceof Vector3d)) throw new TypeError('v is not Vector3d object');

  return new Vector3d(this.x - v.x, this.y - v.y, this.z - v.z);
};


/**
 * Multiplies ‘this’ vector by a scalar value.
 *
 * @param   {number}   x - Factor to multiply this vector by.
 * @returns {Vector3d} Vector scaled by x.
 */
Vector3d.prototype.times = function(x) {
  x = Number(x);

  return new Vector3d(this.x * x, this.y * x, this.z * x);
};


/**
 * Divides ‘this’ vector by a scalar value.
 *
 * @param   {number}   x - Factor to divide this vector by.
 * @returns {Vector3d} Vector divided by x.
 */
Vector3d.prototype.dividedBy = function(x) {
  x = Number(x);

  return new Vector3d(this.x / x, this.y / x, this.z / x);
};


/**
 * Multiplies ‘this’ vector by the supplied vector using dot (scalar) product.
 *
 * @param   {Vector3d} v - Vector to be dotted with this vector.
 * @returns {number} Dot product of ‘this’ and v.
 */
Vector3d.prototype.dot = function(v) {
  if (!(v instanceof Vector3d)) throw new TypeError('v is not Vector3d object');

  return this.x*v.x + this.y*v.y + this.z*v.z;
};


/**
 * Multiplies ‘this’ vector by the supplied vector using cross (vector) product.
 *
 * @param   {Vector3d} v - Vector to be crossed with this vector.
 * @returns {Vector3d} Cross product of ‘this’ and v.
 */
Vector3d.prototype.cross = function(v) {
  if (!(v instanceof Vector3d)) throw new TypeError('v is not Vector3d object');

  var x = this.y*v.z - this.z*v.y;
  var y = this.z*v.x - this.x*v.z;
  var z = this.x*v.y - this.y*v.x;

  return new Vector3d(x, y, z);
};


/**
 * Negates a vector to point in the opposite direction
 *
 * @returns {Vector3d} Negated vector.
 */
Vector3d.prototype.negate = function() {
  return new Vector3d(-this.x, -this.y, -this.z);
};


/**
 * Length (magnitude or norm) of ‘this’ vector
 *
 * @returns {number} Magnitude of this vector.
 */
Vector3d.prototype.length = function() {
  return Math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
};


/**
 * Normalizes a vector to its unit vector
 * – if the vector is already unit or is zero magnitude, this is a no-op.
 *
 * @returns {Vector3d} Normalised version of this vector.
 */
Vector3d.prototype.unit = function() {
  var norm = this.length();
  if (norm == 1) return this;
  if (norm == 0) return this;

  var x = this.x/norm;
  var y = this.y/norm;
  var z = this.z/norm;

  return new Vector3d(x, y, z);
};


/**
 * Calculates the angle between ‘this’ vector and supplied vector.
 *
 * @param   {Vector3d} v
 * @param   {Vector3d} [vSign] - If supplied (and out of plane of this and v), angle is signed +ve if
 *     this->v is clockwise looking along vSign, -ve in opposite direction (otherwise unsigned angle).
 * @returns {number} Angle (in radians) between this vector and supplied vector.
 */
Vector3d.prototype.angleTo = function(v, vSign) {
  if (!(v instanceof Vector3d)) throw new TypeError('v is not Vector3d object');

  var sinθ = this.cross(v).length();
  var cosθ = this.dot(v);

  if (vSign !== undefined) {
    if (!(vSign instanceof Vector3d)) throw new TypeError('vSign is not Vector3d object');
    // use vSign as reference to get sign of sinθ
    sinθ = this.cross(v).dot(vSign)<0 ? -sinθ : sinθ;
  }

  return Math.atan2(sinθ, cosθ);
};


/**
 * Rotates ‘this’ point around an axis by a specified angle.
 *
 * @param   {Vector3d} axis - The axis being rotated around.
 * @param   {number}   theta - The angle of rotation (in radians).
 * @returns {Vector3d} The rotated point.
 */
Vector3d.prototype.rotateAround = function(axis, theta) {
  if (!(axis instanceof Vector3d)) throw new TypeError('axis is not Vector3d object');

  // en.wikipedia.org/wiki/Rotation_matrix#Rotation_matrix_from_axis_and_angle
  // en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Quaternion-derived_rotation_matrix
  var p1 = this.unit();
  var p = [ p1.x, p1.y, p1.z ]; // the point being rotated
  var a = axis.unit();          // the axis being rotated around
  var s = Math.sin(theta);
  var c = Math.cos(theta);
  // quaternion-derived rotation matrix
  var q = [
    [ a.x*a.x*(1-c) + c,     a.x*a.y*(1-c) - a.z*s, a.x*a.z*(1-c) + a.y*s],
    [ a.y*a.x*(1-c) + a.z*s, a.y*a.y*(1-c) + c,     a.y*a.z*(1-c) - a.x*s],
    [ a.z*a.x*(1-c) - a.y*s, a.z*a.y*(1-c) + a.x*s, a.z*a.z*(1-c) + c    ],
  ];
  // multiply q × p
  var qp = [0, 0, 0];
  for (var i=0; i<3; i++) {
    for (var j=0; j<3; j++) {
      qp[i] += q[i][j] * p[j];
    }
  }
  var p2 = new Vector3d(qp[0], qp[1], qp[2]);
  return p2;
  // qv en.wikipedia.org/wiki/Rodrigues'_rotation_formula...
};


/**
 * String representation of vector.
 *
 * @param   {number} [precision=3] - Number of decimal places to be used.
 * @returns {string} Vector represented as [x,y,z].
 */
Vector3d.prototype.toString = function(precision) {
  var p = (precision === undefined) ? 3 : Number(precision);

  var str = '[' + this.x.toFixed(p) + ',' + this.y.toFixed(p) + ',' + this.z.toFixed(p) + ']';

  return str;
};


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
if (typeof module != 'undefined' && module.exports) module.exports = Vector3d; // ≡ export default Vector3d


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* Geodesy tools for an ellipsoidal earth model                       (c) Chris Veness 2005-2016  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-convert-coords.html                                     */
/* www.movable-type.co.uk/scripts/geodesy/docs/module-latlon-ellipsoidal.html                     */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

'use strict';
if (typeof module!='undefined' && module.exports) var Vector3d = require('./vector3d.js'); // ≡ import Vector3d from 'vector3d.js'
if (typeof module!='undefined' && module.exports) var Dms = require('./dms.js');           // ≡ import Dms from 'dms.js'


/**
 * Library of geodesy functions for operations on an ellipsoidal earth model.
 *
 * Includes ellipsoid parameters and datums for different coordinate systems, and methods for
 * converting between them and to cartesian coordinates.
 *
 * q.v. Ordnance Survey ‘A guide to coordinate systems in Great Britain’ Section 6
 * www.ordnancesurvey.co.uk/docs/support/guide-coordinate-systems-great-britain.pdf.
 *
 * @module   latlon-ellipsoidal
 * @requires dms
 */


/**
 * Creates lat/lon (polar) point with latitude & longitude values, on a specified datum.
 *
 * @constructor
 * @param {number}       lat - Geodetic latitude in degrees.
 * @param {number}       lon - Longitude in degrees.
 * @param {LatLon.datum} [datum=WGS84] - Datum this point is defined within.
 *
 * @example
 *     var p1 = new LatLon(51.4778, -0.0016, LatLon.datum.WGS84);
 */
function LatLon(lat, lon, datum) {
  // allow instantiation without 'new'
  if (!(this instanceof LatLon)) return new LatLon(lat, lon, datum);

  if (datum === undefined) datum = LatLon.datum.WGS84;

  this.lat = Number(lat);
  this.lon = Number(lon);
  this.datum = datum;
}


/**
 * Ellipsoid parameters; major axis (a), minor axis (b), and flattening (f) for each ellipsoid.
 */
LatLon.ellipsoid = {
  WGS84:        { a: 6378137,     b: 6356752.31425, f: 1/298.257223563 },
  GRS80:        { a: 6378137,     b: 6356752.31414, f: 1/298.257222101 },
  Airy1830:     { a: 6377563.396, b: 6356256.909,   f: 1/299.3249646   },
  AiryModified: { a: 6377340.189, b: 6356034.448,   f: 1/299.3249646   },
  Intl1924:     { a: 6378388,     b: 6356911.946,   f: 1/297           },
  Bessel1841:   { a: 6377397.155, b: 6356078.963,   f: 1/299.152815351 },
};

/**
 * Datums; with associated ellipsoid, and Helmert transform parameters to convert from WGS 84 into
 * given datum.
 *
 * More are available from earth-info.nga.mil/GandG/coordsys/datums/NATO_DT.pdf,
 * www.fieldenmaps.info/cconv/web/cconv_params.js
 */
LatLon.datum = {
  /* eslint key-spacing: 0, comma-dangle: 0 */
  WGS84: {
    ellipsoid: LatLon.ellipsoid.WGS84,
    transform: { tx:    0.0,    ty:    0.0,     tz:    0.0,    // m
      rx:    0.0,    ry:    0.0,     rz:    0.0,    // sec
      s:    0.0 }                                  // ppm
  },
  NAD83: { // (2009); functionally ≡ WGS84 - www.uvm.edu/giv/resources/WGS84_NAD83.pdf
    ellipsoid: LatLon.ellipsoid.GRS80,
    transform: { tx:    1.004,  ty:   -1.910,   tz:   -0.515,  // m
      rx:    0.0267, ry:    0.00034, rz:    0.011,  // sec
      s:   -0.0015 }                               // ppm
  }, // note: if you *really* need to convert WGS84<->NAD83, you need more knowledge than this!
  OSGB36: { // www.ordnancesurvey.co.uk/docs/support/guide-coordinate-systems-great-britain.pdf
    ellipsoid: LatLon.ellipsoid.Airy1830,
    transform: { tx: -446.448,  ty:  125.157,   tz: -542.060,  // m
      rx:   -0.1502, ry:   -0.2470,  rz:   -0.8421, // sec
      s:   20.4894 }                               // ppm
  },
  ED50: { // www.gov.uk/guidance/oil-and-gas-petroleum-operations-notices#pon-4
    ellipsoid: LatLon.ellipsoid.Intl1924,
    transform: { tx:   89.5,    ty:   93.8,     tz:  123.1,    // m
      rx:    0.0,    ry:    0.0,     rz:    0.156,  // sec
      s:   -1.2 }                                  // ppm
  },
  Irl1975: { // osi.ie/OSI/media/OSI/Content/Publications/transformations_booklet.pdf
    ellipsoid: LatLon.ellipsoid.AiryModified,
    transform: { tx: -482.530,  ty:  130.596,   tz: -564.557,  // m
      rx:   -1.042,  ry:   -0.214,   rz:   -0.631,  // sec
      s:   -8.150 }                                // ppm
  }, // note: many sources have opposite sign to rotations - to be checked!
  TokyoJapan: { // www.geocachingtoolbox.com?page=datumEllipsoidDetails
    ellipsoid: LatLon.ellipsoid.Bessel1841,
    transform: { tx:  148,      ty: -507,       tz: -685,      // m
      rx:    0,      ry:    0,       rz:    0,      // sec
      s:    0 }                                    // ppm
  },
};


/**
 * Converts ‘this’ lat/lon coordinate to new coordinate system.
 *
 * @param   {LatLon.datum} toDatum - Datum this coordinate is to be converted to.
 * @returns {LatLon} This point converted to new datum.
 *
 * @example
 *     var pWGS84 = new LatLon(51.4778, -0.0016, LatLon.datum.WGS84);
 *     var pOSGB = pWGS84.convertDatum(LatLon.datum.OSGB36); // 51.4773°N, 000.0000°E
 */
LatLon.prototype.convertDatum = function(toDatum) {
  var oldLatLon = this;
  var transform;

  if (oldLatLon.datum == LatLon.datum.WGS84) {
    // converting from WGS 84
    transform = toDatum.transform;
  }
  if (toDatum == LatLon.datum.WGS84) {
    // converting to WGS 84; use inverse transform (don't overwrite original!)
    transform = {};
    for (var param in oldLatLon.datum.transform) {
      if (oldLatLon.datum.transform.hasOwnProperty(param)) {
        transform[param] = -oldLatLon.datum.transform[param];
      }
    }
  }
  if (transform === undefined) {
    // neither this.datum nor toDatum are WGS84: convert this to WGS84 first
    oldLatLon = this.convertDatum(LatLon.datum.WGS84);
    transform = toDatum.transform;
  }

  var oldCartesian = oldLatLon.toCartesian();                // convert polar to cartesian...
  var newCartesian = oldCartesian.applyTransform(transform); // ...apply transform...
  var newLatLon = newCartesian.toLatLonE(toDatum);           // ...and convert cartesian to polar

  return newLatLon;
};


/**
 * Converts ‘this’ point from (geodetic) latitude/longitude coordinates to (geocentric) cartesian
 * (x/y/z) coordinates.
 *
 * @returns {Vector3d} Vector pointing to lat/lon point, with x, y, z in metres from earth centre.
 */
LatLon.prototype.toCartesian = function() {
  var φ = this.lat.toRadians(), λ = this.lon.toRadians();
  var h = 0; // height above ellipsoid - not currently used
  var a = this.datum.ellipsoid.a, f = this.datum.ellipsoid.f;

  var sinφ = Math.sin(φ), cosφ = Math.cos(φ);
  var sinλ = Math.sin(λ), cosλ = Math.cos(λ);

  var eSq = 2*f - f*f;                      // 1st eccentricity squared ≡ (a²-b²)/a²
  var ν = a / Math.sqrt(1 - eSq*sinφ*sinφ); // radius of curvature in prime vertical

  var x = (ν+h) * cosφ * cosλ;
  var y = (ν+h) * cosφ * sinλ;
  var z = (ν*(1-eSq)+h) * sinφ;

  var point = new Vector3d(x, y, z);

  return point;
};


/**
 * Converts ‘this’ (geocentric) cartesian (x/y/z) point to (ellipsoidal geodetic) latitude/longitude
 * coordinates on specified datum.
 *
 * Uses Bowring’s (1985) formulation for μm precision in concise form.
 *
 * @param {LatLon.datum.transform} datum - Datum to use when converting point.
 */
Vector3d.prototype.toLatLonE = function(datum) {
  var x = this.x, y = this.y, z = this.z;
  var a = datum.ellipsoid.a, b = datum.ellipsoid.b, f = datum.ellipsoid.f;

  var e2 = 2*f - f*f;   // 1st eccentricity squared ≡ (a²-b²)/a²
  var ε2 = e2 / (1-e2); // 2nd eccentricity squared ≡ (a²-b²)/b²
  var p = Math.sqrt(x*x + y*y); // distance from minor axis
  var R = Math.sqrt(p*p + z*z); // polar radius

  // parametric latitude (Bowring eqn 17, replacing tanβ = z·a / p·b)
  var tanβ = (b*z)/(a*p) * (1+ε2*b/R);
  var sinβ = tanβ / Math.sqrt(1+tanβ*tanβ);
  var cosβ = sinβ / tanβ;

  // geodetic latitude (Bowring eqn 18: tanφ = z+ε²bsin³β / p−e²cos³β)
  var φ = isNaN(cosβ) ? 0 : Math.atan2(z + ε2*b*sinβ*sinβ*sinβ, p - e2*a*cosβ*cosβ*cosβ);

  // longitude
  var λ = Math.atan2(y, x);

  // height above ellipsoid (Bowring eqn 7) [not currently used]
  var sinφ = Math.sin(φ), cosφ = Math.cos(φ);
  var ν = a/Math.sqrt(1-e2*sinφ*sinφ); // length of the normal terminated by the minor axis
  var h = p*cosφ + z*sinφ - (a*a/ν);

  var point = new LatLon(φ.toDegrees(), λ.toDegrees(), datum);

  return point;
};

/**
 * Applies Helmert transform to ‘this’ point using transform parameters t.
 *
 * @private
 * @param {LatLon.datum.transform} t - Transform to apply to this point.
 */
Vector3d.prototype.applyTransform = function(t)   {
  var x1 = this.x, y1 = this.y, z1 = this.z;

  var tx = t.tx, ty = t.ty, tz = t.tz;
  var rx = (t.rx/3600).toRadians(); // normalise seconds to radians
  var ry = (t.ry/3600).toRadians(); // normalise seconds to radians
  var rz = (t.rz/3600).toRadians(); // normalise seconds to radians
  var s1 = t.s/1e6 + 1;             // normalise ppm to (s+1)

  // apply transform
  var x2 = tx + x1*s1 - y1*rz + z1*ry;
  var y2 = ty + x1*rz + y1*s1 - z1*rx;
  var z2 = tz - x1*ry + y1*rx + z1*s1;

  var point = new Vector3d(x2, y2, z2);

  return point;
};


/**
 * Returns a string representation of ‘this’ point, formatted as degrees, degrees+minutes, or
 * degrees+minutes+seconds.
 *
 * @param   {string} [format=dms] - Format point as 'd', 'dm', 'dms'.
 * @param   {number} [dp=0|2|4] - Number of decimal places to use - default 0 for dms, 2 for dm, 4 for d.
 * @returns {string} Comma-separated latitude/longitude.
 */
LatLon.prototype.toString = function(format, dp) {
  return Dms.toLat(this.lat, format, dp) + ', ' + Dms.toLon(this.lon, format, dp);
};


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/** Extend Number object with method to convert numeric degrees to radians */
if (Number.prototype.toRadians === undefined) {
  Number.prototype.toRadians = function() { return this * Math.PI / 180; };
}

/** Extend Number object with method to convert radians to numeric (signed) degrees */
if (Number.prototype.toDegrees === undefined) {
  Number.prototype.toDegrees = function() { return this * 180 / Math.PI; };
}

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
if (typeof module != 'undefined' && module.exports) module.exports = LatLon, module.exports.Vector3d = Vector3d; // ≡ export { LatLon as default, Vector3d }

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
/* UTM / WGS-84 Conversion Functions                                  (c) Chris Veness 2014-2016  */
/*                                                                                   MIT Licence  */
/* www.movable-type.co.uk/scripts/latlong-utm-mgrs.html                                           */
/* www.movable-type.co.uk/scripts/geodesy/docs/module-utm.html                                    */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

'use strict';
if (typeof module!='undefined' && module.exports) var LatLon = require('./latlon-ellipsoidal.js'); // ≡ import LatLon from 'latlon-ellipsoidal.js'


/**
 * Convert between Universal Transverse Mercator coordinates and WGS 84 latitude/longitude points.
 *
 * Method based on Karney 2011 ‘Transverse Mercator with an accuracy of a few nanometers’,
 * building on Krüger 1912 ‘Konforme Abbildung des Erdellipsoids in der Ebene’.
 *
 * @module   utm
 * @requires latlon-ellipsoidal
 */


/**
 * Creates a Utm coordinate object.
 *
 * @constructor
 * @param  {number} zone - UTM 6° longitudinal zone (1..60 covering 180°W..180°E).
 * @param  {string} hemisphere - N for northern hemisphere, S for southern hemisphere.
 * @param  {number} easting - Easting in metres from false easting (-500km from central meridian).
 * @param  {number} northing - Northing in metres from equator (N) or from false northing -10,000km (S).
 * @param  {LatLon.datum} [datum=WGS84] - Datum UTM coordinate is based on.
 * @param  {number} [convergence] - Meridian convergence (bearing of grid north clockwise from true
 *                  north), in degrees
 * @param  {number} [scale] - Grid scale factor
 * @throws {Error}  Invalid UTM coordinate
 *
 * @example
 *   var utmCoord = new Utm(31, 'N', 448251, 5411932);
 */
function Utm(zone, hemisphere, easting, northing, datum, convergence, scale) {
  if (!(this instanceof Utm)) { // allow instantiation without 'new'
    return new Utm(zone, hemisphere, easting, northing, datum, convergence, scale);
  }

  if (datum === undefined) datum = LatLon.datum.WGS84; // default if not supplied
  if (convergence === undefined) convergence = null;   // default if not supplied
  if (scale === undefined) scale = null;               // default if not supplied

  if (!(1<=zone && zone<=60)) throw new Error('Invalid UTM zone '+zone);
  if (!hemisphere.match(/[NS]/i)) throw new Error('Invalid UTM hemisphere '+hemisphere);
  // range-check easting/northing (with 40km overlap between zones) - is this worthwhile?
  //if (!(120e3<=easting && easting<=880e3)) throw new Error('Invalid UTM easting '+ easting);
  //if (!(0<=northing && northing<=10000e3)) throw new Error('Invalid UTM northing '+ northing);

  this.zone = Number(zone);
  this.hemisphere = hemisphere.toUpperCase();
  this.easting = Number(easting);
  this.northing = Number(northing);
  this.datum = datum;
  this.convergence = convergence===null ? null : Number(convergence);
  this.scale = scale===null ? null : Number(scale);
}


/**
 * Converts latitude/longitude to UTM coordinate.
 *
 * Implements Karney’s method, using Krüger series to order n^6, giving results accurate to 5nm for
 * distances up to 3900km from the central meridian.
 *
 * @returns {Utm}   UTM coordinate.
 * @throws  {Error} If point not valid, if point outside latitude range.
 *
 * @example
 *   var latlong = new LatLon(48.8582, 2.2945);
 *   var utmCoord = latlong.toUtm(); // utmCoord.toString(): '31 N 448252 5411933'
 */
LatLon.prototype.toUtm = function() {
  if (isNaN(this.lat) || isNaN(this.lon)) throw new Error('Invalid point');
  if (!(-80<=this.lat && this.lat<=84)) throw new Error('Outside UTM limits');

  var falseEasting = 500e3, falseNorthing = 10000e3;

  var zone = Math.floor((this.lon+180)/6) + 1; // longitudinal zone
  var λ0 = ((zone-1)*6 - 180 + 3).toRadians(); // longitude of central meridian

  // ---- handle Norway/Svalbard exceptions
  // grid zones are 8° tall; 0°N is offset 10 into latitude bands array
  var mgrsLatBands = 'CDEFGHJKLMNPQRSTUVWXX'; // X is repeated for 80-84°N
  var latBand = mgrsLatBands.charAt(Math.floor(this.lat/8+10));
  // adjust zone & central meridian for Norway
  if (zone==31 && latBand=='V' && this.lon>= 3) { zone++; λ0 += (6).toRadians(); }
  // adjust zone & central meridian for Svalbard
  if (zone==32 && latBand=='X' && this.lon<  9) { zone--; λ0 -= (6).toRadians(); }
  if (zone==32 && latBand=='X' && this.lon>= 9) { zone++; λ0 += (6).toRadians(); }
  if (zone==34 && latBand=='X' && this.lon< 21) { zone--; λ0 -= (6).toRadians(); }
  if (zone==34 && latBand=='X' && this.lon>=21) { zone++; λ0 += (6).toRadians(); }
  if (zone==36 && latBand=='X' && this.lon< 33) { zone--; λ0 -= (6).toRadians(); }
  if (zone==36 && latBand=='X' && this.lon>=33) { zone++; λ0 += (6).toRadians(); }

  var φ = this.lat.toRadians();      // latitude ± from equator
  var λ = this.lon.toRadians() - λ0; // longitude ± from central meridian

  var a = this.datum.ellipsoid.a, f = this.datum.ellipsoid.f;
  // WGS 84: a = 6378137, b = 6356752.314245, f = 1/298.257223563;

  var k0 = 0.9996; // UTM scale on the central meridian

  // ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:

  var e = Math.sqrt(f*(2-f)); // eccentricity
  var n = f / (2 - f);        // 3rd flattening
  var n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5; // TODO: compare Horner-form accuracy?

  var cosλ = Math.cos(λ), sinλ = Math.sin(λ), tanλ = Math.tan(λ);

  var τ = Math.tan(φ); // τ ≡ tanφ, τʹ ≡ tanφʹ; prime (ʹ) indicates angles on the conformal sphere
  var σ = Math.sinh(e*Math.atanh(e*τ/Math.sqrt(1+τ*τ)));

  var τʹ = τ*Math.sqrt(1+σ*σ) - σ*Math.sqrt(1+τ*τ);

  var ξʹ = Math.atan2(τʹ, cosλ);
  var ηʹ = Math.asinh(sinλ / Math.sqrt(τʹ*τʹ + cosλ*cosλ));

  var A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian

  var α = [ null, // note α is one-based array (6th order Krüger expressions)
    1/2*n - 2/3*n2 + 5/16*n3 +   41/180*n4 -     127/288*n5 +      7891/37800*n6,
    13/48*n2 -  3/5*n3 + 557/1440*n4 +     281/630*n5 - 1983433/1935360*n6,
    61/240*n3 -  103/140*n4 + 15061/26880*n5 +   167603/181440*n6,
    49561/161280*n4 -     179/168*n5 + 6601661/7257600*n6,
    34729/80640*n5 - 3418889/1995840*n6,
    212378941/319334400*n6 ];

  var ξ = ξʹ;
  for (var j=1; j<=6; j++) ξ += α[j] * Math.sin(2*j*ξʹ) * Math.cosh(2*j*ηʹ);

  var η = ηʹ;
  for (var j=1; j<=6; j++) η += α[j] * Math.cos(2*j*ξʹ) * Math.sinh(2*j*ηʹ);

  var x = k0 * A * η;
  var y = k0 * A * ξ;

  // ---- convergence: Karney 2011 Eq 23, 24

  var pʹ = 1;
  for (var j=1; j<=6; j++) pʹ += 2*j*α[j] * Math.cos(2*j*ξʹ) * Math.cosh(2*j*ηʹ);
  var qʹ = 0;
  for (var j=1; j<=6; j++) qʹ += 2*j*α[j] * Math.sin(2*j*ξʹ) * Math.sinh(2*j*ηʹ);

  var γʹ = Math.atan(τʹ / Math.sqrt(1+τʹ*τʹ)*tanλ);
  var γʺ = Math.atan2(qʹ, pʹ);

  var γ = γʹ + γʺ;

  // ---- scale: Karney 2011 Eq 25

  var sinφ = Math.sin(φ);
  var kʹ = Math.sqrt(1 - e*e*sinφ*sinφ) * Math.sqrt(1 + τ*τ) / Math.sqrt(τʹ*τʹ + cosλ*cosλ);
  var kʺ = A / a * Math.sqrt(pʹ*pʹ + qʹ*qʹ);

  var k = k0 * kʹ * kʺ;

  // ------------

  // shift x/y to false origins
  x = x + falseEasting;             // make x relative to false easting
  if (y < 0) y = y + falseNorthing; // make y in southern hemisphere relative to false northing

  // round to reasonable precision
  x = Number(x.toFixed(6)); // nm precision
  y = Number(y.toFixed(6)); // nm precision
  var convergence = Number(γ.toDegrees().toFixed(9));
  var scale = Number(k.toFixed(12));

  var h = this.lat>=0 ? 'N' : 'S'; // hemisphere

  return new Utm(zone, h, x, y, this.datum, convergence, scale);
};


/**
 * Converts UTM zone/easting/northing coordinate to latitude/longitude
 *
 * @param   {Utm}     utmCoord - UTM coordinate to be converted to latitude/longitude.
 * @returns {LatLon} Latitude/longitude of supplied grid reference.
 *
 * @example
 *   var grid = new Utm(31, 'N', 448251.795, 5411932.678);
 *   var latlong = grid.toLatLonE(); // latlong.toString(): 48°51′29.52″N, 002°17′40.20″E
 */
Utm.prototype.toLatLonE = function() {
  var z = this.zone;
  var h = this.hemisphere;
  var x = this.easting;
  var y = this.northing;

  if (isNaN(z) || isNaN(x) || isNaN(y)) throw new Error('Invalid coordinate');

  var falseEasting = 500e3, falseNorthing = 10000e3;

  var a = this.datum.ellipsoid.a, f = this.datum.ellipsoid.f;
  // WGS 84:  a = 6378137, b = 6356752.314245, f = 1/298.257223563;

  var k0 = 0.9996; // UTM scale on the central meridian

  x = x - falseEasting;               // make x ± relative to central meridian
  y = h=='S' ? y - falseNorthing : y; // make y ± relative to equator

  // ---- from Karney 2011 Eq 15-22, 36:

  var e = Math.sqrt(f*(2-f)); // eccentricity
  var n = f / (2 - f);        // 3rd flattening
  var n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5;

  var A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian

  var η = x / (k0*A);
  var ξ = y / (k0*A);

  var β = [ null, // note β is one-based array (6th order Krüger expressions)
    1/2*n - 2/3*n2 + 37/96*n3 -    1/360*n4 -   81/512*n5 +    96199/604800*n6,
    1/48*n2 +  1/15*n3 - 437/1440*n4 +   46/105*n5 - 1118711/3870720*n6,
    17/480*n3 -   37/840*n4 - 209/4480*n5 +      5569/90720*n6,
    4397/161280*n4 -   11/504*n5 -  830251/7257600*n6,
    4583/161280*n5 -  108847/3991680*n6,
    20648693/638668800*n6 ];

  var ξʹ = ξ;
  for (var j=1; j<=6; j++) ξʹ -= β[j] * Math.sin(2*j*ξ) * Math.cosh(2*j*η);

  var ηʹ = η;
  for (var j=1; j<=6; j++) ηʹ -= β[j] * Math.cos(2*j*ξ) * Math.sinh(2*j*η);

  var sinhηʹ = Math.sinh(ηʹ);
  var sinξʹ = Math.sin(ξʹ), cosξʹ = Math.cos(ξʹ);

  var τʹ = sinξʹ / Math.sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ);

  var τi = τʹ;
  do {
    var σi = Math.sinh(e*Math.atanh(e*τi/Math.sqrt(1+τi*τi)));
    var τiʹ = τi * Math.sqrt(1+σi*σi) - σi * Math.sqrt(1+τi*τi);
    var δτi = (τʹ - τiʹ)/Math.sqrt(1+τiʹ*τiʹ)
      * (1 + (1-e*e)*τi*τi) / ((1-e*e)*Math.sqrt(1+τi*τi));
    τi += δτi;
  } while (Math.abs(δτi) > 1e-12); // using IEEE 754 δτi -> 0 after 2-3 iterations
  // note relatively large convergence test as δτi toggles on ±1.12e-16 for eg 31 N 400000 5000000
  var τ = τi;

  var φ = Math.atan(τ);

  var λ = Math.atan2(sinhηʹ, cosξʹ);

  // ---- convergence: Karney 2011 Eq 26, 27

  var p = 1;
  for (var j=1; j<=6; j++) p -= 2*j*β[j] * Math.cos(2*j*ξ) * Math.cosh(2*j*η);
  var q = 0;
  for (var j=1; j<=6; j++) q += 2*j*β[j] * Math.sin(2*j*ξ) * Math.sinh(2*j*η);

  var γʹ = Math.atan(Math.tan(ξʹ) * Math.tanh(ηʹ));
  var γʺ = Math.atan2(q, p);

  var γ = γʹ + γʺ;

  // ---- scale: Karney 2011 Eq 28

  var sinφ = Math.sin(φ);
  var kʹ = Math.sqrt(1 - e*e*sinφ*sinφ) * Math.sqrt(1 + τ*τ) * Math.sqrt(sinhηʹ*sinhηʹ + cosξʹ*cosξʹ);
  var kʺ = A / a / Math.sqrt(p*p + q*q);

  var k = k0 * kʹ * kʺ;

  // ------------

  var λ0 = ((z-1)*6 - 180 + 3).toRadians(); // longitude of central meridian
  λ += λ0; // move λ from zonal to global coordinates

  // round to reasonable precision
  var lat = Number(φ.toDegrees().toFixed(11)); // nm precision (1nm = 10^-11°)
  var lon = Number(λ.toDegrees().toFixed(11)); // (strictly lat rounding should be φ⋅cosφ!)
  var convergence = Number(γ.toDegrees().toFixed(9));
  var scale = Number(k.toFixed(12));

  var latLong = new LatLon(lat, lon, this.datum);
  // ... and add the convergence and scale into the LatLon object ... wonderful JavaScript!
  latLong.convergence = convergence;
  latLong.scale = scale;

  return latLong;
};


/**
 * Parses string representation of UTM coordinate.
 *
 * A UTM coordinate comprises (space-separated)
 *  - zone
 *  - hemisphere
 *  - easting
 *  - northing.
 *
 * @param   {string} utmCoord - UTM coordinate (WGS 84).
 * @param   {Datum}  [datum=WGS84] - Datum coordinate is defined in (default WGS 84).
 * @returns {Utm}
 * @throws  Error Invalid UTM coordinate
 *
 * @example
 *   var utmCoord = Utm.parse('31 N 448251 5411932');
 *   // utmCoord: {zone: 31, hemisphere: 'N', easting: 448251, northing: 5411932 }
 */
Utm.parse = function(utmCoord, datum) {
  if (datum === undefined) datum = LatLon.datum.WGS84; // default if not supplied

  // match separate elements (separated by whitespace)
  utmCoord = utmCoord.trim().match(/\S+/g);

  if (utmCoord==null || utmCoord.length!=4) throw new Error('Invalid UTM coordinate');

  var zone = utmCoord[0], hemisphere = utmCoord[1], easting = utmCoord[2], northing = utmCoord[3];

  return new Utm(zone, hemisphere, easting, northing, datum);
};


/**
 * Returns a string representation of a UTM coordinate.
 *
 * To distinguish from MGRS grid zone designators, a space is left between the zone and the
 * hemisphere.
 *
 * @param   {number} [digits=0] - Number of digits to appear after the decimal point (3 ≡ mm).
 * @returns {string} A string representation of the coordinate.
 */
Utm.prototype.toString = function(digits) {
  digits = Number(digits||0); // default 0 if not supplied

  var z = this.zone;
  var h = this.hemisphere;
  var e = this.easting;
  var n = this.northing;
  if (isNaN(z) || !h.match(/[NS]/) || isNaN(e) || isNaN(n)) return '';

  return z+' '+h+' '+e.toFixed(digits)+' '+n.toFixed(digits);
};


/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

/** Polyfill Math.sinh for old browsers / IE */
if (Math.sinh === undefined) {
  Math.sinh = function(x) {
    return (Math.exp(x) - Math.exp(-x)) / 2;
  };
}

/** Polyfill Math.cosh for old browsers / IE */
if (Math.cosh === undefined) {
  Math.cosh = function(x) {
    return (Math.exp(x) + Math.exp(-x)) / 2;
  };
}

/** Polyfill Math.tanh for old browsers / IE */
if (Math.tanh === undefined) {
  Math.tanh = function(x) {
    return (Math.exp(x) - Math.exp(-x)) / (Math.exp(x) + Math.exp(-x));
  };
}

/** Polyfill Math.asinh for old browsers / IE */
if (Math.asinh === undefined) {
  Math.asinh = function(x) {
    return Math.log(x + Math.sqrt(1 + x*x));
  };
}

/** Polyfill Math.atanh for old browsers / IE */
if (Math.atanh === undefined) {
  Math.atanh = function(x) {
    return Math.log((1+x) / (1-x)) / 2;
  };
}

/** Polyfill String.trim for old browsers
 *  (q.v. blog.stevenlevithan.com/archives/faster-trim-javascript) */
if (String.prototype.trim === undefined) {
  String.prototype.trim = function() {
    return String(this).replace(/^\s\s*/, '').replace(/\s\s*$/, '');
  };
}

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
if (typeof module != 'undefined' && module.exports) module.exports = Utm; // ≡ export default Utm