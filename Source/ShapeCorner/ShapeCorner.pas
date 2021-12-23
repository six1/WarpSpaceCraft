unit ShapeCorner;

interface

uses
  Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, LResources;

type
  TNewShape = class(TShape)
  private
    FCornerSize: Integer;
    procedure SetCornerSize(Value: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property CornerSize: Integer
      read FCornerSize write SetCornerSize default 2;
end;

procedure Register;

implementation

constructor TNewShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCornerSize := 2;
end;

procedure TNewShape.Paint;
var
  X, Y, W, H, S: Integer;
begin
  Canvas.Pen.Color:=Pen.Color;
  Canvas.Pen.Width:=Pen.Width;
  Canvas.Brush.Color:=brush.Color;
  Canvas.Brush.Style:=brush.Style;
  W := Width - Pen.Width + 1;
  H := Height - Pen.Width + 1;
  with Canvas do
  begin
    X := Pen.Width div 2;
    Y := X;
    //W := Width - Pen.Width + 1;
    //H := Height - Pen.Width + 1;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    if W < H then
      S := W
    else
      S := H;
    if Shape in [stSquare, stRoundSquare, stCircle] then
    begin
      Inc(X, (W - S) div 2);
      Inc(Y, (H - S) div 2);
      W := S;
      H := S;
    end;
    case Shape of
      stRectangle, stSquare:
        Rectangle(X, Y, X + W, Y + H);
      stRoundRect, stRoundSquare:
        RoundRect(X, Y, X + W, Y + H, FCornerSize, FCornerSize);
      stCircle, stEllipse:
        Ellipse(X, Y, X + W, Y + H);
    end;
  end;
end;

procedure TNewShape.SetCornerSize(Value: Integer);
begin
  if FCornerSize <> Value then
    FCornerSize := Value;
  Invalidate;
end;

procedure Register;
begin
  {$I newshape.lrs}
  RegisterComponents('Additional',[TNewShape]);
end;

initialization
{$I newshape.lrs}

end.
