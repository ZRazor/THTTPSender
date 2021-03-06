﻿unit HTTPSender;

// (c) Z.Razor | zt.am | 2012 - 2013
// For Delphi 2010 and Higher

interface

uses Windows, WinInet, Classes, Sysutils;

const
  __ABOUT__ = '(c) Z.Razor 20.05.2013';

type
  THTTPMethod = (hmGet, hmPut, hmPost, hmDelete, hmHead);

type
  THTTPCookie = record
    Domain: String;
    Name: String;
    Value: String;
    Expires: String;
    Path: String;
    HTTPOnly: boolean;
  end;

  THTTPCookieArray = array of THTTPCookie;

  THTTPCookieCollection = class(TPersistent)
  private
    Cookies: THTTPCookieArray;
    RCustomCookies: TStringList;
    function GetCookie(Index: Integer): THTTPCookie;
    procedure PutCookie(Index: Integer; Cookie: THTTPCookie);
  public
    property Items[Index: Integer]: THTTPCookie read GetCookie write PutCookie;
    function Add(const Cookie: THTTPCookie; ReplaceIfExists: boolean): Integer;
    function DeleteCookie(const Index: Integer): boolean;
    function Count: Integer;
    function GetCookies(ADomain, APath: String): String;
    procedure Clear;
    constructor Create;
  published
    property CustomCookies: TStringList read RCustomCookies write RCustomCookies;
  end;

type
  THTTPResponse = record
    StatusCode: Integer;
    StatusText: String;
    RawHeaders: String;
    ContentLength: Integer;
    ContentEncoding: String;
    Location: String;
    Expires: String;
  end;

  THTTPHeaders = class(TPersistent)
  private
    RContentType: String;
    RAccept: String;
    RAcceptLanguage: String;
    RAcceptEncoding: String;
    RCustomHeaders: TStringList;
    RRefferer: String;
    RUserAgent: String;
  public
    constructor Create;
  published
    property ContentType: String read RContentType write RContentType;
    property Accept: String read RAccept write RAccept;
    property AcceptLanguage: String read RAcceptLanguage write RAcceptLanguage;
    property AcceptEncoding: String read RAcceptEncoding write RAcceptEncoding;
    property CustomHeaders: TStringList read RCustomHeaders write RCustomHeaders;
    property Refferer: String read RRefferer write RRefferer;
    property UserAgent: String read RUserAgent write RUserAgent;
  end;

  THTTPBasicAuth = class(TPersistent)
  private
    RUsername: String;
    RPassword: String;
  published
    property Username: String read RUsername write RUsername;
    property Password: String read RPassword write RPassword;
  end;

type
  TCookieAddEvent = procedure(Sender: TObject; Cookie: THTTPCookie) of object;
  TWorkBeginEvent = procedure(Sender: TObject; WorkCountMax: int64) of object;
  TWorkEvent = procedure(Sender: TObject; WorkCount: int64) of object;
  TWorkEndEvent = procedure(Sender: TObject) of object;

type
  THTTPPostContainerFormField = record
    Name: ansistring;
    Value: ansistring;
  end;

  THTTPPostContainerFormFieldArray = array of THTTPPostContainerFormField;

  THTTPPostContainerFile = record
    Name: ansistring;
    FileName: ansistring;
    ContentType: ansistring;
  end;

  THTTPPostContainerFileArray = array of THTTPPostContainerFile;

  THTTPPostContainer = class
  private
    RFormFields: THTTPPostContainerFormFieldArray;
    RFiles: THTTPPostContainerFileArray;
    function GetFile(Index: Integer): THTTPPostContainerFile;
    function GetFormField(Index: Integer): THTTPPostContainerFormField;
    procedure SetFile(Index: Integer; Item: THTTPPostContainerFile);
    procedure SetFormField(Index: Integer; Item: THTTPPostContainerFormField);
  public
    function GetFilesCount: Integer;
    function GetFormFieldsCount: Integer;
    procedure AddFile(const AName, AFileName: ansistring; AContentType: ansistring = 'application/octet-stream');
    procedure AddFormField(const AName, AValue: ansistring);
    procedure DeleteFile(const Index: Integer);
    procedure DeleteFormField(const Index: Integer);
    procedure ClearFiles;
    procedure ClearFormFields;
    property Files[Index: Integer]: THTTPPostContainerFile read GetFile write SetFile;
    property FormFields[Index: Integer]: THTTPPostContainerFormField read GetFormField write SetFormField;
  end;

