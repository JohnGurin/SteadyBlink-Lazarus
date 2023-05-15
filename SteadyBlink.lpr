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
(*
TODO
1. User profile settings (timings, language, eye image size)
2. Eye blink animation
3. Multiple screens support
4. Add to startup from the menu
5. Single Instance
6. Period jitter
*)

