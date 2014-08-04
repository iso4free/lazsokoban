unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Grids, LCLType;

type
     TPlayer = record
      x,y : Integer; //текущие координаты
      Solution : String; //список ходов пользователя
     end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    SkladDrawGrid: TDrawGrid;
    Panel1: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SkladDrawGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure SkladDrawGridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { private declarations }
  public
    { public declarations }
    function LoadLevel(levnom : Integer):Boolean;
    procedure Nextlevel;
    function CheckWin: Boolean;
  end;

var
  Form1: TForm1;
  Sklad : array of array of Char;//игровое поле
  FieldX, FieldY : Integer;      //размеры текущего уровня
  bFloor,                        //пол в складе
  bWall,                         //стена
  bPlayer,                       //складовщик
  bBox,                          //ящик
  bPlace,                        //место, где нужно поставить ящик
  bPlacedBox : Timage;           //ящик на месте
  CurrLevel : Integer;           //№ текущего уровня
  Player : TPlayer;              //текущее состояние игрока

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

procedure TForm1.Button1Click(Sender: TObject);
begin
 Dec(CurrLevel);
 Nextlevel;
 SkladDrawGrid.Repaint;
 SkladDrawGrid.SetFocus;
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

procedure TForm1.SkladDrawGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

procedure MoveLeft; //переместиться влево
begin
  if Player.x=0 then Exit;//двигаться некуда
case Sklad[Player.y,Player.x-1] of
'#': Exit;//стена
' ': Begin //пусто
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Dec(Player.x); //уменьшить X координату игрока
      Sklad[Player.y,Player.x]:='@';
      Player.Solution:=Player.Solution+'l'; //записать ход в переменную
     end;
'.': Begin //место для ящика
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Dec(Player.x); //уменьшить X координату игрока
      Sklad[Player.y,Player.x]:='+';
      Player.Solution:=Player.Solution+'l'; //записать ход в переменную
     end;
'$': begin //ящик
      if Player.x<2 then exit;
      case Sklad[Player.y,Player.x-2] of
       ' ': begin //пусто
          Sklad[Player.y,Player.x-2]:='$';
          Sklad[Player.y,Player.x-1]:='@';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Dec(Player.x);
          Player.Solution:=Player.Solution+'L';
            end;
       '.': begin //цель
               Sklad[Player.y,Player.x-2]:='*';
               Sklad[Player.y,Player.x-1]:='@';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Dec(Player.x);
               Player.Solution:=Player.Solution+'L';
            end;
      end;
     end;
'*': begin //ящик на цели
      if Player.x<2 then exit;
      case Sklad[Player.y,Player.x-2] of
       ' ': begin //пусто
          Sklad[Player.y,Player.x-2]:='$';
          Sklad[Player.y,Player.x-1]:='+';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Dec(Player.x);
          Player.Solution:=Player.Solution+'L';
       end;
       '.': begin //цель
               Sklad[Player.y,Player.x-2]:='*';
               Sklad[Player.y,Player.x-1]:='+';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Dec(Player.x);
               Player.Solution:=Player.Solution+'L';
            end;
      end;
     end;
 end;
end;

procedure MoveRight; //переместиться вправо
begin
  if Player.x=High(Sklad[Player.y]) then Exit;//двигаться некуда
case Sklad[Player.y,Player.x+1] of
'#': Exit;//стена
' ': Begin //пусто
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Inc(Player.x); //увеличить X координату игрока
      Sklad[Player.y,Player.x]:='@';
      Player.Solution:=Player.Solution+'r'; //записать ход в переменную
     end;
'.': Begin //место для ящика
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Inc(Player.x); //увеличить X координату игрока
      Sklad[Player.y,Player.x]:='+';
      Player.Solution:=Player.Solution+'r'; //записать ход в переменную
     end;
