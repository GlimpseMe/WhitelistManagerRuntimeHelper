program runhelper;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, process, CustApp;

type

  { TRunHelper }

  TRunHelper = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TRunHelper }

procedure TRunHelper.DoRun;
var
  ErrorMsg: String;
  theExecutable: String;
  Process: TProcess;
  I: Integer;
begin
  ExitCode := 0;
  Process := TProcess.Create(nil);
  try
    ErrorMsg:=CheckOptions('hi:p:w:b:', 'help ip: port: logdir: executable: password: whitelist: banlist: bantime: allowedips: whitelist-format: banlist-format maxlogins:');
    if ErrorMsg<>'' then begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

    if HasOption('h', 'help') then begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    if HasOption('executable') then begin
       theExecutable := GetOptionValue('executable');
       if not fileexists(theExecutable) then
       Begin
         writeln('Executable ('+theExecutable+') not found, exiting.');
         Terminate;
         Exit;
       end;
    end
    else
    begin
      writeln('Full path to executable not configured, exiting.');
      Terminate;
      Exit;
    end;

    if HasOption('logdir') then begin
      Process.Parameters.Add('--logdir=' + GetOptionValue('logdir'));
    end;

    if HasOption('i','ip') then begin
      Process.Parameters.Add('-i');
      Process.Parameters.Add(GetOptionValue('i','ip'));
    end;

    if HasOption('p','port') then begin
      Process.Parameters.Add('-p');
      Process.Parameters.Add(GetOptionValue('p','port'));
    end;

    if HasOption('password') then begin
       Process.Parameters.Add('--password=' + GetOptionValue('password'));
    end;

    if HasOption('w','whitelist') then begin
      Process.Parameters.Add('-w');
      Process.Parameters.Add(GetOptionValue('w','whitelist'));
    end;

    if HasOption('b','banlist') then begin
      Process.Parameters.Add('-b');
      Process.Parameters.Add(GetOptionValue('b','banlist'));
    end;

    if HasOption('whitelist-format') then begin
       Process.Parameters.Add('--whitelist-format=' + GetOptionValue('whitelist-format'));
    end;

    if HasOption('banlist-format') then begin
       Process.Parameters.Add('--banlist-format=' + GetOptionValue('banlist-format'));
    end;

    if HasOption('maxlogins') then begin
       Process.Parameters.Add('--maxlogins=' + GetOptionValue('maxlogins'));
    end;

    if HasOption('bantime') then begin
       Process.Parameters.Add('--bantime=' + GetOptionValue('bantime'));
    end;

    if HasOption('allowedips') then begin
       Process.Parameters.Add('--allowedips=' + GetOptionValue('allowedips'));
    end;

    if HasOption('logintimeout') then begin
       Process.Parameters.Add('--logintimeout=' + GetOptionValue('logintimeout'));
    end;

    if HasOption('idletimeout') then begin
       Process.Parameters.Add('--idletimeout=' + GetOptionValue('idletimeout'));
    end;

    Process.InheritHandles := False;
    Process.Options := [];
    Process.ShowWindow := swoShow;

    for I := 1 to GetEnvironmentVariableCount do
      Process.Environment.Add(GetEnvironmentString(I));

    Process.Executable := theExecutable;
    Process.Execute;
  finally
    Process.Free;
  end;
  halt(0);
  Terminate;
end;

constructor TRunHelper.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TRunHelper.Destroy;
begin
  inherited Destroy;
end;

procedure TRunHelper.WriteHelp;
begin
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: TRunHelper;

{$R *.res}

begin
  Application:=TRunHelper.Create(nil);
  Application.Title:='Glimpse.Me Whitelist Manager Runtime Helper';
  Application.Run;
  Application.Free;
end.

