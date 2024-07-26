unit unit_download; {download file. See example https://wiki.lazarus.freepascal.org/fphttpclient}
                    {created 2019-9-5}
interface

uses
  classes, forms,
  fphttpclient,
  openssl,
  opensslsockets; {in case of compile problems, temporary copy from fpc source the opensslsockets.pp and fpopenssl.pp from /home/h/fpc/packages/openssl/src to hnsky directory}

function download_file(url, filename:string):boolean;{download file}
function get_http(url: string): string;//get webpage in string

implementation

uses unit_stack;

function get_http(url:string): string;
var
  Client: TFPHttpClient;
begin
  result:=''; //for early exit
  if InitSSLInterface=false then begin application.messagebox(pchar('Install OpenSSL. Required for https conections to AAVSO'), pchar('Missing library'),0);exit;end;
  Client := TFPHttpClient.Create(nil);
  try
    try
    { Allow redirections }
    Client.AllowRedirect := true;
    result:=Client.Get(url);
  except
    memo2_message('Internet error!!');

  end;
  finally
    Client.Free;
  end;
end;


function download_file(url, filename:string):boolean;{download file}
var
  Client: TFPHttpClient;
  FS: TStream;
begin
  result:=true;
  InitSSLInterface; { SSL initialization has to be done by hand here }
  Client := TFPHttpClient.Create(nil);
  FS := TFileStream.Create(Filename,fmCreate or fmOpenWrite);
  try
    try
      Client.AllowRedirect := true;{ Allow redirections }
      Client.Get(url,FS);
    except
  //    on E: EHttpClient do
  //    application.messagebox(pchar(E.Message),pchar(Error_string),0);
  //    else
  //    raise;
      result:=false;
    end;
    finally
      FS.Free;
      Client.Free;
  end;
end;

end.