'$': begin //ящик
      if Player.x>(High(Sklad[Player.Y])-2) then exit;
      case Sklad[Player.y,Player.x+2] of
       ' ': begin //пусто
          Sklad[Player.y,Player.x+2]:='$';
          Sklad[Player.y,Player.x+1]:='@';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Inc(Player.x);
          Player.Solution:=Player.Solution+'R';
            end;
       '.': begin //цель
               Sklad[Player.y,Player.x+2]:='*';
               Sklad[Player.y,Player.x+1]:='@';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Inc(Player.x);
               Player.Solution:=Player.Solution+'R';
            end;
      end;
     end;
'*': begin //ящик на цели
      if Player.x>(High(Sklad[Player.Y])-2) then exit;
      case Sklad[Player.y,Player.x+2] of
       ' ': begin //пусто
          Sklad[Player.y,Player.x+2]:='$';
          Sklad[Player.y,Player.x+1]:='+';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Inc(Player.x);
          Player.Solution:=Player.Solution+'R';
       end;
       '.': begin //цель
               Sklad[Player.y,Player.x+2]:='*';
               Sklad[Player.y,Player.x+1]:='+';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Inc(Player.x);
               Player.Solution:=Player.Solution+'R';
            end;
      end;
     end;
 end;
end;


procedure MoveUp; //переместиться вверх
begin
  if Player.y=0 then Exit;//двигаться некуда
case Sklad[Player.y-1,Player.x] of
'#': Exit;//стена
' ': Begin //пусто
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Dec(Player.y); //уменьшить вертикальную координату игрока
      Sklad[Player.y,Player.x]:='@';
      Player.Solution:=Player.Solution+'u'; //записать ход в переменную
     end;
'.': Begin //место для ящика
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Dec(Player.y); //уменьшить вертикальную координату игрока
      Sklad[Player.y,Player.x]:='+';
      Player.Solution:=Player.Solution+'u'; //записать ход в переменную
     end;
'$': begin //ящик
      if Player.y<2 then exit;
      case Sklad[Player.y-2,Player.x] of
       ' ': begin //пусто
          Sklad[Player.y-2,Player.x]:='$';
          Sklad[Player.y-1,Player.x]:='@';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Dec(Player.y);
          Player.Solution:=Player.Solution+'U';
            end;
       '.': begin //цель
               Sklad[Player.y-2,Player.x]:='*';
               Sklad[Player.y-1,Player.x]:='@';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Dec(Player.y);
               Player.Solution:=Player.Solution+'U';
            end;
      end;
     end;
'*': begin //ящик на цели
      if Player.y<2 then exit;
      case Sklad[Player.y-2,Player.x] of
       ' ': begin //пусто
          Sklad[Player.y-2,Player.x]:='$';
          Sklad[Player.y-1,Player.x]:='+';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Dec(Player.y);
          Player.Solution:=Player.Solution+'U';
       end;
       '.': begin //цель
               Sklad[Player.y-2,Player.x]:='*';
               Sklad[Player.y-1,Player.x]:='+';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Dec(Player.y);
               Player.Solution:=Player.Solution+'U';
            end;
      end;
     end;
 end;
end;

procedure MoveDown; //переместиться вниз
begin
  if Player.y=High(Sklad) then Exit;//двигаться некуда
case Sklad[Player.y+1,Player.x] of
'#': Exit;//стена
' ': Begin //пусто
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Inc(Player.y); //увеличить левую координату игрока
      Sklad[Player.y,Player.x]:='@';
      Player.Solution:=Player.Solution+'d'; //записать ход в переменную
     end;
'.': Begin //место для ящика
      if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
       else Sklad[Player.y,Player.x]:=' ';
      Inc(Player.y); //уменьшить левую координату игрока
      Sklad[Player.y,Player.x]:='+';
      Player.Solution:=Player.Solution+'d'; //записать ход в переменную
     end;