type
  THTTPSender = class(TComponent)
  private
    RResponse: THTTPResponse;
    RResponseText: ansistring;
    RAllowCookies: boolean;
    RAutoRedirects: boolean;
    RConnectTimeout: Integer;
    RReadTimeout: Integer;
    RSendTimeout: Integer;
    RProxy: String;
    RProxyBypass: String;
    RUseIECookies: boolean;
    RHeaders: THTTPHeaders;
    RBasicAuth: THTTPBasicAuth;
    ROnCookieAdd: TCookieAddEvent;
    ROnWorkBegin: TWorkBeginEvent;
    ROnWork: TWorkEvent;
    ROnWorkEnd: TWorkEndEvent;
    RCookies: THTTPCookieCollection;
    function GetQueryInfo(hRequest: Pointer; Flag: Integer): String;
    function GetHeaders: PWideChar;
    function GetAbout: String;
    function GetMethodString(const Method: THTTPMethod): String;
    function PreURLExecute(const URL: String; PostData: ansistring; Method: THTTPMethod): string; overload;
    function GetRandomBoundary: ansistring;
    function GetPostDataFromPostContainer(const PostContainer: THTTPPostContainer): ansistring;
    procedure ProcessCookies(Data: String);
    procedure URLExecute(const HTTPS: boolean; ServerName, Resource, ExtraInfo: String; Method: THTTPMethod;
      Stream: TStream; PostData: ansistring = '');
    procedure ParseURL(const lpszUrl: String; var Host, Resource, ExtraInfo: String);
    procedure PreURLExecute(const URL: String; PostData: ansistring; Method: THTTPMethod; Stream: TStream); overload;
  public
    DefaultEncoding: TEncoding;
    property Response: THTTPResponse read RResponse;
    property ResponseText: ansistring read RResponseText;
    function Get(const URL: String): String; overload;
    function Post(const URL: String; PostData: ansistring): String; overload;
    function Post(const URL: String; PostContainer: THTTPPostContainer): String; overload;
    function Post(const URL: String; PostData: TStringList): String; overload;
    function Put(const URL: String): String; overload;
    procedure Get(const URL: String; Stream: TStream); overload;
    procedure Post(const URL: String; PostData: ansistring; Stream: TStream); overload;
    procedure Post(const URL: String; PostData: TStringList; Stream: TStream); overload;
    procedure Post(const URL: String; PostContainer: THTTPPostContainer; Stream: TStream); overload;
    procedure Put(const URL: String; Stream: TStream); overload;
    procedure Free;
    constructor Create(AOwner: TComponent); override;
  published
    property Cookies: THTTPCookieCollection read RCookies write RCookies;
    property Proxy: String read RProxy write RProxy;
    property ProxyBypass: String read RProxyBypass write RProxyBypass;
    property AllowCookies: boolean read RAllowCookies write RAllowCookies default true;
    property AutoRedirects: boolean read RAutoRedirects write RAutoRedirects default true;
    property ConnectTimeout: Integer read RConnectTimeout write RConnectTimeout default 60000;
    property ReadTimeout: Integer read RReadTimeout write RReadTimeout default 0;
    property SendTimeout: Integer read RSendTimeout write RSendTimeout default 0;
    property UseIECookies: boolean read RUseIECookies write RUseIECookies default true;
    property Headers: THTTPHeaders read RHeaders write RHeaders;
    property BasicAuth: THTTPBasicAuth read RBasicAuth write RBasicAuth;
    property OnCookieAdd: TCookieAddEvent read ROnCookieAdd write ROnCookieAdd;
    property OnWorkBegin: TWorkBeginEvent read ROnWorkBegin write ROnWorkBegin;
    property OnWork: TWorkEvent read ROnWork write ROnWork;
    property OnWorkEnd: TWorkEndEvent read ROnWorkEnd write ROnWorkEnd;
    property About: String read GetAbout;
  end;

function HTTPEncode(const Text: String): String;
function HTTPDecode(const Text: String): String;
function HTMLDecode(const Text: String): String;

procedure Register;

implementation

function PosEx(SubStr, Str: string; Index: longint): Integer;
begin
  delete(Str, 1, index);
  Result := index + Pos(SubStr, Str);
end;

