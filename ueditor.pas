unit ueditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Grids, Buttons, StdCtrls, Spin, ugameutils;

type

  { TEditorForm }

  TEditorForm = class(TForm)
    ClearBitBtn: TBitBtn;
    OpenDialog1: TOpenDialog;
    SaveBitBtn: TBitBtn;
    SaveAsBitBtn: TBitBtn;
    OpenBitBtn: TBitBtn;
    CloseBitBtn: TBitBtn;
    GroupBox1: TGroupBox;
    GroupBox2: TPanel;
    HeightSpinEdit: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SaveDialog1: TSaveDialog;
    SkladDrawGrid: TDrawGrid;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    LevelNumSpinEdit: TSpinEdit;
    WidthSpinEdit: TSpinEdit;
    procedure ClearBitBtnClick(Sender: TObject);
    procedure CloseBitBtnClick(Sender: TObject);
    procedure OpenBitBtnClick(Sender: TObject);
    procedure SaveAsBitBtnClick(Sender: TObject);
    procedure SaveBitBtnClick(Sender: TObject);
    procedure SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure SkladDrawGridSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure SpeedButton1Click(Sender: TObject);
    procedure WidthSpinEditChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  EditorForm: TEditorForm;
  CellData : Char; //символ для встановлення в матрицю рівня

implementation
 uses umain, ulogger;
{$R *.lfm}

{ TEditorForm }

procedure TEditorForm.ClearBitBtnClick(Sender: TObject);
var x,y : Integer;
begin
  //заповнюємо динамічний масив пробілами (підлога)
 for x:=0 to High(Sklad) do
  for y:=0 to High(Sklad[x]) do Sklad[x,y]:=' ';
 SkladDrawGrid.Repaint; //перемальовуємо ігрове поле
end;

procedure TEditorForm.CloseBitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TEditorForm.OpenBitBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    LoadLevel(OpenDialog1.FileName,Sklad);
    SkladDrawGrid.ColCount:=High(Sklad[0])+1; //стовбці
    SkladDrawGrid.RowCount:=High(Sklad)+1; //рядки
    WidthSpinEdit.Value:=EditorForm.SkladDrawGrid.ColCount-1;
    HeightSpinEdit.Value:=EditorForm.SkladDrawGrid.RowCount-1;
    //розміри форми підігнати під розміри рівня
    Width:=(High(Sklad[0])+1)*EditorForm.SkladDrawGrid.DefaultColWidth+EditorForm.Panel1.Width+5;
    Height:=(High(Sklad)+1)*EditorForm.SkladDrawGrid.DefaultRowHeight+5;
  end;
end;

procedure TEditorForm.SaveAsBitBtnClick(Sender: TObject);
begin
  if SaveDialog1.Execute then begin
    SaveLevel(SaveDialog1.FileName);
  end;
end;

procedure TEditorForm.SaveBitBtnClick(Sender: TObject);
begin
  SaveLevel(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+LevelNumSpinEdit.Text+'.xsb');
end;

procedure TEditorForm.SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
 {$I drawsklad.inc}
end;

procedure TEditorForm.SkladDrawGridSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
  if CurrSymbol='' then Exit;
  if CurrSymbol='@' then begin
    Player.x:=aCol;
    Player.y:=aRow;
    if  Sklad[aRow,aCol]='.' then Sklad[aRow,aCol]:='+'
     else Sklad[aRow,aCol]:=CurrSymbol[1];
  end else Sklad[aRow,aCol]:=CurrSymbol[1];
  SkladDrawGrid.Repaint;
end;

procedure TEditorForm.SpeedButton1Click(Sender: TObject);
begin
  case CurrSymbol of
'$':SpeedButton1.Down:=false;
' ':SpeedButton2.Down:=false;
'*':SpeedButton3.Down:=false;
'@':SpeedButton4.Down:=false;
'#':SpeedButton5.Down:=false;
'.':SpeedButton6.Down:=false;
  end;
  CurrSymbol:=(Sender as TSpeedButton).Hint;
  (Sender as TSpeedbutton).Down:=true;
end;

procedure TEditorForm.WidthSpinEditChange(Sender: TObject);
begin
 CanDraw:=false;
 Case (Sender as TSpinEdit).Tag of
  1:ChangeMatrixWidth((Sender as TSpinEdit).Value); //ширина
  2:ChangeMatrixHeight((Sender as TSpinEdit).Value); //висота
 end;
 SkladDrawGrid.ColCount:=High(Sklad[0])+1; //стовбці
 SkladDrawGrid.RowCount:=High(Sklad)+1; //рядки
 //розміри форми підігнати під розміри рівня
 Width:=SkladDrawGrid.ColCount*SkladDrawGrid.DefaultColWidth+Panel1.Width+5;
 Height:=SkladDrawGrid.RowCount*SkladDrawGrid.DefaultRowHeight+5;
 CanDraw:=true;
 SkladDrawGrid.Repaint;//перемальовуємо поле редактора
end;

end.