'$': begin //ящик
      if Player.x>(High(Sklad)-1) then exit;
      case Sklad[Player.y+2,Player.x] of
       ' ': begin //пусто
          Sklad[Player.y+2,Player.x]:='$';
          Sklad[Player.y+1,Player.x]:='@';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Inc(Player.y);
          Player.Solution:=Player.Solution+'D';
            end;
       '.': begin //цель
               Sklad[Player.y+2,Player.x]:='*';
               Sklad[Player.y+1,Player.x]:='@';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Inc(Player.y);
               Player.Solution:=Player.Solution+'D';
            end;
      end;
     end;
'*': begin //ящик на цели
      if Player.x>(High(Sklad)-2) then exit;
      case Sklad[Player.y+2,Player.x] of
       ' ': begin //пусто
          Sklad[Player.y+2,Player.x]:='$';
          Sklad[Player.y+1,Player.x]:='+';
          if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
            else Sklad[Player.y,Player.x]:=' ';
          Inc(Player.y);
          Player.Solution:=Player.Solution+'D';
       end;
       '.': begin //цель
               Sklad[Player.y+2,Player.x]:='*';
               Sklad[Player.y+1,Player.x]:='+';
               if Sklad[Player.y,Player.x]='+' then Sklad[Player.y,Player.x]:='.'
                 else Sklad[Player.y,Player.x]:=' ';
               Inc(Player.y);
               Player.Solution:=Player.Solution+'D';
            end;
      end;
     end;
 end;
end;


begin
 case Key of
VK_LEFT  : MoveLeft;
VK_RIGHT : MoveRight;
VK_UP    : MoveUp;
VK_DOWN  : MoveDown;
 end;
 SkladDrawGrid.Repaint;
 if CheckWin then begin
  ShowMessage('Поздравляем! Вы прошли уровень! Ваш результат: '+IntToStr(Length(Player.Solution))+' ходов');
  Nextlevel;
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
 //обнуляем данные игрока
 Player.x:=0;
 Player.y:=0;
 Player.Solution:='';
 AssignFile(t,ProgramDirectory+DirectorySeparator+'data'+DirectorySeparator+IntToStr(levnom)+'.xsb');
 Reset(t);
 currline:=0;
 repeat
  Inc(currline);
  ReadLN(t,s);
  SetLength(Sklad,currline);
  SetLength(Sklad[currline-1],Length(s));
  for i:=1 to Length(s) do begin
       Sklad[currline-1,i-1]:=s[i];
       case s[i] of
    '@','+': begin //координаты игрока
          Player.y:=currline-1;
          Player.x:=i-1;
        end;
   end;
  end;
 until EoF(t);
end;

procedure TForm1.Nextlevel;
begin
 Inc(CurrLevel); //увеличить на 1 счётчик уровней
 if not LoadLevel(CurrLevel) then begin //пробуем загрузить уровень
  if CurrLevel=1 then begin;
  ShowMessage('Отсутствует файл уровня!');
  Exit; //отсутствует файл - выходим ничего не делая
  end else begin
   //закончились уровни - игра пройдена
   ShowMessage('Поздравляем! Вы прошли все уровни!');
   CurrLevel:=0;
   Nextlevel;
  end;
 end;
 //размеры формы подогнать под размеры уровня
 Width:=(High(Sklad[0])+1)*SkladDrawGrid.DefaultColWidth+5;
 Height:=(High(Sklad)+1)*SkladDrawGrid.DefaultRowHeight+Panel1.Height+5;
 //размеры отображаемого склада установить соответственно размеров уровня
 SkladDrawGrid.ColCount:=High(Sklad[0])+1; //количество колонок
 SkladDrawGrid.RowCount:=High(Sklad)+1; //количество строк
end;

function TForm1.CheckWin: Boolean;
 var BoxesLeft : Integer;
     i,j : Integer;
begin
  result:=false;
  for i:=0 to High(Sklad) do
   for j:=0 to High(Sklad[i]) do if Sklad[i,j]='$' then Exit;
  result:=true;
end;

end.

