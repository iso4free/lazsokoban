unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    SkladDrawGrid: TDrawGrid;
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  private
    { private declarations }
  public
    { public declarations }
    function LoadLevel(levnom : Integer):Boolean;
    procedure Nextlevel;
  end;

var
  Form1: TForm1;
  Sklad : array of array of Char;//игровое поле
  FieldX, FieldY : Integer;      //размеры текущего уровня
  Solution : String;             //список ходов пользователя
  bFloor,                        //пол в складе
  bWall,                         //стена
  bPlayer,                       //складовщик
  bBox,                          //ящик
  bPlace,                        //место, где нужно поставить ящик
  bPlacedBox : Timage;           //ящик на месте
  CurrLevel : Integer;           //№ текущего уровня

implementation

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
  bPlayer.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'player.gif');
  bPlace:=TImage.Create(self);
  bPlace.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'place.png');
  bBox:=TImage.Create(self);
  bBox.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'box.jpg');
  bPlacedBox:=TImage.Create(self);
  bPlacedBox.Picture.LoadFromFile(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+'placedbox.jpg');
  CurrLevel:=0;
  Nextlevel;
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

procedure TForm1.SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  case Sklad[aRow,aCol] of
' ':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//пол
'#':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bWall.Picture.Bitmap);//стена
'.':begin //цель
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//сначала рисуем пол
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlace.Picture.Bitmap);//затем цель
    end;
'@':begin //складовщик
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//сначала рисуем пол
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlayer.Picture.Bitmap);//затем складовщика
    end;
'+':begin //складовщик на цели
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bFloor.Picture.Bitmap);//сначала рисуем пол
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlace.Picture.Bitmap);//после этого цель
     SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlayer.Picture.Bitmap);//и только затем складовщика
    end;
'$':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bBox.Picture.Bitmap);//ящик
'*':SkladDrawGrid.Canvas.Draw(aRect.Left,aRect.Top,bPlacedBox.Picture.Bitmap);//ящик на цели
  end;
end;

function TForm1.LoadLevel(levnom: Integer) : Boolean;
var t : TextFile; //файл уровня
    i : Integer;  //счётчик
    s : String;
    currline : Integer; //счётчик строк
begin
 Result:=true;
 //проверим наличие файла уровня
 if not FileExistsUTF8(ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+IntToStr(levnom)+'.xsb') then begin
  //файл отсутствует - устанавливаем отрицательный результат и выходим
  Result:=false;
  Exit;
 end;
 //обнуляем динамический массив
 for i:=0 to High(Sklad) do SetLength(Sklad[i],0);
 SetLength(Sklad,0);
 AssignFile(t,ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+IntToStr(levnom)+'.xsb');
 Reset(t);
 currline:=0;
 repeat
  Inc(currline);
  ReadLN(t,s);
  SetLength(Sklad,currline);
  SetLength(Sklad[currline-1],Length(s));
  for i:=1 to Length(s) do Sklad[currline-1,i-1]:=s[i];
 until EoF(t);
end;

procedure TForm1.Nextlevel;
begin
 Inc(CurrLevel); //увеличить на 1 счётчик уровней
 if not LoadLevel(CurrLevel) then begin //пробуем загрузить первый уровень
  ShowMessage('Отсутствует файл уровня!');
  Exit; //отсутствует файл - выходим ничего не делая
 end;
 //размеры формы подогнать под размеры уровня
 Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
 Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+5;
 //размеры отображаемого склада установить соответственно размеров уровня
 SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
 SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
end;

end.

