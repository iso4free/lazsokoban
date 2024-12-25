unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Grids, LCLType, Menus, Buttons, ugameutils;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    bbtnExit: TBitBtn;
    bbtnDemo: TBitBtn;
    bbtnRestart: TBitBtn;
    bbtnUndo: TBitBtn;
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
    procedure bbtnDemoClick(Sender: TObject);
    procedure bbtnRestartClick(Sender: TObject);
    procedure bbtnUndoClick(Sender: TObject);
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
    procedure SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
  private
    procedure SetSizes;
    { private declarations }
  public
    procedure LoadSkin(aDir: string);
    { public declarations }

  end;

var
  frmMain: TfrmMain;
  bFloor,                        //підлога в складі
  bWall,                         //стіна
  bPlayer,                       //кладовщик
  bBox,                          //ящик
  bPlace,
  //місце, куди потрібно перемістити ящик
  bPlacedBox: Timage;           //ящик на місці

implementation

uses uabout, ueditor;
  {$R *.lfm}

  { TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  CanDraw := False;
  //створення і завантаження зображень
  bFloor := TImage.Create(self);
  bWall := TImage.Create(self);
  bPlayer := TImage.Create(self);
  bPlace := TImage.Create(self);
  bBox := TImage.Create(self);
  bPlacedBox := TImage.Create(self);

  LoadSkin(ProgramDirectory + DirectorySeparator + 'data' + DirectorySeparator + 'halloween');
  CurrLevel := 0;
  Nextlevel;
  SetSizes;
  //все завантажено, можна намалювати рівень
  CanDraw := True;
end;

procedure TfrmMain.bbtnRestartClick(Sender: TObject);
begin
  Dec(CurrLevel);
  Nextlevel;
  SkladDrawGrid.Repaint;
end;

procedure TfrmMain.bbtnDemoClick(Sender: TObject);
var
  i: integer;
  simulatedkey: word;
begin
  if (LevelSolution = '') or (Length(Player.Solution) > 0) then Exit;
  bbtnDemo.Enabled := False;
  //блокуємо кнопки до закінчення демки
  bbtnExit.Enabled := False;
  bbtnRestart.Enabled := False;
  bbtnUndo.Enabled := False;
  for i := 1 to Length(LevelSolution) do
  begin
    case LevelSolution[i] of
      'l', 'L': simulatedkey := VK_LEFT;
      'r', 'R': simulatedkey := VK_RIGHT;
      'u', 'U': simulatedkey := VK_UP;
      'd', 'D': simulatedkey := VK_DOWN;
    end;
    FormKeyDown(self, simulatedkey, []);
    SkladDrawGrid.Repaint;
    Sleep(200); //затримка 0,2 с
    Application.ProcessMessages; //щоб не підвисав інтерфейс
  end;
  bbtnDemo.Enabled := True; //знімаємо блокування кнопок
  bbtnExit.Enabled := True;
  bbtnRestart.Enabled := True;
  bbtnUndo.Enabled := True;
end;

procedure TfrmMain.bbtnUndoClick(Sender: TObject);
var
  c: char;
begin
  //відміна останнього ходу
  if Player.Solution = '' then Exit;
  c := Player.Solution[Length(Player.Solution)];
  case c of
    'u': uPlayerBack;
    'U': begin
      uPlayerBack;
      uBoxBack;
    end;
    'd': dPlayerBack;
    'D': begin
      dPlayerBack;
      dBoxBack;
    end;
    'l': lPlayerBack;
    'L': begin
      lPlayerBack;
      lBoxBack;
    end;
    'r': rPlayerBack;
    'R': begin
      rPlayerBack;
      rBoxBack;
    end;
  end;
  SkladDrawGrid.Repaint;
end;

procedure TfrmMain.EditorMenuItemClick(Sender: TObject);
begin
  LoadLevel(CurrLevel, Sklad);
  EditorForm.LevelNumSpinEdit.Value := CurrLevel;
  EditorForm.SkladDrawGrid.ColCount := High(Sklad[0]) + 1;
  //кількість стовбців
  EditorForm.SkladDrawGrid.RowCount := High(Sklad) + 1; //кількість рядків
  EditorForm.WidthSpinEdit.Value := High(Sklad[0]) + 1;
  EditorForm.HeightSpinEdit.Value := High(Sklad) + 1;
  //розміри форми підігнати під розміри рівня
  EditorForm.Width := (EditorForm.SkladDrawGrid.ColCount) *
    EditorForm.SkladDrawGrid.DefaultColWidth + EditorForm.Panel1.Width + 5;
  EditorForm.Height := (EditorForm.SkladDrawGrid.RowCount) *
    EditorForm.SkladDrawGrid.DefaultRowHeight + 5;
  CurrSymbol := ' ';//символ по замовчуванню - пробіл
  EditorForm.sbFloor.Down := True;
  //натискаємо відповідну кнопку
  EditorForm.ShowModal;//показувємо редактор
  SkladDrawGrid.Repaint;
  //після закриття редактора перемальовуємо рівень
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  //звільняємо пам'ять
  bPlacedBox.Free;
  bBox.Free;
  bPlace.Free;
  bPlayer.Free;
  bWall.Free;
  bFloor.Free;
  Sklad := nil;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  Position := poScreenCenter;
end;

procedure TfrmMain.ChangeThemeMenuItemClick(Sender: TObject);
var
  SkinPath: string;
begin
  //зміна скіна - вибір відповідної папки з асетами
  SelectDirectoryDialog1.InitialDir := ExtractFileDir(Application.ExeName);
  if SelectDirectoryDialog1.Execute then
  begin
    SkinPath := SelectDirectoryDialog1.FileName;
    LoadSkin(SkinPath);
  end;
end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TfrmMain.MenuItem4Click(Sender: TObject);
begin
  CurrLevel := 0;
  Nextlevel;
  Caption := 'Sokoban: level ' + IntToStr(CurrLevel);
  SetSizes;
end;

procedure TfrmMain.MenuItem6Click(Sender: TObject);
begin
  NextLevel;
  Caption := 'Sokoban: level ' + IntToStr(CurrLevel);
  SetSizes;
  FormResize(Self);
end;

procedure TfrmMain.MenuItem8Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.MenuItem9Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    if not LoadLevel(OpenDialog1.FileName, Sklad) then
    begin
      ShowMessage('Не вдалось завантажити рівень!');
      MenuItem4Click(Self); //починаємо гру з першого рівня
    end;
    Caption := 'Sokoban: level ' + OpenDialog1.FileName;
    SetSizes;
  end;
end;

procedure TfrmMain.SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: integer;
  aRect: TRect; aState: TGridDrawState);