function MyStringReplace(const S, OldPattern, NewPattern: string; ReplaceAll: boolean): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  SearchStr := S;
  Patt := OldPattern;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not(ReplaceAll) then begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function Pars(const source, left, right: String): String;
var
  r, l: Integer;
begin
  l := Pos(left, source);
  r := Pos(right, (Copy(source, l + Length(left), Length(source) - l - Length(left)))) + l;
  if l = r then exit('');
  Result := Copy(source, l + Length(left), r - l - 1);
end;

function HTTPEncode(const Text: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Text) do begin
    case Text[i] of
      'A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', '.': Result := Result + Text[i];
    else Result := Result + '%' + IntToHex(Ord(Text[i]), 2);
    end;
  end;
end;

function HTTPDecode(const Text: String): String;
begin
  // !
end;

function HTMLDecode(const Text: String): String; // !
var
  i, j: Integer;
  k: string;
begin
  Result := Text;
  while Pos('&#', Result) > 0 do begin
    i := Pos('&#', Result);
    j := PosEx(';', Result, i);
    k := Copy(Result, i + 2, j - i - 2);
    Result := MyStringReplace(Result, '&#' + k + ';', WideChar(strtoint(k)));
  end;
end;

function GetWinInetError(ErrorCode: Cardinal): String;
const
  winetdll = 'wininet.dll';
var
  Len: Integer;
  Buffer: PChar;
