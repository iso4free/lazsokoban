  if not CanDraw then Exit;
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
