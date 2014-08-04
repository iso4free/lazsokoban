unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, LCLType, Menus, Buttons, ugameutils;

Type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TBitBtn;
    Button2: TBitBtn;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    EditorMenuItem: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SkladDrawGrid: TDrawGrid;
    Panel1: TPanel;
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditorMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  Form1: TForm1;
  bFloor,                        //пол в складе
  bWall,                         //стена
  bPlayer,                       //складовщик
  bBox,                          //ящик
  bPlace,                        //место, где нужно поставить ящик
  bPlacedBox : Timage;           //ящик на месте

implementation

uses uabout, ueditor;
{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  //динамическое создание компонента
  bFloor:=TImage.Create(self);
  //загрузка изображения из файла
  bFloor.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'floor.png');
  bWall:=TImage.Create(self);
  bWall.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'wall.jpg');
  bPlayer:=TImage.Create(self);
  bPlayer.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'player.png');
  bPlace:=TImage.Create(self);
  bPlace.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'place.png');
  bBox:=TImage.Create(self);
  bBox.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'box.jpg');
  bPlacedBox:=TImage.Create(self);
  bPlacedBox.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'placedbox.jpg');
  CurrLevel:=0;
  Nextlevel;
  //размеры отображаемого склада установить соответственно размеров уровня
  SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
  SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
  //размеры формы подогнать под размеры уровня
  Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
  Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+25;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Dec(CurrLevel);
 Nextlevel;
 SkladDrawGrid.Repaint;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var i : Integer;
   simulatedkey: Word;
begin
 if (LevelSolution='') or (Length(Player.Solution)>0) then Exit;
 BitBtn2.Enabled:=false;  //блокируем кнопку до окончания демки
 for i := 1 to Length(LevelSolution) do begin
  case LevelSolution[i] of
'l','L': simulatedkey:=VK_LEFT;
'r','R': simulatedkey:=VK_RIGHT;
'u','U': simulatedkey:=VK_UP;
'd','D': simulatedkey:=VK_DOWN;
  end;
  FormKeyDown(self,simulatedkey,[]);
  SkladDrawGrid.Repaint;
  Sleep(200); //задержка 0,2 с
  Application.ProcessMessages; //чтобы приложение обработало очередь сообщений
 end;
 BitBtn2.Enabled:=true; //снимаем блокировку кнопки
end;

procedure TForm1.Button2Click(Sender: TObject);
var c : Char;
begin
  //отмена последнего хода
 if Player.Solution='' then Exit;
 c:=Player.Solution[Length(Player.Solution)];
 case c of
'u':uPlayerBack;
'U':begin
     uPlayerBack;
     uBoxBack;
    end;
'd':dPlayerBack;
'D':begin
     dPlayerBack;
     dBoxBack;
    end;
'l':lPlayerBack;
'L':begin
     lPlayerBack;
     lBoxBack;
    end;
'r':rPlayerBack;
'R':begin
     rPlayerBack;
     rBoxBack;
    end;
 end;
 SkladDrawGrid.Repaint;
end;

procedure TForm1.EditorMenuItemClick(Sender: TObject);
begin
   LoadLevel(CurrLevel, Sklad);
   EditorForm.LevelNumSpinEdit.Value:=CurrLevel;
   EditorForm.SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
   EditorForm.SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
   EditorForm.WidthSpinEdit.Value:=High(Sklad[0]);
   EditorForm.HeightSpinEdit.Value:=High(Sklad);
   //размеры формы подогнать под размеры уровня
   EditorForm.Width:=(High(Sklad[0])+1)*EditorForm.SkladDrawGrid.DefaultColWidth+EditorForm.Panel1.Width+5;
   EditorForm.Height:=(High(Sklad)+1)*EditorForm.SkladDrawGrid.DefaultRowHeight+5;
   CurrSymbol:=' ';//символ по умолчанию - пустое место
   EditorForm.SpeedButton2.Down:=true;//делаем нажатой соответствующую кнопку
   EditorForm.ShowModal;//показываем редактор
   SkladDrawGrid.Repaint;//после закрытия редактора перерисовываем уровень
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 //освобождаем память
  bPlacedBox.Free;
  bBox.Free;
  bPlace.Free;
  bPlayer.Free;
  bWall.Free;
  bFloor.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Position:=poScreenCenter;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  CurrLevel:=0;
  Nextlevel;
  Caption:='Socoban: level '+IntToStr(CurrLevel);
  //размеры отображаемого склада установить соответственно размеров уровня
  SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
  SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
  //размеры формы подогнать под размеры уровня
  Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
  Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+25;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  NextLevel;
  Caption:='Socoban: level '+IntToStr(CurrLevel);
  //размеры отображаемого склада установить соответственно размеров уровня
  SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
  SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
  //размеры формы подогнать под размеры уровня
  Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
  Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+25;
  FormResize(Self);
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
   if not LoadLevel(OpenDialog1.FileName,Sklad) then begin
    ShowMessage('Не удалось загрузить уровень!');
    MenuItem4Click(Self); //начинаем игру с первого уровня
   end;
   Caption:='Socoban: level '+OpenDialog1.FileName;
   //размеры отображаемого склада установить соответственно размеров уровня
   SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
   SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
   //размеры формы подогнать под размеры уровня
   Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
   Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+25;
  end;
end;

procedure TForm1.SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
{$I drawsklad.inc}
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case Key of
VK_LEFT  : MoveLeft;
VK_RIGHT : MoveRight;
VK_UP    : MoveUp;
VK_DOWN  : MoveDown;
VK_ESCAPE: Close;
 end;
 Caption:='Socoban: level '+IntToStr(CurrLevel);
 SkladDrawGrid.Repaint;
 if CheckWin then begin
  ShowMessage('Поздравляем! Вы прошли уровень! Ваш результат: '+IntToStr(Length(Player.Solution))+' ходов');
  SaveSolution;
  Nextlevel;
  Caption:='Socoban: level '+IntToStr(CurrLevel);
  //размеры формы подогнать под размеры уровня
  Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
  Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+25;
  //размеры отображаемого склада установить соответственно размеров уровня
  SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
  SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
  FormResize(Self);
 end;
end;


end.
