unit BlinkerUnit;

 {$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, Menus,
  BGRABitmap, BGRASVG, BGRABitmapTypes, AboutUnit, Dialogs;

type

  { TFormBlinker }

  TFormBlinker = class(TForm)
    BlinkerTimer: TTimer;
    BlinkerTrayIcon: TTrayIcon;
    MenuItemAbout: TMenuItem;
    MenuItemPauseResume: TMenuItem;
    MenuItemExit: TMenuItem;
    TrayPopupMenu: TPopupMenu;

    procedure BlinkerTrayIconMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure FormCreate(Sender: TObject);
    procedure BlinkerTimerTimer(Sender: TObject);
    procedure BlinkerTrayIconClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemPauseResumeClick(Sender: TObject);
    procedure MenuItemPauseResumeHandle();
    procedure TrayPopupMenuPopup(Sender: TObject);

  private
    bfBlend: TBlendFunction;
    pPos: TPoint;
    sSize: TSize;
    dwStyle: DWORD;
  end;

type
  EyeMode = (EyeShowing, EyeHidden, EyePaused);

var
  FormBlinker: TFormBlinker;
  mode: EyeMode;
  EYE_ACTIVE: TBGRABitmap;
  EYE_PAUSED: TBGRABitmap;

function UpdateLayeredWindow(hwnd: HWND; hdcDst: HDC; pptDst: PPoint;
  psize: PSize; hdcSrc: HDC; pptSrc: PPoint; crKey: TColor;
  pblend: PBlendFunction; dwFlags: DWORD): BOOL; stdcall; external 'user32';

implementation

 {$R *.lfm}

const
  EYE_SIZE: integer = 96;
  UPSCALE_K: integer = 5;
  RESOURCE_DEFAULT_SVG = 'EYE1';

  EYE_SHOW_MS = 1500;
  EYE_HIDE_MS = 3500;
  EYE_PAUSED_REMIND_MS = 60000;

procedure TFormBlinker.FormCreate(Sender: TObject);

var
  SVGData: TResourceStream;

  SVG: TBGRASVG;
  PNG: TBGRABitmap;
begin
  mode := EyeShowing;
  FormStyle := fsSystemStayOnTop;
  Borderstyle := bsNone;
  Width := EYE_SIZE;
  Height := EYE_SIZE;

  SVGData := TResourceStream.Create(HInstance, RESOURCE_DEFAULT_SVG, RT_RCDATA);
  SVG := TBGRASVG.Create(SVGData);
  PNG := TBGRABitmap.Create;
  PNG.SetSize(EYE_SIZE * UPSCALE_K, EYE_SIZE * UPSCALE_K);
  try

    SVG.StretchDraw(PNG.Canvas2D, taCenter, tlCenter,
      0, 0, PNG.Width, PNG.Height);
    BGRAReplace(PNG, PNG.Resample(EYE_SIZE, EYE_SIZE, rmFineResample));

    EYE_ACTIVE := PNG.Duplicate(True);
    EYE_PAUSED := PNG.FilterGrayscale;


    dwStyle := GetWindowLongA(Self.Handle, GWL_EXSTYLE);
    if (dwStyle and WS_EX_LAYERED = 0) then
      SetWindowLong(Self.Handle, GWL_EXSTYLE, dwStyle or
        WS_EX_TRANSPARENT or WS_EX_LAYERED or WS_EX_TOPMOST);

    pPos := Point(0, 0);
    sSize.cx := EYE_SIZE;
    sSize.cy := EYE_SIZE;

    bfBlend.BlendOp := AC_SRC_OVER;
    bfBlend.BlendFlags := 0;
    bfBlend.SourceConstantAlpha := 255;
    bfBlend.AlphaFormat := AC_SRC_ALPHA;

    BlinkerTrayIcon.Icon.Assign(EYE_ACTIVE.Bitmap);

    BlinkerTrayIcon.Show;
    UpdateLayeredWindow(Self.Handle, 0, nil, @sSize,
      PNG.Bitmap.Canvas.Handle, @pPos,
      0, @bfBlend, ULW_ALPHA);
  finally
    PNG.Free;
  end;
end;

procedure TFormBlinker.BlinkerTrayIconMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  if Button = mbRight then
    TrayPopupMenu.PopUp;
end;



procedure TFormBlinker.BlinkerTimerTimer(Sender: TObject);
var
  flag: uint = SWP_NOACTIVATE;
begin

  case mode of
    EyeShowing:
    begin
      flag := SWP_NOACTIVATE or SWP_HIDEWINDOW;
      BlinkerTimer.Interval := EYE_HIDE_MS;
      mode := EyeHidden;
    end;
    EyeHidden:
    begin
      flag := SWP_NOACTIVATE or SWP_SHOWWINDOW;
      BlinkerTimer.Interval := EYE_SHOW_MS;
      mode := EyeShowing;
    end;
    EyePaused:
    begin
      BlinkerTrayIcon.ShowBalloonHint;
    end;
  end;

  SetWindowPos(
    Handle, HWND_TOPMOST,
    Self.Left, Self.Top, Self.Width, Self.Height,
    flag
    );
end;

procedure TFormBlinker.BlinkerTrayIconClick(Sender: TObject);
begin
  Self.MenuItemPauseResumeHandle();
end;

procedure TFormBlinker.FormDestroy(Sender: TObject);
begin
  EYE_ACTIVE.Free;
  EYE_PAUSED.Free;
end;

procedure TFormBlinker.MenuItemAboutClick(Sender: TObject);
begin
  FormAbout.Show;
end;

procedure TFormBlinker.MenuItemExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormBlinker.MenuItemPauseResumeHandle();
var
  flag: uint = SWP_NOACTIVATE;
begin
  case mode of
    EyeShowing,
    EyeHidden:
    begin
      flag := SWP_NOACTIVATE or SWP_HIDEWINDOW;
      BlinkerTimer.Interval := EYE_PAUSED_REMIND_MS;
      MenuItemPauseResume.Caption := 'Resume';
      BlinkerTrayIcon.Icon.Assign(EYE_PAUSED.Bitmap);
      mode := EyePaused;
    end;
    EyePaused:
    begin
      flag := SWP_NOACTIVATE or SWP_SHOWWINDOW;
      BlinkerTimer.Interval := EYE_SHOW_MS;
      MenuItemPauseResume.Caption := 'Pause';
      BlinkerTrayIcon.Icon.Assign(EYE_ACTIVE.Bitmap);
      mode := EyeShowing;
    end;
  end;


  SetWindowPos(
    Handle, HWND_TOPMOST,
    Self.Left, Self.Top, Self.Width, Self.Height,
    flag
    );
end;

procedure TFormBlinker.MenuItemPauseResumeClick(Sender: TObject);
begin
  Self.MenuItemPauseResumeHandle();
end;

procedure TFormBlinker.TrayPopupMenuPopup(Sender: TObject);
begin
  // Hack to fix the "by design" behaviour of popups from notification area icons.
  // See: http://support.microsoft.com/kb/135788
  BringToFront();
end;

end.
