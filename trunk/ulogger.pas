unit ulogger;

{$mode objfpc}{$H+}

{******************************************************************************}
{                                                                              }
{                Модуль для ведення ЛОГ-файла для полегшення відладки          }
{                                                                              }
{                                                                              }
{ Опис і парамерти роботи                                                      }
{ -----------------------                                                      }
{                                                                              }
{ Історія ревізій                                                              }
{ ---------------                                                              }
{         10/03/2013:  Реалізовано базовий функціонал                          }
{                                                                              }
{******************************************************************************}

interface

uses
  Classes,
  SysUtils;

type

  { TLogger }

  TLogger = class
  private
    FAutoSave: Boolean;
    FLogFileName: String;
    fLog : TStringList;
    procedure SetAutoSave(AValue: Boolean);
    procedure SetLogFileName(AValue: String);

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure LogError( ErrorMessage : string; Location : string );
    procedure LogWarning( WarningMessage : string; Location : string );
    procedure LogStatus( StatusMessage : string; Location : string );
  published
    property LogFileName : String read FLogFileName write SetLogFileName;
    property AutoSave : Boolean read FAutoSave write SetAutoSave;
  end;

var
  Log : TLogger;

implementation

procedure TLogger.SetLogFileName(AValue: String);
begin
  if FLogFileName=AValue then Exit;
  FLogFileName:=AValue;
end;

procedure TLogger.SetAutoSave(AValue: Boolean);
begin
  if FAutoSave=AValue then Exit;
  FAutoSave:=AValue;
end;

{ TLogger }
constructor TLogger.Create;
begin
  inherited Create;
  fLog:=TStringList.Create;
end;

destructor TLogger.Destroy;
begin
  fLog.SaveToFile(FLogFileName);
  fLog.Free;
  inherited Destroy;
end;

procedure TLogger.LogError(ErrorMessage: string; Location: string);
var
  S : string;
begin
  S := '*** ERROR *** : @ ' + TimeToStr(Time) + ' MSG : ' + ErrorMessage + ' IN : ' + Location + #13#10;
  fLog.Add(s);
  if FAutoSave then fLog.SaveToFile(FLogFileName);
end;

procedure TLogger.LogStatus(StatusMessage: string; Location: string);
var
  S : string;
begin
  S := 'STATUS INFO : @ ' + TimeToStr(Time) + ' MSG : ' + StatusMessage + ' IN : ' + Location + #13#10;
  fLog.Add(s);
  if FAutoSave then fLog.SaveToFile(FLogFileName);
end;

procedure TLogger.LogWarning(WarningMessage: string; Location: string);
var
  S : string;
begin
  S := '=== WARNING === : @ ' + TimeToStr(Time) + ' MSG : ' + WarningMessage + ' IN : ' + Location + #13#10;
  fLog.Add(s);
  if FAutoSave then fLog.SaveToFile(FLogFileName);
end;

initialization
begin
  Log := TLogger.Create;
  {$IFDEF WINDOWS}
  Log.LogFileName:=ChangeFileExt(ParamStr(0),'.log');
  {$ELSE}
  Log.LogFileName:=ChangeFileExt(ParamStr(0),'.log');
  {$ENDIF}
  Log.LogStatus( 'Starting Application', 'Initialization' );
  Log.LogStatus('AppName',ApplicationName);
end;

finalization
begin
  Log.LogStatus( 'Terminating Application', 'Finalization' );
  Log.Free;
  Log := nil;
end;

end.

