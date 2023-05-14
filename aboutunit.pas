unit AboutUnit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, RTTICtrls,
  IpHtml, lclintf;

type

  { TFormAbout }

  TFormAbout = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private

  public

  end;

var
  FormAbout: TFormAbout;

implementation

{$R *.lfm}

{ TFormAbout }




procedure TFormAbout.Label1Click(Sender: TObject);
begin
  OpenURL('https://github.com/JohnGurin/');
end;

procedure TFormAbout.Label2Click(Sender: TObject);
begin
  OpenURL('https://www.linkedin.com/in/evgeniyg/');
end;

end.