begin
  {$I drawsklad.inc}
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: MoveLeft;
    VK_RIGHT: MoveRight;
    VK_UP: MoveUp;
    VK_DOWN: MoveDown;
    VK_ESCAPE: Close;
  end;
  Caption := 'Sokoban: level ' + IntToStr(CurrLevel);
  SkladDrawGrid.Repaint;
  if CheckWin then
  begin
    ShowMessage('Вітаємо! Ви пройшли рівень! Ваш результат: '
      + IntToStr(Length(Player.Solution)) + ' ходів');
    SaveSolution;
    Nextlevel;
    Caption := 'Sokoban: level ' + IntToStr(CurrLevel);
    SetSizes;
    FormResize(Self);
  end;
end;

procedure TfrmMain.SetSizes;
//встановити розміри рівня і форми
begin
  //розміри видимого складу встановити відповідно розмірів рівня
  SkladDrawGrid.ColCount := High(Sklad[0]) + 1; //кількість стовбців
  SkladDrawGrid.RowCount := High(Sklad) + 1; //кількість рядків
  //розміри форми підігнати під розміри рівня
  Width := (High(Sklad[0]) + 1) * SkladDrawGrid.DefaultColWidth + 10;
  Height := (High(Sklad) + 1) * SkladDrawGrid.DefaultRowHeight + Panel1.Height + 30;
end;

procedure TfrmMain.LoadSkin(aDir: string);
begin
  //завантаження ассетівв з файлів
  bFloor.Picture.LoadFromFile(aDir + DirectorySeparator + 'floor.png');
  bWall.Picture.LoadFromFile(aDir + DirectorySeparator + 'wall.png');
  bPlayer.Picture.LoadFromFile(aDir + DirectorySeparator + 'player.png');
  bPlace.Picture.LoadFromFile(aDir + DirectorySeparator + 'place.png');
  bBox.Picture.LoadFromFile(aDir + DirectorySeparator + 'box.png');
  bPlacedBox.Picture.LoadFromFile(aDir + DirectorySeparator + 'placedbox.png');
end;


end.
