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
  cHeaderKindNames: array[THeaderKind] of string = ('Content-Type', 'Authorization');
  // cHeaderKindCaptions: array[THeaderKind] of string = ('Content Type', 'Authorization');

implementation

end.
