unit SL.Types;

interface

type
  THeaderKind = (Accept, AcceptCharset, AcceptEncoding, AccessControlRequestHeaders, AccessControlRequestMethod, Authorization, CacheControl,
    ContentType, UserAgent);

  TRequestHeader = record
    Index: Integer;
    Name: string;
    Value: string;
  end;

  TRequestHeaders = TArray<TRequestHeader>;

  TRequest = record
    ID: string;
    Name: string;
    Headers: TRequestHeaders;
    Method: string;
    URL: string;
  end;

  TRequests = TArray<TRequest>;

  TRequestCollection = record
    ID: string;
    Name: string;
    Requests: TRequests;
  end;

implementation

end.