begin
  Len := FormatMessage(FORMAT_MESSAGE_FROM_HMODULE or FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_ALLOCATE_BUFFER or
    FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_ARGUMENT_ARRAY, Pointer(GetModuleHandle(winetdll)), ErrorCode, 0,
    @Buffer, SizeOf(Buffer), nil);
  try
    while (Len > 0) and {$IFDEF UNICODE}(CharInSet(Buffer[Len - 1], [#0 .. #32, '.']))
{$ELSE}(Buffer[Len - 1] in [#0 .. #32, '.']) {$ENDIF} do Dec(Len);
    SetString(Result, Buffer, Len);
  finally
    LocalFree(HLOCAL(Buffer));
  end;
end;

{ THTTPSender }

procedure THTTPSender.ParseURL(const lpszUrl: String; var Host, Resource, ExtraInfo: String);
var
  lpszScheme: array [0 .. INTERNET_MAX_SCHEME_LENGTH - 1] of Char;
  lpszHostName: array [0 .. INTERNET_MAX_HOST_NAME_LENGTH - 1] of Char;
  lpszUserName: array [0 .. INTERNET_MAX_USER_NAME_LENGTH - 1] of Char;
  lpszPassword: array [0 .. INTERNET_MAX_PASSWORD_LENGTH - 1] of Char;
  lpszUrlPath: array [0 .. INTERNET_MAX_PATH_LENGTH - 1] of Char;
  lpszExtraInfo: array [0 .. 1024 - 1] of Char;
  lpUrlComponents: TURLComponents;
begin
  ZeroMemory(@lpszScheme, SizeOf(lpszScheme));
  ZeroMemory(@lpszHostName, SizeOf(lpszHostName));
  ZeroMemory(@lpszUserName, SizeOf(lpszUserName));
  ZeroMemory(@lpszPassword, SizeOf(lpszPassword));
  ZeroMemory(@lpszUrlPath, SizeOf(lpszUrlPath));
  ZeroMemory(@lpszExtraInfo, SizeOf(lpszExtraInfo));
  ZeroMemory(@lpUrlComponents, SizeOf(TURLComponents));

  lpUrlComponents.dwStructSize := SizeOf(TURLComponents);
  lpUrlComponents.lpszScheme := lpszScheme;
  lpUrlComponents.dwSchemeLength := SizeOf(lpszScheme);
  lpUrlComponents.lpszHostName := lpszHostName;
  lpUrlComponents.dwHostNameLength := SizeOf(lpszHostName);
  lpUrlComponents.lpszUserName := lpszUserName;
  lpUrlComponents.dwUserNameLength := SizeOf(lpszUserName);
  lpUrlComponents.lpszPassword := lpszPassword;
  lpUrlComponents.dwPasswordLength := SizeOf(lpszPassword);
  lpUrlComponents.lpszUrlPath := lpszUrlPath;
  lpUrlComponents.dwUrlPathLength := SizeOf(lpszUrlPath);
  lpUrlComponents.lpszExtraInfo := lpszExtraInfo;
  lpUrlComponents.dwExtraInfoLength := SizeOf(lpszExtraInfo);

  InternetCrackUrl(PChar(lpszUrl), Length(lpszUrl), ICU_DECODE or ICU_ESCAPE, lpUrlComponents);

  Host := lpszHostName;
  Resource := lpszUrlPath;
  ExtraInfo := lpszExtraInfo;
end;

function THTTPSender.GetQueryInfo(hRequest: Pointer; Flag: Integer): String;
var
  code: String;
  size, Index: Cardinal;
begin
  Result := '';
  SetLength(code, 8);
  size := Length(code);
  index := 0;
  if HttpQueryInfo(hRequest, Flag, PChar(code), size, index) then Result := code
  else if GetLastError = ERROR_INSUFFICIENT_BUFFER then begin
    SetLength(code, size);
    size := Length(code);
    if HttpQueryInfo(hRequest, Flag, PChar(code), size, index) then Result := code;
  end;
end;

procedure THTTPSender.URLExecute(const HTTPS: boolean; ServerName, Resource, ExtraInfo: String; Method: THTTPMethod;
  Stream: TStream; PostData: ansistring = '');
const
  C_PROXYCONNECTION = 'Proxy-Connection: Keep-Alive'#10#13;
  BuffSize = 1024;
var
  hInet: HINTERNET;
  hConnect: HINTERNET;
  hRequest: HINTERNET;
  ErrorCode: Integer;
  lpvBuffer: PansiChar;
  lpdwBufferLength: DWORD;
  dwBytesRead: DWORD;
  lpdwNumberOfBytesAvailable: DWORD;
  ConnectPort: INTERNET_PORT;
  OpenTypeFlags: DWORD;
  OpenRequestFlags: DWORD;
  PostDataPointer: Pointer;
  PostDataLength: DWORD;
  lpOtherHeaders: String;
  Buffer: Pointer;

  function ExtractHeaders: boolean;
  var
    lpdwReserved: DWORD;
  begin
    Result := true;
    with RResponse do begin
      lpdwBufferLength := SizeOf(StatusCode);
      lpdwReserved := 0;
      Result := Result and HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_CODE or HTTP_QUERY_FLAG_NUMBER, @StatusCode,
        lpdwBufferLength, lpdwReserved);
      SetLength(StatusText, 1024);
      lpdwBufferLength := Length(StatusText);
      Result := Result and HttpQueryInfo(hRequest, HTTP_QUERY_STATUS_TEXT, @StatusText[1], lpdwBufferLength,
        lpdwReserved);
      lpdwBufferLength := SizeOf(ContentLength);
      if not HttpQueryInfo(hRequest, HTTP_QUERY_CONTENT_LENGTH or HTTP_QUERY_FLAG_NUMBER, @ContentLength,
        lpdwBufferLength, lpdwReserved) then ContentLength := 0;
      SetLength(ContentEncoding, 1024);
      lpdwBufferLength := Length(ContentEncoding);
      if not HttpQueryInfo(hRequest, HTTP_QUERY_CONTENT_ENCODING, @ContentEncoding[1], lpdwBufferLength, lpdwReserved)
      then ContentEncoding := '';
      SetLength(Location, 1024);
      lpdwBufferLength := Length(Location);
      if not HttpQueryInfo(hRequest, HTTP_QUERY_LOCATION, @Location[1], lpdwBufferLength, lpdwReserved) then
          Location := '';
      SetLength(Expires, 1024);
      lpdwBufferLength := Length(Expires);
      if not HttpQueryInfo(hRequest, HTTP_QUERY_EXPIRES, @Expires[1], lpdwBufferLength, lpdwReserved) then
          Expires := '';
    end;
  end;

begin
  with RResponse do begin
    StatusCode := 0;
    StatusText := '';
    RawHeaders := '';
    ContentLength := 0;
    Expires := '';
  end;
  lpOtherHeaders := '';

  if RProxy <> '' then OpenTypeFlags := INTERNET_OPEN_TYPE_PROXY
  else OpenTypeFlags := INTERNET_OPEN_TYPE_PRECONFIG;

  hInet := InternetOpen(PChar(RHeaders.RUserAgent), OpenTypeFlags, PChar(RProxy), PChar(RProxyBypass), 0);

  if RConnectTimeout > 0 then
      InternetSetOption(hInet, INTERNET_OPTION_CONNECT_TIMEOUT, @RConnectTimeout, SizeOf(RConnectTimeout));
  if RReadTimeout > 0 then
      InternetSetOption(hInet, INTERNET_OPTION_RECEIVE_TIMEOUT, @RReadTimeout, SizeOf(RReadTimeout));
  if RSendTimeout > 0 then InternetSetOption(hInet, INTERNET_OPTION_SEND_TIMEOUT, @RSendTimeout, SizeOf(RSendTimeout));

  if hInet = nil then begin
    ErrorCode := GetLastError;
    raise Exception.Create(Format('InternetOpen Error %d Description %s', [ErrorCode, GetWinInetError(ErrorCode)]));
  end;

  try
    if HTTPS then ConnectPort := INTERNET_DEFAULT_HTTPS_PORT
    else ConnectPort := INTERNET_DEFAULT_HTTP_PORT;
    hConnect := InternetConnect(hInet, PChar(ServerName), ConnectPort, PChar(RBasicAuth.RUsername),
      PChar(RBasicAuth.RPassword), INTERNET_SERVICE_HTTP, 0, 0);
    if hConnect = nil then begin
      ErrorCode := GetLastError;
      raise Exception.Create(Format('InternetConnect Error %d Description %s',
        [ErrorCode, GetWinInetError(ErrorCode)]));
    end;

    try
      if HTTPS then OpenRequestFlags := INTERNET_FLAG_SECURE
      else OpenRequestFlags := INTERNET_FLAG_RELOAD;
      if not RAutoRedirects then OpenRequestFlags := OpenRequestFlags or INTERNET_FLAG_NO_AUTO_REDIRECT;
      if (not RUseIECookies) or (not RAllowCookies) then
          OpenRequestFlags := OpenRequestFlags or INTERNET_FLAG_NO_COOKIES;

      hRequest := HttpOpenRequest(hConnect, PChar(GetMethodString(Method)), PChar(Resource + ExtraInfo), HTTP_VERSION,
        PChar(RHeaders.RRefferer), nil, OpenRequestFlags, 0);
      if hRequest = nil then begin
        ErrorCode := GetLastError;
        raise Exception.Create(Format('HttpOpenRequest Error %d Description %s',
          [ErrorCode, GetWinInetError(ErrorCode)]));
      end;
      if RAllowCookies and (not RUseIECookies) then
          lpOtherHeaders := RCookies.GetCookies('.' + ServerName, Resource) + #10;
      if RProxy <> '' then lpOtherHeaders := lpOtherHeaders + C_PROXYCONNECTION + #10;

      try
        if Method = hmPost then begin
          PostDataPointer := @PostData[1];
          PostDataLength := Length(PostData);
        end else begin
          PostDataPointer := nil;
          PostDataLength := 0;
        end;

        if not HTTPSendRequest(hRequest, PWideChar(GetHeaders + lpOtherHeaders), 0, PostDataPointer, PostDataLength)
        then begin
          ErrorCode := GetLastError;
          raise Exception.Create(Format('HttpSendRequest Error %d Description %s',
            [ErrorCode, GetWinInetError(ErrorCode)]));
        end;

        RResponse.RawHeaders := GetQueryInfo(hRequest, HTTP_QUERY_RAW_HEADERS_CRLF);
        if RAllowCookies and (not RUseIECookies) then ProcessCookies(RResponse.RawHeaders);

        if not ExtractHeaders then begin
          ErrorCode := GetLastError;
          raise Exception.Create(Format('HttpQueryInfo Error %d Description %s',
            [ErrorCode, GetWinInetError(ErrorCode)]));
        end;
        if Assigned(ROnWorkBegin) then ROnWorkBegin(self, Response.ContentLength);
        if RResponse.StatusCode = 200 then
          try
            Stream.Seek(0, 0);
            GetMem(Buffer, BuffSize);
            repeat
              if not InternetReadFile(hRequest, Buffer, BuffSize, dwBytesRead) then begin
                ErrorCode := GetLastError;
                raise Exception.Create(Format('InternetReadFile Error %d Description %s',
                  [ErrorCode, GetWinInetError(ErrorCode)]));
              end;
              if dwBytesRead > 0 then Stream.WriteBuffer(Buffer^, dwBytesRead);
              if Assigned(ROnWork) then ROnWork(self, Stream.size);
            until dwBytesRead = 0;
          finally
            FreeMem(Buffer);
          end;
        if Assigned(ROnWorkEnd) then ROnWorkEnd(self);
      finally
        InternetCloseHandle(hRequest);
      end;
    finally
      InternetCloseHandle(hConnect);
    end;
  finally
    InternetCloseHandle(hInet);
  end;
end;

function THTTPSender.GetRandomBoundary: ansistring;
var
  i: Integer;
begin
  Result := '----------0';
  for i := 2 to 15 do Result := Format('%s%d', [Result, random(10)]);
end;

constructor THTTPSender.Create(AOwner: TComponent);
begin
  inherited;
  RCookies := THTTPCookieCollection.Create;
  RHeaders := THTTPHeaders.Create;
  BasicAuth := THTTPBasicAuth.Create;
  RReadTimeout := 0;
  RConnectTimeout := 60000;
  RSendTimeout := 0;
  RProxy := '';
  RProxyBypass := '';
  RUseIECookies := true;
  RAllowCookies := true;
  RAutoRedirects := true;
  DefaultEncoding := TEncoding.ANSI;
  with RHeaders do begin
    RContentType := '';
    RAccept := '';
    RAcceptLanguage := '';
    RAcceptEncoding := '';
    RCustomHeaders.Text := '';
    RRefferer := '';
    RUserAgent := 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)';
  end;
end;

procedure THTTPSender.Free;
begin
  RCookies.Free;
  Destroy;
end;

function THTTPSender.GetAbout: String;
begin
  Result := __ABOUT__;
end;

function THTTPSender.GetHeaders: PWideChar;
begin
  Result := '';
  with RHeaders do begin
    if RContentType <> '' then Result := PChar(Format('%sContent-type: %s'#10#13, [Result, RContentType]));
    if RAcceptLanguage <> '' then Result := PChar(Format('%sAccept-Language: %s'#10#13, [Result, RAcceptLanguage]));
    if RAcceptEncoding <> '' then Result := PChar(Format('%sAccept-Encoding: %s'#10#13, [Result, RAcceptEncoding]));
    if RAccept <> '' then Result := PChar(Format('%sAccept: %s'#10#13, [Result, RAccept]));
    if RCustomHeaders.Text <> '' then Result := PChar(Format('%s'#10#13'%s'#10#13, [Result, RCustomHeaders.Text]));
  end;
end;

function THTTPSender.GetMethodString(const Method: THTTPMethod): String;
begin
  case Method of
    hmGet: Result := 'GET';
    hmPut: Result := 'PUT';
    hmPost: Result := 'POST';
    hmDelete: Result := 'DELETE';
  end;
end;

function THTTPSender.GetPostDataFromPostContainer(const PostContainer: THTTPPostContainer): ansistring;
var
  i: Integer;
  boundary, S: ansistring;
  ms: TMemoryStream;
  ss: TStringStream;
begin
  Result := '';
  boundary := GetRandomBoundary;
  RHeaders.ContentType := RHeaders.ContentType + '; boundary=' + boundary;
  with PostContainer do begin
    for i := 0 to High(RFormFields) do begin
      Result := Format('%s--%s'#10'Content-Disposition: form-data; name="%s"'#10'Content-Type: text/plain' +
        #10'Content-Transfer-Encoding: quoted-printable'#10#10'%s'#10, [Result, boundary, RFormFields[i].Name,
        RFormFields[i].Value]);
    end;
    for i := 0 to High(RFiles) do begin
      Result := Format('%s--%s'#10'Content-Disposition: form-data; name="%s"; filename="%s"'#10'Content-Type: %s' +
        #10'Content-Transfer-Encoding: binary'#10#10, [Result, boundary, RFiles[i].Name, RFiles[i].FileName,
        RFiles[i].ContentType]);
      ms := TMemoryStream.Create;
      ms.LoadFromFile(RFiles[i].FileName);
      ss := TStringStream.Create('');
      ss.CopyFrom(ms, ms.size);
      Result := Result + ss.DataString + #10;
      ss.Free;
      ms.Free;
    end;
  end;
  Result := Result + '--' + boundary + '--'#10#0;
end;

procedure THTTPSender.Get(const URL: String; Stream: TStream);
begin
  PreURLExecute(URL, '', hmGet, Stream);
end;

function THTTPSender.Get(const URL: String): String;
begin
  Result := PreURLExecute(URL, '', hmGet);
end;

function THTTPSender.Post(const URL: String; PostData: ansistring): String;
begin
  Result := PreURLExecute(URL, PostData, hmPost);
end;

procedure THTTPSender.Post(const URL: String; PostData: ansistring; Stream: TStream);
begin
  if RHeaders.ContentType = '' then RHeaders.ContentType := 'application/x-www-form-urlencoded';
  PreURLExecute(URL, PostData, hmPost, Stream);
end;

function THTTPSender.Post(const URL: String; PostContainer: THTTPPostContainer): String;
begin
  if RHeaders.ContentType = '' then RHeaders.ContentType := 'multipart/form-data';
  Result := PreURLExecute(URL, GetPostDataFromPostContainer(PostContainer), hmPost);
end;

procedure THTTPSender.Post(const URL: String; PostContainer: THTTPPostContainer; Stream: TStream);
begin
  if RHeaders.ContentType = '' then RHeaders.ContentType := 'multipart/form-data';
  PreURLExecute(URL, GetPostDataFromPostContainer(PostContainer), hmPost, Stream);
end;

function THTTPSender.Post(const URL: String; PostData: TStringList): String;
begin
  Result := Post(URL, MyStringReplace(PostData.Text, PostData.Delimiter, '&', true));
end;

procedure THTTPSender.Post(const URL: String; PostData: TStringList; Stream: TStream);
begin
  Post(URL, MyStringReplace(PostData.Text, PostData.Delimiter, '&', true), Stream);
end;

function THTTPSender.Put(const URL: String): String;
begin
  Result := PreURLExecute(URL, '', hmPut);
end;

procedure THTTPSender.Put(const URL: String; Stream: TStream);
begin
  PreURLExecute(URL, '', hmPut, Stream);
end;

procedure THTTPSender.PreURLExecute(const URL: String; PostData: ansistring; Method: THTTPMethod; Stream: TStream);
var
  Host, Resource, ExtraInfo: String;
begin
  RResponseText := '';
  ParseURL(URL, Host, Resource, ExtraInfo);
  if Pos('http', URL) = 1 then URLExecute((Pos('https', URL) = 1), Host, Resource, ExtraInfo, Method, Stream)
  else raise Exception.Create(Format('Unknown Protocol %s', [URL]));
end;

function THTTPSender.PreURLExecute(const URL: String; PostData: ansistring; Method: THTTPMethod): string;
var
  StringStream: TStringStream;
  Host, Resource, ExtraInfo: String;
begin
  Result := '';
  RResponseText := '';
  ParseURL(URL, Host, Resource, ExtraInfo);
  StringStream := TStringStream.Create('', DefaultEncoding);
  try
    if Pos('http', URL) = 1 then
        URLExecute((Pos('https', URL) = 1), Host, Resource, ExtraInfo, Method, StringStream, PostData)
    else raise Exception.Create(Format('Unknown Protocol %s', [URL]));
    if StringStream.size > 0 then begin
      StringStream.Seek(0, 0);
      Result := StringStream.ReadString(StringStream.size);
      RResponseText := Result;
    end;
  finally
    StringStream.Free;
  end;
end;

procedure THTTPSender.ProcessCookies(Data: String);
const
  SetCookie = 'Set-Cookie:';
var
  NCookie: THTTPCookie;

  function GetCookie(S: String): THTTPCookie;
  var
    t: String;
  begin
    with Result do begin
      Name := Copy(S, 1, Pos('=', S) - 1);
      Value := Pars(S, '=', ';');
      Path := Pars(S, 'path=', ';');
      Expires := Pars(S, 'expires=', ';');
      Domain := Pars(S, 'domain=', ';');
      HTTPOnly := (Pos('; HttpOnly', S) > 0);
    end;
  end;

begin
  while Pos(SetCookie, Data) > 0 do begin
    NCookie := GetCookie(Pars(Data, SetCookie, #10#13));
    RCookies.Add(NCookie, true);
    if Assigned(ROnCookieAdd) then ROnCookieAdd(self, NCookie);
    delete(Data, Pos(SetCookie, Data), Length(SetCookie));
  end;
end;

{ THTTPCookieCollection }

function THTTPCookieCollection.Add(const Cookie: THTTPCookie; ReplaceIfExists: boolean): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(Cookies) do
    if (Cookies[i].Domain = Cookie.Domain) and (Cookies[i].Name = Cookie.Name) then begin
      Cookies[i] := Cookie;
      exit(i);
    end;
  SetLength(Cookies, Length(Cookies) + 1);
  Cookies[high(Cookies)] := Cookie;
end;

procedure THTTPCookieCollection.Clear;
begin
  SetLength(Cookies, 0);
end;

function THTTPCookieCollection.Count: Integer;
begin
  Result := Length(Cookies);
end;

constructor THTTPCookieCollection.Create;
begin
  inherited;
  RCustomCookies := TStringList.Create;
end;

function THTTPCookieCollection.DeleteCookie(const Index: Integer): boolean;
var
  i: Integer;
begin
  Result := false;
  if (index < 0) or (index > high(Cookies)) then exit;
  for i := Index to High(Cookies) - 1 do Cookies[i] := Cookies[i + 1];
  SetLength(Cookies, Length(Cookies) - 1);
  Result := true;
end;

function THTTPCookieCollection.GetCookie(Index: Integer): THTTPCookie;
begin
  Result := Cookies[Index];
end;

function THTTPCookieCollection.GetCookies(ADomain, APath: String): String;
var
  i: Integer;
begin
  for i := Length(APath) downto 1 do
    if (APath[i] = '/') and (i > 1) then begin
      APath := Copy(APath, 1, i);
      Break;
    end;
  Result := 'Cookies:';
  for i := 0 to High(Cookies) do
    if Cookies[i].Domain = ADomain then Result := Format('%s %s=%s;', [Result, Cookies[i].Name, Cookies[i].Value]);
  Result := Result + ' ' + RCustomCookies.Text;
  if Result[Length(Result) - 1] = ';' then delete(Result, Length(Result) - 1, 2);
  if Length(Result) = 7 then Result := '';
end;

procedure THTTPCookieCollection.PutCookie(Index: Integer; Cookie: THTTPCookie);
begin
  Cookies[Index] := Cookie;
end;

procedure Register;
begin
  RegisterComponents('Internet', [THTTPSender]);
end;

{ THTTPHeaders }

constructor THTTPHeaders.Create;
begin
  inherited;
  RCustomHeaders := TStringList.Create;
end;

{ THTTPPostContainer }

procedure THTTPPostContainer.AddFile(const AName, AFileName: ansistring;
  AContentType: ansistring = 'application/octet-stream');
begin
  SetLength(RFiles, Length(RFiles) + 1);
  with RFiles[High(RFiles)] do begin
    Name := AName;
    FileName := AFileName;
    ContentType := AContentType;
  end;
end;

procedure THTTPPostContainer.AddFormField(const AName, AValue: ansistring);
begin
  SetLength(RFormFields, Length(RFormFields) + 1);
  with RFormFields[High(RFormFields)] do begin
    Name := AName;
    Value := AValue;
  end;
end;

procedure THTTPPostContainer.ClearFiles;
begin
  SetLength(RFiles, 0);
end;

procedure THTTPPostContainer.ClearFormFields;
begin
  SetLength(RFormFields, 0);
end;

procedure THTTPPostContainer.DeleteFile(const Index: Integer);
var
  i: Integer;
begin
  for i := Index to High(RFiles) - 1 do RFiles[i] := RFiles[i + 1];
  SetLength(RFiles, Length(RFiles) - 1);
end;

procedure THTTPPostContainer.DeleteFormField(const Index: Integer);
var
  i: Integer;
begin
  for i := Index to High(RFormFields) - 1 do RFormFields[i] := RFormFields[i + 1];
  SetLength(RFormFields, Length(RFormFields) - 1);
end;

function THTTPPostContainer.GetFile(Index: Integer): THTTPPostContainerFile;
begin
  Result := RFiles[Index];
end;

function THTTPPostContainer.GetFilesCount: Integer;
begin
  Result := Length(RFiles);
end;

function THTTPPostContainer.GetFormField(Index: Integer): THTTPPostContainerFormField;
begin
  Result := RFormFields[Index];
end;

function THTTPPostContainer.GetFormFieldsCount: Integer;
begin
  Result := Length(RFormFields);
end;

procedure THTTPPostContainer.SetFile(Index: Integer; Item: THTTPPostContainerFile);
begin
  RFiles[Index] := Item;
end;

procedure THTTPPostContainer.SetFormField(Index: Integer; Item: THTTPPostContainerFormField);
begin
  RFormFields[Index] := Item;
end;

end.
