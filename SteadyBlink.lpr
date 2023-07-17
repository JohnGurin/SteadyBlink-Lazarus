program SteadyBlink;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
 {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
 {$ENDIF}
  Interfaces,
  Forms,
  BlinkerUnit,
  Windows,
  AboutUnit { you can add units after this };

{$R *.res}
begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;

  Application.CreateForm(TFormBlinker, FormBlinker);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.

