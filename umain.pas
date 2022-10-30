unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Grids, LCLType, Menus, Buttons, ugameutils;

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
    ChangeThemeMenuItem: TMenuItem;
    N1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SkladDrawGrid: TDrawGrid;
    Panel1: TPanel;
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EditorMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ChangeThemeMenuItemClick(Sender: TObject);
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
    procedure SetSizes;
    { private declarations }
  public
    procedure LoadSkin(aDir : String);
    { public declarations }

  end;

var
  Form1: TForm1;
  bFloor,                        //підлога в складі
  bWall,                         //стіна
  bPlayer,                       //кладовщик
  bBox,                          //ящик
  bPlace,                        //місце, куди потрібно перемістити ящик
  bPlacedBox : Timage;           //ящик на місці

implementation

uses uabout, ueditor;
{$R *.frm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  CanDraw:=false;
  //створення і завантаження зображень
  bFloor:=TImage.Create(self);
  bWall:=TImage.Create(self);
  bPlayer:=TImage.Create(self);
  bPlace:=TImage.Create(self);
  bBox:=TImage.Create(self);
  bPlacedBox:=TImage.Create(self);

  LoadSkin(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'halloween');
  CurrLevel :=0;
  Nextlevel;
  SetSizes;
  //все завантажено, можна намалювати рівень
  CanDraw:=true;
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
 BitBtn2.Enabled:=false;  //блокуємо кнопку до закінчення демки
 for i := 1 to Length(LevelSolution) do begin
  case LevelSolution[i] of
'l','L': simulatedkey:=VK_LEFT;
'r','R': simulatedkey:=VK_RIGHT;
'u','U': simulatedkey:=VK_UP;
'd','D': simulatedkey:=VK_DOWN;
  end;
  FormKeyDown(self,simulatedkey,[]);
  SkladDrawGrid.Repaint;
  Sleep(200); //затримка 0,2 с
  Application.ProcessMessages; //щоб не підвисав інтерфейс
 end;
 BitBtn2.Enabled:=true; //знімаємо блокування кнопки
end;

procedure TForm1.Button2Click(Sender: TObject);
var c : Char;
begin
  //відміна останнього ходу
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
   EditorForm.SkladDrawGrid.ColCount:=High(Sklad[0])+1; //кількість стовбців
   EditorForm.SkladDrawGrid.RowCount:=High(Sklad)+1; //кількість рядків
   EditorForm.WidthSpinEdit.Value:=High(Sklad[0])+1;
   EditorForm.HeightSpinEdit.Value:=High(Sklad)+1;
   //розміри форми підігнати під розміри рівня
   EditorForm.Width:=(EditorForm.SkladDrawGrid.ColCount)*EditorForm.SkladDrawGrid.DefaultColWidth+EditorForm.Panel1.Width+5;
   EditorForm.Height:=(EditorForm.SkladDrawGrid.RowCount)*EditorForm.SkladDrawGrid.DefaultRowHeight+5;
   CurrSymbol:=' ';//символ по замовчуванню - пробіл
   EditorForm.SpeedButton2.Down:=true;//натискаємо відповідну кнопку
   EditorForm.ShowModal;//показувємо редактор
   SkladDrawGrid.Repaint;//після закриття редактора перемальовуємо рівень
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
 //звільняємо пам'ять
  bPlacedBox.Free;
  bBox.Free;
  bPlace.Free;
  bPlayer.Free;
  bWall.Free;
  bFloor.Free;
  Sklad:=nil;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Position:=poScreenCenter;
end;

procedure TForm1.ChangeThemeMenuItemClick(Sender: TObject);
var SkinPath : String;
begin
 //зміна скіна - вибір відповідної папки з асетами
 SelectDirectoryDialog1.InitialDir:=ExtractFileDir(Application.ExeName);
 if SelectDirectoryDialog1.Execute then begin
  SkinPath:=SelectDirectoryDialog1.FileName;
  LoadSkin(SkinPath);
 end;
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin
  CurrLevel:=0;
  Nextlevel;
  Caption:='Sokoban: level '+IntToStr(CurrLevel);
  SetSizes;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
  NextLevel;
  Caption:='Sokoban: level '+IntToStr(CurrLevel);
  SetSizes;
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
    ShowMessage('Не вдалось завантажити рівень!');
    MenuItem4Click(Self); //починаємо гру з першого рівня
   end;
   Caption:='Sokoban: level '+OpenDialog1.FileName;
   SetSizes;
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
 Caption:='Sokoban: level '+IntToStr(CurrLevel);
 SkladDrawGrid.Repaint;
 if CheckWin then begin
  ShowMessage('Вітаємо! Ви пройшли рівень! Ваш результат: '+IntToStr(Length(Player.Solution))+' ходів');
  SaveSolution;
  Nextlevel;
  Caption:='Sokoban: level '+IntToStr(CurrLevel);
  SetSizes;
  FormResize(Self);
 end;
end;

procedure TForm1.SetSizes;
//встановити розміри рівня і форми
begin
  //розміри видимого складу встановити відповідно розмірів рівня
  SkladDrawGrid.ColCount:=High(Sklad[0])+1; //кількість стовбців
  SkladDrawGrid.RowCount:=High(Sklad)+1; //кількість рядків
  //розміри форми підігнати під розміри рівня
  Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+10;
  Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+30;
end;

procedure TForm1.LoadSkin(aDir: String);
begin
  //завантаження ассетівв з файлів
   bFloor.Picture.LoadFromFile(aDir+DirectorySeparator+'floor.png');
   bWall.Picture.LoadFromFile(aDir+DirectorySeparator+'wall.png');
   bPlayer.Picture.LoadFromFile(aDir+DirectorySeparator+'player.png');
   bPlace.Picture.LoadFromFile(aDir+DirectorySeparator+'place.png');
   bBox.Picture.LoadFromFile(aDir+DirectorySeparator+'box.png');
   bPlacedBox.Picture.LoadFromFile(aDir+DirectorySeparator+'placedbox.png');
end;


end.

