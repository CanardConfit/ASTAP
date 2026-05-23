unit unit_download; {download v2026. See example https://wiki.lazarus.freepascal.org/fphttpclient}

interface
uses
  classes, forms,
  fphttpclient,
  openssl,
  sysutils,
  opensslsockets; {in case of compile problems, temporary copy from fpc source the opensslsockets.pp and fpopenssl.pp from /home/h/fpc/packages/openssl/src to hnsky directory}

function download_file(url, filename: string): boolean;//download file
function get_http(url: string): string; //get webpage in string

implementation
uses unit_stack;

function get_http(url: string): string;
var
  Client: TFPHttpClient;
begin
  result := ''; //for early exit
  Client := TFPHttpClient.Create(nil);
  try
    try
      Client.AllowRedirect := true;// Allow redirections
      Client.ConnectTimeout := 10000; // msec
      Client.IOTimeout      := 15000; // msec
      result := Client.Get(url);
    except
      memo2_message('Internet error!!');
    end;
  finally
    Client.Free;
  end;
end;


function download_file(url, filename: string): boolean; {download file}
var
  Client: TFPHttpClient;
  FS: TStream;
begin
  result := true;
  Client := TFPHttpClient.Create(nil);
  try
    try
      FS := TFileStream.Create(Filename, fmCreate or fmOpenWrite);
      try
        Client.AllowRedirect := true; // Allow redirections
        Client.ConnectTimeout := 10000; // msec
        Client.IOTimeout      := 15000; // msec
        Client.Get(url, FS);
      finally
        FS.Free;
      end;
    except
      result := false;
      if FileExists(filename) then
        DeleteFile(filename); // remove incomplete file on failure
    end;
  finally
    Client.Free;
  end;
end;

end.
