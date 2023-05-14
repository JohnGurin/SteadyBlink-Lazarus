program SteadyBlink;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
     {$ENDIF} {$IFDEF HASAMIGA}
  athreads,
     {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, runtimetypeinfocontrols,
  BlinkerUnit,
  Windows,
  AboutUnit { you can add units after this };

{$R *.res}
var
  AppName: PChar;
  Ex: integer;
begin
  RequireDerivedFormResource := True;
  Application.Title:='SteadyBlink';
  Application.Scaled:=True;
  Application.Initialize;
  AppName := PChar(Application.Title);

  //ShowInTaskBar:=stNever;// bug, workaround
  Ex := GetWindowLong(FindWindow(nil, AppName), GWL_EXSTYLE);
  SetWindowLong(
    FindWindow(nil, AppName),
    GWL_EXSTYLE,
    Ex or WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW
    );
  Application.CreateForm(TFormBlinker, FormBlinker);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.
