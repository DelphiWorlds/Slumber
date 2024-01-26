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

implementation

end.
