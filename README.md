
# diaspora* federation lib

[![Build Status](https://travis-ci.org/Raven24/diaspora-federation.png)](https://travis-ci.org/Raven24/diaspora-federation)
[![Coverage Status](https://coveralls.io/repos/Raven24/diaspora-federation/badge.png)](https://coveralls.io/r/Raven24/diaspora-federation)

[Project site](https://diasporafoundation.org) |
[Wiki](https://wiki.diasporafoundation.org)

The goal of this gem is to provide a library of reusable code for the purpose
of implementing the protocols used around Diaspora. This covers user discovery
utilizing the [XRD](http://docs.oasis-open.org/xri/xrd/v1.0/xrd-1.0.html),
[HostMeta](http://tools.ietf.org/html/rfc6415),
[WebFinger](http://tools.ietf.org/html/draft-jones-appsawg-webfinger) and
[hCard](http://microformats.org/wiki/hCard "hCard 1.0") standards as well as
the message passing implementation using a subset of the
[Salmon protocol](http://www.salmon-protocol.org/).

One of the main ideas behind this lib was to avoid any dependencies toward a
specific web framework. This means any app using this gem is free to set up
HTTP routing and database infrastructure any way it sees fit, as long as the
few required routes are handled to specification.


### user discovery

When Diaspora attempts to discover a remote user account, the server name is
extracted from the account handle: `"user@server.example" => "server.example"`
Next, a `GET` request is sent to the servers host-meta route
`https://server.example/.well-known/host-meta` which returns an XRD document with
the `application/xrd+xml` media type.
The contained `Link` element with `rel="lrdd"` contains a template URL in its
`template` attribute. It will be used for querying the WebFinger document.

To retrieve the WebFinger document, the placeholder `{uri}` in the template has
to be replaced by the `acct` URI of the account to look up:
`https://server.example/webfinger?q=acct:user@server.example`
Now this URL can be used in a `GET` request to fetch the WebFinger document, which
also consists of an XRD document served with the `application/xrd+xml` media type.
The document already contains some basic information associated with the queried
user account. More specific profile details are in the referenced hCard document.
The URL is contained in the `href` attribute of the `Link` element with
`rel="http://microformats.org/profile/hcard"`

The hCard document can be accessed by issuing a `GET` request to the hCard URL
extracted from the WebFinger document. It will return a simple HTML page
containing the public profile information of the queried user, marked up as
specified in the hCard microformat standard (using `class` attributes on the
elements, thereby giving them semantic meaning).

All of the described documents can be generated and parsed by classes shipped
with this gem. You can find them in the `DiasporaFederation::WebFinger` module.
See the included documentation for specifics on how to use them.


### message passing

(TODO)
