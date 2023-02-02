unit SL.Consts;

interface

uses
  SL.Types, SL.Client;

const
  cHTTPMethodDelete = 'DELETE';
  cHTTPMethodGet = 'GET';
  cHTTPMethodPatch = 'PATCH';
  cHTTPMethodPost = 'POST';
  cHTTPMethodPut = 'PUT';

  cActionKindNames: array[THTTPMethod] of string = (cHTTPMethodDelete, cHTTPMethodGet, cHTTPMethodPatch, cHTTPMethodPost, cHTTPMethodPut);
  cHeaderKindNames: array[THeaderKind] of string = ('Accept', 'Accept-Charset', 'Accept-Encoding', 'Access-Control-Request-Headers',
    'Access-Control-Request-Method', 'Authorization', 'Cache-Control', 'Content-Type', 'User-Agent');

implementation

end.
